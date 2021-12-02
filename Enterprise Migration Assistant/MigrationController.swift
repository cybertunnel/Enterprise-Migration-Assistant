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
        let path = self.detectedDisks[0].pathURL.path + "/Users/"
        do {
            let folders = try FileManager.default.contentsOfDirectory(atPath: path)
            let user_folders = folders.filter { folder in
                if folder == ".localized" || folder == "Shared" {
                    return false
                }
                else {
                    return true
                }
            }
            
            print(user_folders)
        } catch {
            print("ERROR processing folder lookup")
        }
    }
    
    func determineDiskUsage() {
        
    }
}
