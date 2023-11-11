//
//  MeResponse.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation

public struct MeResponse: Codable, Hashable {
    public let bear_name: String;
    public let hue_deg: Int;
    public let my_invite_code: String;
    public let invited_users: [User];
    public let streak: Int;
    public let time_remaining: String;
}
