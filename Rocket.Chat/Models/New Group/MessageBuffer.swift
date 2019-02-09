//
//  MessageBuffer.swift
//  Rocket.Chat
//
//  Created by Rishat Yakushev on 09/02/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

class MessageBuffer {
    
    // MARK: - Type Properties
    
    static let shared = MessageBuffer()
    
    // MARK: - Instance Properties
    
    var message: Message?
    
    // MARK: - Instance Methods
    
    func reset() {
        self.message = nil
    }
}
