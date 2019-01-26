//
//  SubscriptionsClient.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift

@testable import Rocket_Chat

class SubscriptionsClientSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.execute({ realm in
            realm.deleteAll()
        })
    }

    func testFetchSubscriptionsList() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        Realm.execute({ realm in
            realm.add(auth, update: true)
        })

        api.nextResult = JSON([
            "result": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "5ALsG3QhpJfdMpyc8"
                ],
                [
                    "t": "p",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "important",
                    "fname": nil,
                    "rid": "Ajalkjdaoiqw",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "LKSAJdklasd123"
                ]
            ],
            "success": true
        ])

        client.fetchSubscriptions(updatedSince: nil)
        XCTAssertEqual(Realm.current?.objects(Subscription.self).count, 2)
    }

    func testSubscriptionsUpdate() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.identifier = "subscription-identifier"
        subscription.name = "internal"
        subscription.auth = auth

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "update": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "subscription-identifier"
                ],
                [
                    "t": "p",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "important",
                    "fname": nil,
                    "rid": "Ajalkjdaoiqw",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "LKSAJdklasd123"
                ]
            ],
            "success": true
        ])

        client.fetchSubscriptions(updatedSince: nil)

        let subs = Realm.current?.objects(Subscription.self)
        XCTAssertEqual(subs?.count, 2)
        XCTAssertEqual(subs?[0].name, "general")
    }

    func testSubscriptionsRemove() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.identifier = "subscription-identifier"
        subscription.auth = auth

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "remove": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "subscription-identifier"
                ]
            ],
            "success": true
        ])

        client.fetchSubscriptions(updatedSince: nil)

        let object = Realm.current?.objects(Subscription.self).first
        XCTAssertNotNil(object)
        XCTAssertNil(object?.auth)
    }

    func testSubscriptionsRoomMapping() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.roomReadOnly = false
        subscription.rid = "subscription-rid"
        subscription.identifier = "subscription-identifier"
        subscription.auth = auth

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "update": [
                [
                    "_id": "subscription-rid",
                    "name": "123",
                    "fname": "123",
                    "t": "p",
                    "u": [
                        "_id": "hw5DThnhQmxDWnavu",
                        "username": "user2"
                    ],
                    "_updatedAt": "2018-01-24T21:02:04.318Z",
                    "customFields": [],
                    "ro": true
                ]
            ],
            "success": true
        ])

        client.fetchRooms(updatedSince: nil)

        let object = Realm.current?.objects(Subscription.self).first
        XCTAssertNotNil(object)
        XCTAssertTrue(object?.roomReadOnly ?? false)
    }

    func testFetchRoles() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let subscription = Subscription.testInstance("test-roles")
        let user = User.testInstance("test-user")
        let user2 = User.testInstance("test-user2")

        Realm.execute({ realm in
            realm.add(user, update: true)
            realm.add(user2, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "roles": [
                [
                    "u": [
                        "username": "test-user-username",
                        "_id": "test-user-identifier"
                    ],
                    "_id": "LG62dmF5XySq63GWk",
                    "rid": "test-roles-rid",
                    "roles": ["fixer", "moderator"]
                ],
                [
                    "u": [
                        "username": "test-user2-username",
                        "_id": "test-user2-identifier"
                    ],
                    "_id": "qa62dasdSq63Gak",
                    "rid": "test-roles-rid",
                    "roles": ["owner"]
                ]
            ],
            "success": true
        ])

        client.fetchRoles(subscription: subscription)

        guard
            let realm = Realm.current,
            let subscriptionObject = realm.objects(Subscription.self).first,
            let userObject = User.find(username: "test-user-username"),
            let user2Object = User.find(username: "test-user2-username")
        else {
            XCTFail("no results were found")
            return
        }

        XCTAssertEqual(userObject.rolesInSubscription(subscriptionObject).count, 2)
        XCTAssertEqual(user2Object.rolesInSubscription(subscriptionObject).count, 1)
    }
}
