//
//  RegisterResponse.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation

public struct RegisterResponse: Codable, Hashable {
    public let hue_deg: Int
    public let message: String
    public let my_invite_code: String
    public let uid: String
}
