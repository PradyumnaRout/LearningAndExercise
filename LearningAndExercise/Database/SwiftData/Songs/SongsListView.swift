//
//  SongsListView.swift
//  LearningAndExercise
//
//  Created by hb on 13/01/26.
//

import SwiftUI
import SwiftData

struct SongsListView: View {
    @Query private var songs: [Song]
    
    @State private var showSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    ContentUnavailableView("No songs found", systemImage: "radio.fill")
                } else {
                    List {
                        ForEach(songs) { song in
                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .font(.title3)
                                
                                Text(song.albumName)
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showSheet, content: {
                AddSongView()
                    .presentationDetents([.medium])
            })
            .navigationTitle("My Songs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    SongsListView()
}

struct AddSongView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var albumName: String = ""
    @State private var runtime: String = ""
    @State private var relaseYear: String = ""
    
    var body: some View {
        NavigationStack {
            var disable: Bool {
                return name.isEmpty || albumName.isEmpty || runtime.isEmpty || relaseYear.isEmpty
            }

            VStack {
                HStack {
                    Text("Name")
                    TextField("Enter name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Album")
                    TextField("Album Name", text: $albumName)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Runtime")
                    TextField("0.0", text: $runtime)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Release Year")
                    TextField("XXXX", text: $relaseYear)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button {
                    insertSong()
                } label: {
                    Text("Save")
                        .frame(width: 150, height: 35)
                }
                .padding(.top, 20)
                .buttonStyle(.bordered)
                .disabled(disable)
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("Add Song")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func insertSong() {
        let song = Song(
            title: name,
            albumName: albumName,
            runTime: runtime,
            releaseYear: relaseYear
        )
        
        context.insert(song)
        dismiss()
    }
}
