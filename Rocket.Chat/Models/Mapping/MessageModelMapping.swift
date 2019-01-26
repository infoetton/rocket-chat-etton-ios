//
//  MessageModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Message: ModelMappeable {
    //swiftlint:disable cyclomatic_complexity function_body_length
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].stringValue
        }

        self.rid = values["rid"].stringValue
        self.text = values["msg"].stringValue
        self.avatar = values["avatar"].string
        self.emoji = values["emoji"].string
        self.alias = values["alias"].stringValue
        self.internalType = values["t"].string ?? "t"
        self.role = values["role"].stringValue
        self.pinned = values["pinned"].bool ?? false
        self.unread = values["unread"].bool ?? false
        self.groupable = values["groupable"].bool ?? true
        self.snippetName = values["snippetName"].string
        self.snippetId = values["snippetId"].string

        if let createdAt = values["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }

        if let createdAt = values["ts"].string {
            self.createdAt = Date.dateFromString(createdAt)
        }

        if let updatedAt = values["_updatedAt"]["$date"].double {
            self.updatedAt = Date.dateFromInterval(updatedAt)
        }

        if let updatedAt = values["_updatedAt"].string {
            self.updatedAt = Date.dateFromString(updatedAt)
        }

        if let userIdentifier = values["u"]["_id"].string {
            self.userIdentifier = userIdentifier
            self.userBlocked = MessageManager.blockedUsersList.contains(userIdentifier)

            if let realm = realm {
                if let user = realm.object(ofType: User.self, forPrimaryKey: userIdentifier as AnyObject) {
                    user.map(values["u"], realm: realm)
                    realm.add(user, update: true)
                } else {
                    let user = User()
                    user.map(values["u"], realm: realm)
                    realm.add(user, update: true)
                }
            }
        }

        // Starred
        if let starred = values["starred"].array {
            self.starred.removeAll()
            starred.compactMap({ $0["_id"].string }).forEach(self.starred.append)
        }

        // Attachments
        if let attachments = values["attachments"].array {
            self.attachments.removeAll()

            attachments.forEach {
                guard var attachmentValue = try? $0.merged(with: JSON(dictionaryLiteral: ("messageIdentifier", values["_id"].stringValue))) else {
                    return
                }

                if let realm = realm {
                    var obj: Attachment!

                    // FA NOTE: We are not using Object.getOrCreate method here on purpose since
                    // we have to map the local modifications before mapping the current JSON on the object.
                    if let primaryKey = attachmentValue.rawString()?.md5(), let existingObj = realm.object(ofType: Attachment.self, forPrimaryKey: primaryKey) {
                        obj = existingObj
                        attachmentValue["collapsed"] = JSON(existingObj.collapsed)
                    } else {
                        obj = Attachment()
                    }

                    obj.map(attachmentValue, realm: realm)
                    realm.add(obj, update: true)
                    self.attachments.append(obj)
                } else {
                    let obj = Attachment()
                    obj.map(attachmentValue, realm: realm)
                    self.attachments.append(obj)
                }
            }
        }

        // URLs
        if let urls = values["urls"].array {
            self.urls.removeAll()

            for url in urls {
                let obj = MessageURL()
                obj.map(url, realm: realm)
                self.urls.append(obj)
            }
        }

        // Mentions
        if let mentions = values["mentions"].array {
            self.mentions.removeAll()

            for mention in mentions {
                let obj = Mention()
                obj.map(mention, realm: realm)
                self.mentions.append(obj)
            }
        }

        // Channels
        if let channels = values["channels"].array {
            self.channels.removeAll()

            for channel in channels {
                let obj = Channel()
                obj.map(channel, realm: realm)
                self.channels.append(obj)
            }
        }

        // Reactions
        self.reactions.removeAll()
        if let reactions = values["reactions"].dictionary {
            reactions.enumerated().compactMap {
                let reaction = MessageReaction()
                reaction.map(emoji: $1.key, json: $1.value)
                return reaction
            }.forEach(self.reactions.append)
        }
    }
}
