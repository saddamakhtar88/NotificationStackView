//
//  NotificationView.swift
//  NotificationStackView
//
//  Created by Saddam Akhtar on 6/10/20.
//  Copyright © 2020 personal. All rights reserved.
//

import Foundation
import UIKit

class NotificationView: UIView {
    
    private var contentLeftInset: NSLayoutConstraint!
    private var contentTopInset: NSLayoutConstraint!
    private var contentRightInset: NSLayoutConstraint!
    private var contentBottomInset: NSLayoutConstraint!
    
    private var verticalSpacingBetweenLabels: CGFloat = 8.0
    
    public let titleLabel: UILabel = UILabel()
    public let descriptionLabel: UILabel = UILabel()
    
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            contentLeftInset.constant = contentInset.left
            contentTopInset.constant = contentInset.top
            contentRightInset.constant = -contentInset.right
            contentBottomInset.constant = -contentInset.bottom
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        initializeView()
    }
    
    public init(title: String, description: String?) {
        super.init(frame: CGRect.zero)
        verticalSpacingBetweenLabels = description != nil && !description!.isEmpty ? verticalSpacingBetweenLabels : 0.0
        
        initializeView()
        
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }
    
    private func initializeView() {
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        contentTopInset = contentView.topAnchor.constraint(equalTo: topAnchor,
                                         constant: contentInset.top)
        contentTopInset.isActive = true
        
        contentLeftInset = contentView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                             constant: contentInset.left)
        contentLeftInset.isActive = true
        
        contentRightInset = contentView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                              constant: -contentInset.right)
        contentRightInset.isActive = true
        
        contentBottomInset = contentView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                            constant: -contentInset.bottom)
        contentBottomInset.isActive = true
        
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 4.0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                              constant: verticalSpacingBetweenLabels).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
