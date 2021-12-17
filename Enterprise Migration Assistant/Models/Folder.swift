//
//  Folder.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import Foundation

/// An object that is tied to a specific folder on a disk
class Folder:Hashable {
    
    // MARK: - Properties
    
    /// Name of the folder which is normally displayed to the user
    let name: String
    
    /// The size this folder takes up on disk
    var sizeOnDisk: Int?
    
    // TODO: Convert this to use the byteFormatter to prevent extra calls to process the size of the file/folder
    /// The size of the folder as a `String`
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
    
    /// Is the size of this folder still being processed?
    var processingSize: Bool = false
    
    /// The `URL` path of this folder
    var urlPath: URL
    
    // MARK: - Initialiser
    
    /**
     Create a new Folder object
     - Parameters:
        - name: The user friendly name of the folder
        - urlPath: The `URL` object that references the folder to be used
        - size: Set the size of the folder automatically if you know it
     - Note: `size` can be set in SwiftUI previews to visualize what a view might look like
     */
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
    
    /**
     Determine the size of the specific path provided
     - Parameters:
        - path: The path to determine the size of as a `URL` object
     - Returns: The size of the folder as an `Int` object or `nil` if the folder doesn't exist
     */
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
