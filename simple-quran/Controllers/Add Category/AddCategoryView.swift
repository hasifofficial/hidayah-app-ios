//
//  AddCategoryView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskManager: TaskManager
    @State private var categoryName = ""
    @State private var iconName = "folder"
    
    private let icons = [
        "folder",
        "bookmark",
        "star",
        "heart",
        "flag",
        "calendar",
        "alarm",
        "moon",
        "sun.max",
        "cloud"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("add_category_category_detail_section_title")) {
                    TextField(
                        "add_category_category_detail_category_name",
                        text: $categoryName
                    )
                    
                    Picker(
                        "add_category_category_detail_icon",
                        selection: $iconName
                    ) {
                        ForEach(icons, id: \.self) { icon in
                            Label {
                                Text(icon)
                            } icon: {
                                Image(systemName: icon)
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        taskManager.addCustomCategory(
                            name: categoryName,
                            icon: iconName
                        )
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("add_category_category_detail_add_category_button")
                            Spacer()
                        }
                    }
                    .foregroundColor(Color(uiColor: .lightGreen))
                    .disabled(categoryName.isEmpty)
                }
            }
            .navigationTitle("add_category_header_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("add_category_cancel_button") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(uiColor: .lightGreen))
                }
            }
        }
    }
}
