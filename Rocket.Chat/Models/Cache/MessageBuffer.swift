//
//  MessageBuffer.swift
//  Rocket.Chat
//
//  Created by Позднышев Максим on 09/02/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
//swiftlint: disable all

class MessageBuffer {
    
    // MARK: - Type Properties
    
    static let shared = MessageBuffer()
    
    // MARK: - Instance Properties
    
    var message: Message? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("bufferChanged"), object: nil)
        }
    }
    
    // MARK: - Instance Methods
    
    func reset() {
        self.message = nil
        NotificationCenter.default.post(name: Notification.Name("bufferChanged"), object: nil)
    }
}
