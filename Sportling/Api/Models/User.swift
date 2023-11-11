//
//  User.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation

public struct User: Codable, Hashable, Identifiable {
    public var id: String {
        return bear_name
    }
    public let hue_deg: Int
    public let bear_name: String
    public let streak: Int
}
