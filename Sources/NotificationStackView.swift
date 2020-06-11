//
//  NotificationStackView.swift
//  NotificationStackView
//
//  Created by Saddam Akhtar on 6/9/20.
//  Copyright © 2020 personal. All rights reserved.
//

import Foundation
import UIKit

public enum Position {
    case top
    case bottom
}

public protocol NotificationStackViewDelegate {
    func didTap(notificationView: UIView, stackView: NotificationStackView)
}

public class NotificationStackView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    public var delegate: NotificationStackViewDelegate?
    
    public var containerView: UIView? {
        get {
            return superview
        }
        set {
            if newValue != nil {
                setupContainerView(containerView: newValue!)
            } else {
                removeFromSuperview()
            }
        }
    }
    
    public var position: Position = .top {
        didSet {
            if position == .bottom {
                bottomConstraint?.isActive = true
                topConstraint?.isActive = false
            } else {
                topConstraint?.isActive = true
                bottomConstraint?.isActive = false
            }
        }
    }
    
    public var containerEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            leadingConstraint?.constant = containerEdgeInsets.left
            topConstraint?.constant = containerEdgeInsets.top
            trailingConstraint?.constant = -containerEdgeInsets.right
            bottomConstraint?.constant = -containerEdgeInsets.bottom
        }
    }
    
    public var verticalSpacing: CGFloat = 8.0 {
        didSet {
            stackView.spacing = verticalSpacing
            invalidateIntrinsicContentSize()
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        initializeView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }
    
    public override var intrinsicContentSize: CGSize {
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
        return stackView.frame.size
    }
    
    public func push(view: UIView, popAfter: Double = 0) {
        containerView?.bringSubviewToFront(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(panNotificationView))
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapNotificationView))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        if popAfter > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + popAfter) {
                self.pop(view: view)
            }
        }
        
        // Animate push
        view.layer.opacity = 0
        stackView.insertArrangedSubview(view, at: 0)
        view.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 1).isActive = true
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }){ (completed) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                view.layer.opacity = 1
            }) { (completed) in
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    public func pop(view: UIView? = nil) {
        if let viewToBePopped = view ?? stackView.arrangedSubviews.last {
            var poppingViewCenter = viewToBePopped.center
            if viewToBePopped.center.x != stackView.center.x {
                let draggedToLeft = viewToBePopped.center.x < stackView.center.x
                if draggedToLeft {
                    poppingViewCenter.x = -stackView.center.x
                } else {
                    poppingViewCenter.x = stackView.center.x * 3
                }
            }
            
            // Animate pop
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                viewToBePopped.center = poppingViewCenter
                viewToBePopped.layer.opacity = 0
            }) { (completed) in
                let codeBlock = {
                    self.stackView.removeArrangedSubview(viewToBePopped)
                    viewToBePopped.removeFromSuperview()
                    self.layoutIfNeeded()
                }
                if self.position == .bottom {
                    // TODO - Apply animation
                    codeBlock()
                    self.invalidateIntrinsicContentSize()
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        codeBlock()
                    }) { (completed) in
                        self.invalidateIntrinsicContentSize()
                    }
                }
            }
        }
    }
    
    public func popAll() {
        var delay = 0.01
        for view in stackView.arrangedSubviews.reversed() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                var center = view.center
                center.x += 1.0
                view.center = center
                self.pop(view: view)
            }
            
            delay += 0.01
        }
    }
    
    private var viewCenterBeforePan = CGPoint()
    @objc private func panNotificationView(_ gestureRecognizer:UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        
        if gestureRecognizer.state == .began {
           self.viewCenterBeforePan = piece.center
        } else if gestureRecognizer.state == .ended {
            let centerHalfway = stackView.center.x / 2
            if piece.center.x < centerHalfway || piece.center.x > stackView.center.x + centerHalfway {
                self.pop(view: gestureRecognizer.view!)
            } else {
                UIView.animate(withDuration: 0.2) {
                    piece.center = self.viewCenterBeforePan
                }
            }
        } else if gestureRecognizer.state != .cancelled {
            let newCenter = CGPoint(x: viewCenterBeforePan.x + translation.x,
                                    y: viewCenterBeforePan.y)
            piece.center = newCenter
        } else {
           piece.center = viewCenterBeforePan
        }
    }
    
    @objc private func tapNotificationView(_ gestureRecognizer:UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        delegate?.didTap(notificationView: gestureRecognizer.view!,
                         stackView: self)
    }
    
    private func setupContainerView(containerView: UIView) {
        guard containerView != superview else {
            return
        }
        
        removeFromSuperview()
        containerView.addSubview(self)
        
        leadingConstraint = leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                     constant: containerEdgeInsets.left)
        leadingConstraint!.isActive = true
        
        trailingConstraint = trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                       constant: -containerEdgeInsets.right)
        trailingConstraint!.isActive = true
        
        heightAnchor.constraint(lessThanOrEqualTo: containerView.heightAnchor, multiplier: 1).isActive = true
        
        let guide = containerView.safeAreaLayoutGuide
        topConstraint = topAnchor.constraint(equalTo: guide.topAnchor,
                                             constant: containerEdgeInsets.top)
        bottomConstraint = bottomAnchor.constraint(equalTo: guide.bottomAnchor,
                                                   constant: -containerEdgeInsets.bottom)
        
        if position == .top {
            topConstraint!.isActive = true
        } else {
            bottomConstraint!.isActive = true
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func initializeView() {
        translatesAutoresizingMaskIntoConstraints = false
        setContentCompressionResistancePriority(.required, for: .vertical)
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = verticalSpacing
        scrollView.addSubview(stackView);
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
}

extension NotificationStackView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
