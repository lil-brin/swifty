//
//  Api.swift
//  SwiftyCompanion
//
//  Created by Brin on 6/6/19.
//  Copyright © 2019 Brin. All rights reserved.
//
import Foundation
import Alamofire

var tokenData : TokenModel?

class Api {
    let url = "https://api.intra.42.fr/"
    
    init() {
        print("init api class")
    }
    
    public func getToken(success: @escaping (TokenModel) -> Void, error: @escaping (Error) -> Void) {
        let parameters : Parameters = [
            "grant_type" : "client_credentials",
            "client_id" : "f6217668cad28cbe38036f1cc98c49211e56a6284d906fdbe4d65ca6d795c28c",
            "client_secret" : "710bca9b3456c434168a14170217e6972e778312982926fde267d4ba5fba145e"
        ]
        Alamofire.request(self.url + "oauth/token", method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success:
                guard let array = response.result.value as? [String: Any] else { return }
                tokenData = TokenModel(array)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func getUser(login : String, success: @escaping (UserModel) -> Void, error: @escaping (String) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(tokenData!.access_token)",
            "Accept": "application/json"
        ]
        Alamofire.request(self.url + "v2/users/\(login)", method: .get, headers: headers).responseUserModel { response in
            if ((response.response?.statusCode ?? 0) / 100 == 2 ) {
                if let userModel = response.result.value {
                    success(userModel)
                }
            } else {
                error("error")
            }
        }
    }
}
