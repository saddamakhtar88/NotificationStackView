//
//  ViewController.swift
//  NotificationStackViewSample
//
//  Created by Saddam Akhtar on 6/10/20.
//  Copyright © 2020 personal. All rights reserved.
//

import UIKit
import NotificationStackView

class ViewController: UIViewController {

    var topNotificationStackView: NotificationStackView!
    var bottomNotificationStackView: NotificationStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Top Stack
        topNotificationStackView = NotificationStackView()
        topNotificationStackView.containerEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        topNotificationStackView.containerView = self.view // Or UIApplication.shared.windows[index] (current window)
        topNotificationStackView.delegate = self
        
        // Bottom Stack
        bottomNotificationStackView = NotificationStackView()
        bottomNotificationStackView.containerView = self.view
        bottomNotificationStackView.containerEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        bottomNotificationStackView.position = .bottom
        bottomNotificationStackView.delegate = self
    }
    
    @IBAction func onTopStandardTap(_ sender: UIButton) {
        let notificationView = NotificationView(title: "Top Notification !!!", description: "I am on the top.... Top of the world :)")
        topNotificationStackView.push(view: notificationView)
    }
    
    @IBAction func onTopCustomTap(_ sender: Any) {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.backgroundColor = UIColor.brown
        view.layer.cornerRadius = 4.0
        topNotificationStackView.push(view: view)
    }
    
    @IBAction func onBottomStandardTap(_ sender: UIButton) {
        let notificationView = NotificationView(title: "Bottom Notification !!!", description: "I am on the bottom.... I am not liking it.... :(")
        bottomNotificationStackView.push(view: notificationView)
    }
    
    @IBAction func onBottomCustomTap(_ sender: Any) {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.backgroundColor = UIColor.brown
        view.layer.cornerRadius = 4.0
        bottomNotificationStackView.push(view: view)
    }
    
    @IBAction func onPopAllTap(_ sender: Any) {
        topNotificationStackView.popAll()
        bottomNotificationStackView.popAll()
    }
}

extension ViewController: NotificationStackViewDelegate {
    func didTap(notificationView: UIView, stackView: NotificationStackView) {
        stackView.pop(view: notificationView)
    }
}
