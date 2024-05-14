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
            appListView
                .tabItem({
                    HStack {
                        Image(systemName: "app")
                        Text("Apps")
                    }
                })

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
            await vm.fetchAppList()
            await vm.fetchDeviceList()
            await vm.fetchXcodeList()
        }

    }

    var appListView: some View {
        NavigationView {
            List(vm.apps, id: \.id) { app in
                Section {
                    ContentRow(leftString: "name", rightString: app.attributes?.name ?? "NO name")
                    ContentRow(leftString: "sku", rightString: app.attributes?.sku ?? "NO sku")
                } header: {
                    Text(app.attributes?.bundleId ?? "NO bundleId").font(.body).textCase(.none)
                }
            }
            .navigationTitle("Apps")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var deviceListView: some View {
        NavigationView {
            List(vm.devices, id: \.id) { device in
                Section {
                    ContentRow(leftString: "deviceClass", rightString: device.attributes?.deviceClass?.rawValue ?? "NO deviceClass")
                    ContentRow(leftString: "model", rightString: device.attributes?.model ?? "NO model")
                    ContentRow(leftString: "addedDate", rightString: device.attributes?.addedDate?.description ?? "NO addedDate")

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
                    ContentRow(leftString: "version", rightString: xcodeVersion.attributes?.version ?? "NO version")
                    ContentRow(leftString: "testDestinations.count", rightString: xcodeVersion.attributes?.testDestinations?.count.description ?? "NO testDestinations")
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
                            await vm.startBuild(workflowID: workflowID)
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

struct ContentRow: View {
    let leftString: String
    let rightString: String

    var body: some View {
        HStack {
            Text(leftString)
                .foregroundColor(.gray)
                .bold()
            Spacer()
            Text(rightString)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


