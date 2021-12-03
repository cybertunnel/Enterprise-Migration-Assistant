//
//  Folder.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import Foundation

class Folder:Hashable {
    
    let name: String
    var sizeOnDisk: Int?
    var sizeOnDiskString: String? {
        get {
            do {
                let size = try self.urlPath.sizeOnDisk()
                return size
            } catch {
                return nil
            }
        }
    }
    var processingSize: Bool = false
    var urlPath: URL
    
    init (name: String, urlPath: URL, size: Int? = nil) {
        self.name = name
        self.urlPath = urlPath
        self.processingSize = true
        
        //  Use this for creating a dummy object
        if size != nil {
            self.sizeOnDisk = size
            return
        }
        
        DispatchQueue(label: "Determine Size", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil).async {
            do {
                let size = try self.urlPath.directoryTotalAllocatedSize(includingSubfolders: true)
                DispatchQueue.main.async {
                    self.sizeOnDisk = size
                    self.processingSize = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.sizeOnDisk = nil
                    self.processingSize = false
                }
            }
            
        }
    }
    
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        if lhs.name == rhs.name && lhs.sizeOnDisk == rhs.sizeOnDisk && lhs.urlPath == rhs.urlPath {
            return true
        }
        else {
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(urlPath)
    }
}
