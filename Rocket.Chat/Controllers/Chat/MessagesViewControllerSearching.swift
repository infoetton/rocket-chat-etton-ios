//
//  MessagesViewControllerSearching.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension MessagesViewController {
    func updateSearchMessagesButton() {
        if subscription != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "Search"),
                style: .done,
                target: self,
                action: #selector(showSearchMessages)
            )
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc func showSearchMessages() {
        guard
            let controller = storyboard?.instantiateViewController(withIdentifier: "MessagesList"),
            let messageList = controller as? MessagesListViewController
            else {
                return
        }

        messageList.data.subscription = subscription
        messageList.data.isSearchingMessages = true
        let searchMessagesNav = BaseNavigationController(rootViewController: messageList)

        present(searchMessagesNav, animated: true, completion: nil)

    }
}
