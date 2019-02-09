//
//  PushNotificationsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

#if BETA || DEBUG
import FLEX
#endif

final class PushNotificationsViewController: BaseTableViewController {
    
    private let kSectionProfile = 0
    private let kSectionSettings = 1
    private let kSectionAdministration = 2
    private let kSectionLogout = 3
    
    private let viewModel = PreferencesViewModel()
    

    
    override var navigationController: PreferencesNavigationController? {
        return super.navigationController as? PreferencesNavigationController
    }
    
    weak var shareAppCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Уведомления"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true) {
            UserReviewManager.shared.requestReview()
        }
    }
    
}

extension PushNotificationsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
}
