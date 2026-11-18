//
//  AddStampView.swift
//  Stampy
//

import SwiftUI
import PhotosUI

struct AddStampView: View {
    @ObservedObject var vm: StampViewModel
    @StateObject private var form = AddStampViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let ui = form.image {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(Text("Select Stamp Image"))
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    let data = try? await newItem?.loadTransferable(type: Data.self)
                    form.setImageData(data)
                }
            }

            TextField("Stamp Name", text: $form.name)
                .textFieldStyle(.roundedBorder)
            TextField("Description", text: $form.details)
                .textFieldStyle(.roundedBorder)

            Picker("Menu category", selection: $form.menuCategory) {
                ForEach(MenuCategories.all, id: \.self) { category in
                    Text(category).tag(category)
                }
            }

            if let errorMessage = form.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    if await form.upload() {
                        await vm.fetchStamps()
                        dismiss()
                    }
                }
            } label: {
                if form.isUploading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Upload Stamp")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(StampyTheme.ink)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!form.canUpload)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    AddStampView(vm: StampViewModel())
}
