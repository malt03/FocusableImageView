//
//  AppDelegate.swift
//  Example
//
//  Created by Koji Murata on 2020/03/20.
//  Copyright © 2020 Koji Murata. All rights reserved.
//

import UIKit
import FocusableImageView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FocusableImageViewConfiguration.default = .init(
            backgroundColor: .init(white: 0, alpha: 0.5),
            animationDuration: 0.5,
            pageControlConfiguration: .init(hidesForSinglePage: false, pageIndicatorTintColor: nil, currentPageIndicatorTintColor: nil),
            createDismissButton: { (parentView) -> UIButton in
                let button = UIButton()
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("Close", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                parentView.addSubview(button)
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
                    button.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
                ])
                return button
            }
        )
        return true
    }
}

