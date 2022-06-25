//
//  ASCJWT.swift
//  ASCAPIClient-Example-iOS
//
//  Created by u1 on 2022/06/25.
//

import Foundation
import SwiftJWT

enum ASCJWT {
    static func generateJWT(keyID: String, issuerID: String, privateKey: String) throws -> String {
        let header = Header(kid: keyID)
        let claims = ASCClaims(iss: issuerID,
                              iat: Date(timeIntervalSinceNow: 0),
                              exp: Date(timeIntervalSinceNow: 1200),
                              aud: "appstoreconnect-v1")
        var jwt = JWT(header: header, claims: claims)
        let jwtSigner = JWTSigner.es256(privateKey: privateKey.data(using: .utf8)!)

        do {
            return try jwt.sign(using: jwtSigner)
        } catch {
            debugPrint("ERROR::JWT \(error.localizedDescription)")
            throw error
        }
    }
}

struct ASCClaims: Claims {
    let iss: String
    let iat: Date
    let exp: Date
    let aud: String
}

