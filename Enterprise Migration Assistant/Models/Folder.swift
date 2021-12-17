//
//  Folder.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import Foundation

class Folder:Hashable {
    
    // MARK: - Properties
    
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
    
    // MARK: - Initialiser
    
    init (name: String, urlPath: URL, size: Int? = nil) {
        self.name = name
        self.urlPath = urlPath
        self.processingSize = true
        
        //  Use this for creating a dummy object
        if size != nil {
            self.sizeOnDisk = size
            self.processingSize = false
            return
        } else {
            DispatchQueue(label: "Determine Size", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil).async {
                let size: Int? = self.determineSize(forPath: urlPath)
                
                DispatchQueue.main.async {
                    self.sizeOnDisk = size
                    self.processingSize = false
                }
            }
        }
    }
    
    private func determineSize(forPath path: URL) -> Int? {
        var size: Int? = nil
        do {
            size = try path.directoryTotalAllocatedSize(includingSubfolders: true)
            return size
        } catch {
            return nil
        }
    }
    
    // MARK: - Static Functions
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        if lhs.name == rhs.name && lhs.sizeOnDisk == rhs.sizeOnDisk && lhs.urlPath == rhs.urlPath {
            return true
        }
        else {
            return false
        }
    }
    
    
    // MARK: - Functions
    func hash(into hasher: inout Hasher) {
        hasher.combine(urlPath)
    }
}
