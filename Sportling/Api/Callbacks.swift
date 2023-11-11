//
//  Callbacks.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation

public enum RegisterCallback {
    case register(RegisterResponse)
    case error(Error)
}

public enum StepsCallback {
    case update(UpdateResponse)
    case error(Error)
}


public enum MeCallback {
    case me(MeResponse)
    case error(Error)
}
