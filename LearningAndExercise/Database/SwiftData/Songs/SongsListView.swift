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
    @State private var showEditSheet: Bool = false
    @State private var selectedSong: Song?
    
    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    ContentUnavailableView("No songs found", systemImage: "radio.fill")
                } else {
                    List {
                        ForEach(songs) { song in
                            let runtimeText = song.runTimeInFloat.formatted(.number.precision(.fractionLength(1)))

                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .font(.title3)
                                
                                HStack(spacing: 0) {
                                    Text("\(song.album) /")
                                    Text("\(runtimeText) min")
                                }
                                .font(.footnote)
                                
                                Text("Song By: \(song.singer)")
                                    .font(.footnote)
                            }
                            .background(Color.red.opacity(0.01))
                            .onTapGesture(perform: {
                                selectedSong = song
                            })
                            .sheet(item: $selectedSong) { song in
                                EditSongView(song: song)
                                    .presentationDetents([.medium])
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
    @State private var runtime: Float = 0.0
    @State private var relaseYear: String = ""
    @State private var details: String = ""
    
    var body: some View {
        NavigationStack {
            var disable: Bool {
                return name.isEmpty || albumName.isEmpty || relaseYear.isEmpty
//                 return name.isEmpty || details.isEmpty || runtime.isEmpty
            }

            VStack {
                HStack {
                    Text("Name")
                    TextField("Enter name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Text("Album")
                    TextField("Album Name", text: $albumName)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                // As String
//                HStack {
//                    Text("Runtime")
//                    TextField("0.0", text: $runtime)
//                        .textFieldStyle(.roundedBorder)
//                        .autocorrectionDisabled()
//                }
                
                // As Float
                HStack {
                    Text("Runtime")
                    TextField("0.0", value: $runtime, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Release Year")
                    TextField("XXXX", text: $relaseYear)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
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
            album: albumName,
            runTime: runtime,
            releaseYear: relaseYear
        )
        
        context.insert(song)
        try? context.save()
        dismiss()
    }
}


struct EditSongView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var song: Song
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Name")
                    TextField("Enter name", text: $song.title)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Text("Album")
                    TextField("Album Name", text: $song.album)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
//                HStack {
//                    Text("Runtime")
//                    TextField("Runtime", text: $song.runTime)
//                        .textFieldStyle(.roundedBorder)
//                        .autocorrectionDisabled()
//                }
                
                HStack {
                    Text("Runtime")
                    TextField("0.0", text: Binding(
                        get: { String(song.runTimeInFloat) },
                        set: { song.runTimeInFloat = Float($0) ?? 0.0 }
                    ))
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Text("Release Year")
                    TextField("XXXX", text: $song.releaseYear)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Text("Song By")
                    TextField("Singer Name", text: $song.singer)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                
                Button {
                    insertSong()
                } label: {
                    Text("Save")
                        .frame(width: 150, height: 35)
                }
                .padding(.top, 20)
                .buttonStyle(.bordered)
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("Add Song")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func insertSong() {
        dismiss()
    }
}
