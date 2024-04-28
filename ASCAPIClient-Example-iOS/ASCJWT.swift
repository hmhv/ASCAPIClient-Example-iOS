//
//  ASCJWT.swift
//  ASCAPIClient-Example-iOS
//
//  Created by u1 on 2022/06/25.
//

import Foundation
import CryptoKit

enum ASCJWT {
    static func generateJWT(keyID: String, issuerID: String, privateKey: String) throws -> String {
        let header = Header(kid: keyID)
        let payload = Payload(iss: issuerID)
        let headerAndPayloadString = header.toJWTEncodedString + "." + payload.toJWTEncodedString
        let headerAndPayloadData = Data(headerAndPayloadString.utf8)
        
        let signedToken = try P256.Signing.PrivateKey(pemRepresentation: privateKey)
            .signature(for: headerAndPayloadData)
            .rawRepresentation.toBase64JWTEncodedString
        return headerAndPayloadString + "." + signedToken
    }
    
    private struct Header: Encodable {
        let alg = "ES256"
        let kid: String
        let typ = "JWT"
    }

    private struct Payload: Encodable {
        let iss: String
        let iat: Date
        let exp: Date
        let aud: String
        
        init(iss: String) {
            let now = Date.now
            self.iss = iss
            self.iat = Date(timeInterval: 0, since: now)
            self.exp = Date(timeInterval: 60 * 20, since: now)
            self.aud = "appstoreconnect-v1"
        }
    }
}

private extension Encodable {
    var toJWTEncodedString: String {
        try! JSONEncoder.jwtEncoder.encode(self).toBase64JWTEncodedString
    }
}

private extension JSONEncoder {
    static let jwtEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        return jsonEncoder
    }()
}
    
private extension Data {
    var toBase64JWTEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
