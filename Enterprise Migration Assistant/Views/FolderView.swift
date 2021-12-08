//
//  FolderView.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import SwiftUI

struct FolderView: View {
    var folder: Folder
    var body: some View {
        HStack {
            Text(folder.name)
            Spacer()
            Text("Size: " + (self.folder.sizeOnDiskString ?? "Error Calculating"))
        }
        .padding()
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        let folderExample = Folder(name: "Example", urlPath: URL(fileURLWithPath: "/"), size: 1000000000)
        FolderView(folder: folderExample)
    }
}
