//
//  Disk.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import Foundation
import DiskArbitration

// MARK: - Constants

/// Disk Error
enum DiskError: Error {
    
    /// Provided type is not a valid device type
    case NotValidDeviceType(type: String)
    
    /// No user path was found
    case NoUserPathFound
    
    /// Invalid path was provided
    case InvalidPath
    
    /// Unable to get description
    case UnableToGetDescription
    
    /// Unsupported protocol
    case UnsupportedProtocol
}

/// Supported Disk Protocols
enum DiskProtocol: String {
    
    /// Thunderbolt
    case Thunderbolt = "Thunderbolt"
    
    /// USB
    case USB = "USB"
}

/// A object that is tied to a disk that is attached to the device.
struct Disk: Hashable {
    
    // MARK: - Properties
    
    /// The name of the device that is normally displayed to the user
    let name: String
    
    // TODO: Have the enum created above tied to this property
    /// The type of volume
    let volumeType: String
    
    /// The URL object tied to the disk object
    let pathURL: URL
    
    /// The capacity of the device
    /// - Note: This can be turned into human reable form by using the `Disk.byteCountFormatter` object
    let capacity: Int
    
    /// The current free space on the drive
    /// - Note: This can be turned into human reable form by using the `Disk.byteCountFormatter` object
    let free: Int
    
    /// The current used space on the drive
    /// - Note: This can be turned into human reable form by using the `Disk.byteCountFormatter` object
    let used: Int
    
    // TODO: Remove this, as if the drive is mounted, then it has been decrypted.
    /// Is the drive currently encrypted?
    let isEncrypted: Bool
    
    /// The capacity of the drive as a string
    var capacityString: String {
        get {
            return Disk.byteCountFormatter.string(for: self.capacity) ?? "Error Calculating"
        }
    }
    
    /// The free space on the drive as a string
    var freeString: String {
        get {
            Disk.byteCountFormatter.string(for: self.free) ?? "Error Calculating"
        }
    }
    
    /// The used space on the drive as a string
    var usedString: String {
        get {
            Disk.byteCountFormatter.string(for: self.used) ?? "Error Calculating"
        }
    }
    
    // MARK: - Static Properties
    private static let byteCountFormatter = ByteCountFormatter()
    
    
    // MARK: Static Functions
    
    // TODO: Add all throws in documentation
    /**
     Create a disk object from a URL object
     - Parameters:
        - url: The URL object that the disk object should be created from
     - Returns: `Disk` object
     - Throws: `DiskError` is conditions aren't met
     */
    static func fromURL(_ url: URL) throws -> Disk {
        guard let diskObj = DADiskCreateFromVolumePath(nil, DASessionCreate(nil)!, url.absoluteURL as CFURL) else { throw DiskError.InvalidPath }
        guard let diskDict = DADiskCopyDescription(diskObj) as? [String: Any] else { throw DiskError.UnableToGetDescription }
        
        if (diskDict["DAMediaEjectable"] as? Int) != 1 && diskDict["DADeviceProtocol"] as? String != "Thunderbolt" {
            //print(diskDict["DADeviceProtocol"])
            throw DiskError.NotValidDeviceType(type: "Non-Removable")
        }
        
        if diskDict["DADeviceModel"] as? String == "Disk Image" {
            throw DiskError.NotValidDeviceType(type: "Disk Image")
        }
        
        //print(diskDict["DADeviceModel"])
        //print(diskDict["DADeviceProtocol"])
        let pathURL = diskDict["DAVolumePath"] as? URL
        let values = try! pathURL?.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        var freeCap = 0
        if let capacity = values?.volumeAvailableCapacity {
            print("Available capascity for important usage: \(capacity)")
            freeCap = capacity
        } else {
            print("Capacity is unavailable")
        }
        
        #if DEBUG
        //dump(diskDict)
        #endif
        
        return Disk(
            name: String(describing: diskDict["DAVolumeName"] ?? ""),
            volumeType: diskDict["DAVolumeType"] as? String ?? "",
            pathURL: url,
            capacity: diskDict["DAMediaSize"] as? Int ?? 0,
            free: freeCap,
            used: (diskDict["DAMediaSize"] as? Int ?? 0) - freeCap,
            isEncrypted: diskDict["DAMediaEncrypted"] as? Int ?? 0 == 1
        )
    }
    
    // MARK: Private Functions
    
    // TODO: Remove this as the byteFormatter is better
    /**
     Convert provided size to a string
     - Parameters:
        - size: The size of the disk to be converted to string
     - Returns: size as `String`
     */
    private func sizeToString(_ size: Int) -> String {
        var currentSize: Double = Double(size)
        
        let sizeDict = [
            "Bytes",
            "KB",
            "MB",
            "GB",
            "TB"
        ]
        
        var currPos = 0
        while currentSize > 1000 {
            currentSize = currentSize / 1000
            currPos = currPos + 1
        }
        
        return "\(String(describing: currentSize)) \(sizeDict[currPos])"
    }
}
