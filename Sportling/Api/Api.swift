//
//  Api.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import Alamofire

public struct APIClient {
    
    private static let BASEURL = "https://bearrun.testausserveri.fi";
    
    /// Get Wilma studies
    public static func register(name: String, invite: String, phone: String, _ callback: @escaping (RegisterCallback) -> Void) {
        let requestUrl = BASEURL + "/signup"
        let decoder = JSONDecoder()
        var body = [String: String]();
        body["bear_name"] = name
        body["invite_code"] = invite
        body["phone_number"] = phone
        Alamofire.AF.request(requestUrl, method: .post,  parameters: body, encoder: JSONParameterEncoder.default).responseDecodable(of: RegisterResponse.self, decoder: decoder) { response in
            if response.error != nil {
                callback(RegisterCallback.error(response.error!))
                return
            }
            do {
                let responseObject = try response.result.get()
                callback(RegisterCallback.register(responseObject))
            } catch let err {
                callback(RegisterCallback.error(err))
            }
        }
    }
    
    public static func sendSteps(name: String, steps: Double, _ callback: @escaping (StepsCallback) -> Void) {
        let requestUrl = BASEURL + "/update"
        let decoder = JSONDecoder()
        var body = [String: String]();let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        body["uid"] = name
        body["date"] = dateFormatter.string(from: Date())
        body["steps"] = String(steps)
        Alamofire.AF.request(requestUrl, method: .post,  parameters: body, encoder: JSONParameterEncoder.default).responseDecodable(of: UpdateResponse.self, decoder: decoder) { response in
            if response.error != nil {
                callback(StepsCallback.error(response.error!))
                return
            }
            do {
                let responseObject = try response.result.get()
                callback(StepsCallback.update(responseObject))
            } catch let err {
                callback(StepsCallback.error(err))
            }
        }
    }
    
    public static func me(username: String,  _ callback: @escaping (MeCallback) -> Void) {
        let requestUrl = BASEURL + "/me"
        let parameters: Parameters = [
                "uid": username
        ]
        let decoder = JSONDecoder()
        Alamofire.AF.request(requestUrl, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseDecodable(of: MeResponse.self, decoder: decoder) { response in
            if response.error != nil {
                callback(MeCallback.error(response.error!))
                return
            }
            do {
                let responseObject = try response.result.get()
                callback(MeCallback.me(responseObject))
            } catch let err {
                callback(MeCallback.error(err))
            }
        }
    }
}
