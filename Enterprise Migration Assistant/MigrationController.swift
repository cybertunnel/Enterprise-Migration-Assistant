//
//  MigrationController.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import Foundation
import DiskArbitration
import SwiftUI

class MigrationController: ObservableObject {
    
    @Published var detectedDisks: Array <Disk> = []
    @Published var selectedDisk: Disk?
    @Published var selectedDiskFolders: Array <Folder>?
    @Published var selectedUserFolder: Folder?
    
    func beginDiskDetection() {
        let disks = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeURLKey], options: .skipHiddenVolumes)
        
        disks?.forEach { disk in
            do {
                let diskObj = try Disk.fromURL(disk)
                self.detectedDisks.append(diskObj)
            }
            catch DiskError.NotValidDeviceType(let type) {
                print("Unsupported type found: \(type)")
            }
            catch DiskError.UnableToGetDescription {
                print("Unable to get description")
            }
            catch {
                print("Unknown error occurred")
            }
        }
        
        
    }
    
    func detectPath() {
        guard let basePath = self.selectedDisk?.pathURL.path else { return }
        let path = basePath + "/Users/"
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: path)
            let user_folders = folders.filter { folder in
                if folder == ".localized" || folder == "Shared" || folder == ".DS_Store"{
                    return false
                }
                else {
                    return true
                }
            }
            DispatchQueue(label: "Folder Detection", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem).async {
                var user_folder_urls: Array <Folder> = []
                user_folder_urls = user_folders.map { user_folder in
                    var folder_url = URL(fileURLWithPath: self.selectedDisk?.pathURL.path ?? "" + "/Users/" + user_folder)
                    folder_url = folder_url.appendingPathComponent("Users/\(user_folder)")
                    
                    return Folder(name: user_folder, urlPath: folder_url)
                }
                
                DispatchQueue.main.async {
                    self.selectedDiskFolders = user_folder_urls
                }
            }
            
        } catch {
            print("ERROR processing folder lookup")
        }
    }
    
    func determineDiskUsage() {
        do {
            if let url = self.selectedUserFolder?.urlPath {
                //let sizeOnDisk = try FileManager.default.allocatedSizeOfDirectory(at: url)
                let sizeOnDisk = try self.selectedUserFolder?.urlPath.sizeOnDisk()
                
                print(sizeOnDisk)
                
            }
        }
        catch {
            print("ERROR")
            return
        }
    }
}
