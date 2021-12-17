//
//  HelperConstants.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/8/21.
//

import Foundation

/// Constants used by the helper and referencing classes/objects
enum HelperConstants {
    /// The Priviledged Helper's folder where the helper would be normally installed
    static let helpersFolder = "/Library/PrivilegedHelperTools/"
    
    /// The helper domain
    static let domain = "com.github.cybertunnel.Enterprise-Migration-Assistant.helper"
    
    /// The helper's path
    static let helperPath = helpersFolder + domain
}
