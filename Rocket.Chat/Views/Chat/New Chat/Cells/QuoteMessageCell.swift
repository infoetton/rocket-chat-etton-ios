//
//  QuoteMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 17/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class QuoteMessageCell: BaseQuoteMessageCell, SizingCell {
    static let identifier = String(describing: QuoteMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = QuoteMessageCell.instantiateFromNib() else {
            return QuoteMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var messageUsername: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.borderWidth = 1
        }
    }

    @IBOutlet weak var purpose: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var readReceiptButton: UIButton!

    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var purposeHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        textHeightConstraint = NSLayoutConstraint(
            item: text,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 20
        )

        textHeightConstraint.isActive = true

        purposeHeightInitialConstant = purposeHeightConstraint.constant
        avatarLeadingInitialConstant = avatarLeadingConstraint.constant
        avatarWidthInitialConstant = avatarWidthConstraint.constant
        containerLeadingInitialConstant = containerLeadingConstraint.constant
        textLeadingInitialConstant = textLeadingConstraint.constant
        textTrailingInitialConstant = textTrailingConstraint.constant
        containerTrailingInitialConstant = containerTrailingConstraint.constant
        readReceiptWidthInitialConstant = readReceiptWidthConstraint.constant
        readReceiptTrailingInitialConstant = readReceiptTrailingConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)

        insertGesturesIfNeeded(with: username)
    }

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? QuoteChatItem else {
            return
        }

        configure(readReceipt: readReceiptButton)
        configure(
            with: avatarView,
            date: date,
            status: statusView,
            and: messageUsername,
            completeRendering: completeRendering
        )

        purpose.text = viewModel.purpose
        purposeHeightConstraint.constant = viewModel.purpose.isEmpty ? 0 : purposeHeightInitialConstant

        let attachmentText = viewModel.text ?? ""
        let attributedText = NSMutableAttributedString(string: attachmentText).transformMarkdown(with: theme)
        username.text = viewModel.title
        text.attributedText = attributedText

        let maxSize = CGSize(width: textLabelWidth, height: .greatestFiniteMagnitude)
        let textHeight = text.sizeThatFits(maxSize).height

        if textHeight > collapsedTextMaxHeight {
            isCollapsible = true
            arrow.alpha = 1

            if viewModel.collapsed {
                arrow.image = theme == .light ?  #imageLiteral(resourceName: "Attachment Collapsed Light") : #imageLiteral(resourceName: "Attachment Collapsed Dark")
                textHeightConstraint.constant = collapsedTextMaxHeight
            } else {
                arrow.image = theme == .light ? #imageLiteral(resourceName: "Attachment Expanded Light") : #imageLiteral(resourceName: "Attachment Expanded Dark")
                textHeightConstraint.constant = textHeight
            }
        } else {
            isCollapsible = false
            textHeightConstraint.constant = textHeight
            arrow.alpha = 0
        }
    }
}

extension QuoteMessageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        containerView.backgroundColor = theme.chatComponentBackground
        messageUsername.textColor = theme.titleText
        date.textColor = theme.auxiliaryText
        purpose.textColor = theme.auxiliaryText
        username.textColor = theme.actionTintColor
        text.textColor = theme.bodyText
        containerView.layer.borderColor = theme.borderColor.cgColor
    }
}
