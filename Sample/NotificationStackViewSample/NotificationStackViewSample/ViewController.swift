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

    var notificationStackView: NotificationStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationStackView = NotificationStackView()
        notificationStackView.containerEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        notificationStackView.containerView = self.view // Or UIApplication.shared.windows[index] (current window)
        notificationStackView.delegate = self
    }
    @IBAction func onStandardTap(_ sender: UIButton) {
        let notificationView = NotificationView(title: "Title", description: "description")
        notificationStackView.push(view: notificationView)
    }
    
    @IBAction func onCustomTap(_ sender: Any) {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.backgroundColor = UIColor.brown
        view.layer.cornerRadius = 4.0
        notificationStackView.push(view: view)
    }
    
    @IBAction func onPopAllTap(_ sender: Any) {
        notificationStackView.popAll()
    }
}

extension ViewController: NotificationStackViewDelegate {
    func didTap(notificationView: UIView, stackView: NotificationStackView) {
        stackView.pop(view: notificationView)
    }
}
