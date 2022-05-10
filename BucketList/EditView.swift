//
//  EditView.swift
//  BucketList
//
//  Created by Ozgu Ozden on 2022/05/04.
//

import SwiftUI

struct EditView: View {
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    var onSave: (Location) -> Void
    
    var body: some View {
            NavigationView {
                Form {
                    Section {
                        TextField("Place name", text: $viewModel.name)
                        TextField("Description", text: $viewModel.description)
                    }
                    Section("Nearby…") {
                        switch viewModel.loadingState {
                            case .loaded:
                            ForEach(viewModel.pages, id: \.pageid) { page in
                                    Text(page.title)
                                        .font(.headline)
                                    + Text(": ") +
                                    Text(page.description)
                                        .italic()
                                }
                            case .loading:
                                Text("Loading…")
                            case .failed:
                                Text("Please try again later.")
                        }
                    }
                }
                .navigationTitle("Place details")
                .toolbar {
                    Button("Save") {
                        var newLocation = viewModel.location
                        newLocation.id = UUID()
                        newLocation.name = viewModel.name
                        newLocation.description = viewModel.description
                        
                        onSave(newLocation)
                        dismiss()
                    }
                    .task {
                        await viewModel.fetchNearbyPlaces()
                    }
                }
            }
        }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
    
        self.onSave = onSave

        _viewModel = StateObject(wrappedValue: ViewModel(location: location))
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: Location.example) { _ in }
    }
}
