//
//  FolderViewList.swift
//  Enterprise Migration Assistant
//
//  Created by Morgan, Tyler on 12/2/21.
//

import SwiftUI

struct FolderViewList: View {
    @Binding var selectedFolder: Folder?
    let folders: Array <Folder>
    var body: some View {
        VStack {
            List(self.folders, id: \.self, selection: self.$selectedFolder) { folder in
                FolderView(folder: folder)
            }
            Text("Selected Folder Size:" + String(describing: self.selectedFolder?.sizeOnDisk))
        }
    }
}

struct FolderViewList_Previews: PreviewProvider {
    static var previews: some View {
        let exampleFolders = [
            Folder(name: "Folder 1", urlPath: URL(fileURLWithPath: "/"), size: 20),
            Folder(name: "Folder 4", urlPath: URL(fileURLWithPath: "/"), size: 241413),
            Folder(name: "Folder 3", urlPath: URL(fileURLWithPath: "/"), size: 42350245),
            Folder(name: "Folder 5", urlPath: URL(fileURLWithPath: "/"), size: 05430516),
            Folder(name: "Folder 2", urlPath: URL(fileURLWithPath: "/"), size: 4320556)
        ]
        FolderViewList(selectedFolder: .constant(exampleFolders[0]), folders: exampleFolders)
    }
}
