//
//  ContentView.swift
//  ASCAPIClient-Example-iOS
//
//  Created by u1 on 2022/06/25.
//

import SwiftUI
import ASC

struct ContentView: View {
    @StateObject private var vm = ContentViewModel()
    @State private var workflowID = ""
    @FocusState var focus: Bool

    var body: some View {

        if let message = vm.message {
            VStack {
                Text(message)
                    .padding()
                    .onTapGesture {
                        vm.clearMessage()
                    }
            }
        }

        TabView {
            deviceListView
                .tabItem({
                    HStack {
                        Image(systemName: "iphone")
                        Text("Devices")
                    }
                })

            xcodeListView
                .tabItem({
                    HStack {
                        Image(systemName: "hammer.circle")
                        Text("Xcodes")
                    }
                })

            buildRunView
                .tabItem({
                    HStack {
                        Image(systemName: "arrow.clockwise.icloud.fill")
                        Text("Run")
                    }
                })
        }
        .task {
            await vm.fetchDeviceList()
            await vm.fetchXcodeList()
        }

    }

    var deviceListView: some View {
        NavigationView {
            List(vm.devices, id: \.id) { device in
                Section {
                    HStack {
                        Text("deviceClass")
                        Text(device.attributes?.deviceClass?.rawValue ?? "NO deviceClass")
                    }
                    HStack {
                        Text("model")
                        Text(device.attributes?.model ?? "NO model")
                    }
                    HStack {
                        Text("addedDate")
                        Text(device.attributes?.addedDate?.description ?? "NO addedDate")
                    }
                } header: {
                    Text(device.attributes?.name ?? "NO name").font(.body).textCase(.none)
                }
            }
            .navigationTitle("Registered Devices")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var xcodeListView: some View {
        NavigationView {
            List(vm.xcodeVersions, id: \.id) { xcodeVersion in
                Section {
                    HStack {
                        Text("version")
                        Text(xcodeVersion.attributes?.version ?? "NO version")
                    }
                    HStack {
                        Text("testDestinations.count")
                        Text(xcodeVersion.attributes?.testDestinations?.count.description ?? "NO testDestinations")
                    }
                } header: {
                    Text(xcodeVersion.attributes?.name ?? "NO name").font(.body).textCase(.none)
                }
            }
            .navigationTitle("Xcode Versions in Xcode Cloud")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var buildRunView: some View {
        NavigationView {
            Form {
                Section {
                    TextField("a3946af0-cc38-4e0b-acba-5575c8dad050", text: $workflowID)
                        .focused(self.$focus)
                }

                Section {
                    Button {
                        self.focus = false
                        guard !workflowID.isEmpty else { return }
                        
                        Task {
                            await vm.startBuild(wordflowID: workflowID)
                        }
                    } label: {
                        Text("Start a Build")
                            .frame(maxWidth: .infinity)
                    }
                }

            }
            .navigationTitle("Start a new Xcode Cloud build")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


