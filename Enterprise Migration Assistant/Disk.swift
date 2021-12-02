//
//  Disk.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 11/17/21.
//

import Foundation
import DiskArbitration
import SwiftUI

enum DiskError: Error {
    case NotValidDeviceType(type: String), NoUserPathFound, InvalidPath, UnableToGetDescription, UnsupportedProtocol
}

enum DiskProtocol: String {
    case Thunderbolt = "Thunderbolt"
}

struct Disk: Hashable {
    let name: String
    let volumeType: String
    let pathURL: URL
    let capacity: Int
    var capacityString: String {
        get {
            self.sizeToString(self.capacity)
        }
    }
    let free: Int
    var freeString: String {
        get {
            return self.sizeToString(self.free)
        }
    }
    let used: Int
    var usedString: String {
        get {
            return self.sizeToString(self.used)
        }
    }
    
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
    let isEncrypted: Bool
    
    static func fromURL(_ url: URL) throws -> Disk {
        guard let diskObj = DADiskCreateFromVolumePath(nil, DASessionCreate(nil)!, url.absoluteURL as CFURL) else { throw DiskError.InvalidPath }
        guard let diskDict = DADiskCopyDescription(diskObj) as? [String: Any] else { throw DiskError.UnableToGetDescription }
        
        if (diskDict["DAMediaEjectable"] as? Int) != 1 && diskDict["DADeviceProtocol"] as? String != "Thunderbolt" {
            print(diskDict["DADeviceProtocol"])
            throw DiskError.NotValidDeviceType(type: "Non-Removable")
        }
        
        if diskDict["DADeviceModel"] as? String == "Disk Image" {
            throw DiskError.NotValidDeviceType(type: "Disk Image")
        }
        
        print(diskDict["DADeviceModel"])
        print(diskDict["DADeviceProtocol"])
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
        dump(diskDict)
        #endif
        
        return Disk(
            name: String(describing: diskDict["DAVolumeName"]),
            mediaBSDName: diskDict["DAMediaBSDName"] as! String,
            volumeType: diskDict["DAVolumeType"] as! String,
            mediaContent: diskDict["DAMediaContent"] as! String,
            pathURL: url,
            capacity: diskDict["DAMediaSize"] as! Int,
            free: freeCap,
            used: (diskDict["DAMediaSize"] as! Int) - freeCap,
            isEncrypted: diskDict["DAMediaEncrypted"] as! Int == 1
        )
    }
}

struct Disk_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
