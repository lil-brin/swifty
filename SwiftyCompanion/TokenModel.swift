//
//  tokenData.swift
//  SwiftyCompanion
//
//  Created by Brin on 6/6/19.
//  Copyright © 2019 Brin. All rights reserved.
//
import Foundation

struct TokenModel : Codable {
    var access_token : String
    var expires_in : Double = 0
    var created_at : Double = 0
    let scope : String
    let token_type : String

    init(_ dictionary: [String: Any]) {
        print(dictionary)
        self.access_token = dictionary["access_token"] as? String ?? ""
        self.created_at = dictionary["created_at"] as? Double ?? 0
        self.expires_in = dictionary["expires_in"] as? Double ?? 0
        self.scope = dictionary["scope"] as? String ?? ""
        self.token_type = dictionary["token_type"] as? String ?? ""
    }
}
