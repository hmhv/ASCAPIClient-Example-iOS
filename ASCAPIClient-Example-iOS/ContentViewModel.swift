//
//  ContentViewModel.swift
//  ASCAPIClient-Example-iOS
//
//  Created by u1 on 2022/06/25.
//

import Foundation
import ASC

// Use your keyID, issuerID and privateKey
// https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
let keyID = "XXXXXXXXXX"
let issuerID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
let privateKey = """
-----BEGIN PRIVATE KEY-----
xxxxxxxxXXXXXXxxxxXXXxxXxxxxxxxXXXXXXxxxXXXXXXxxXXXXxxxXXXXXXXXX
XXXxxxxXXXxxXxxxxxxxXXXXXXxxxXXXXXXxxXXXXxxxXXXXXXXXXxxxxxxxxXXX
xxXXXXXXxxxXXXXXXxxXXXXxxxXXXXXXXXXxxxxxxxxXXXXXXxxxxXXXxxXxxxxx
XXxxxxxx
-----END PRIVATE KEY-----
"""

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var message: String?
    @Published var devices:  [Device] = []
    @Published var xcodeVersions:  [CiXcodeVersion] = []

    init() {
        do {
            ASCAPI.customHeaders = ["Authorization" : "Bearer \(try ASCJWT.generateJWT(keyID: keyID, issuerID: issuerID, privateKey: privateKey))"]
        } catch {
            message = error.localizedDescription
        }
    }

    func clearMessage() {
        message = nil
    }
    
    func fetchDeviceList() async {
        do {
            var response = try await DevicesAPI.devicesGetCollection(sort: [.platform_desc], limit: 10)
            var results = response.data

            // for paging check next url (response.links.next) and request using method xxxxxGetCollection(urlString: nextURLString)
            while let nextURLString = response.links.next {
                response = try await DevicesAPI.devicesGetCollection(urlString: nextURLString)
                results.append(contentsOf: response.data)
            }

            devices = results
        } catch {
            message = error.localizedDescription
        }
    }

    func fetchXcodeList() async {
        do {
            let response = try await CiXcodeVersionsAPI.ciXcodeVersionsGetCollection(limit: 200)
            xcodeVersions = response.data
        } catch {
            message = error.localizedDescription
        }
    }

    func startBuild(wordflowID: String) async {
        do {
            message = "Build Requested"
            let workflowData = CiBuildRunRelationshipsWorkflowData(type: .ciworkflows, id: wordflowID)
            let workflow = CiBuildRunCreateRequestDataRelationshipsWorkflow(data: workflowData)
            let relationships = CiBuildRunCreateRequestDataRelationships(workflow: workflow)
            let data = CiBuildRunCreateRequestData(type: .cibuildruns, relationships: relationships)
            let request = CiBuildRunCreateRequest(data: data)

            let response = try await CiBuildRunsAPI.ciBuildRunsCreateInstance(ciBuildRunCreateRequest: request)
            message = "Build Started: ID(\(response.data.id))"
        } catch {
            message = error.localizedDescription
        }
    }
}
