//
//  SelectableImageViewConfiguration.swift
//  SelectableImageView
//
//  Created by Koji Murata on 2020/03/21.
//

import UIKit

public struct SelectableImageViewConfiguration {
    let backgroundColor: UIColor
    let animationDuration: TimeInterval
    let createDismissButton: (_ parentView: UIView) -> UIButton
    
    public static var `default` = SelectableImageViewConfiguration()
    
    public init(
        backgroundColor: UIColor = .init(white: 0, alpha: 0.5),
        animationDuration: TimeInterval = 0.3,
        createDismissButton: @escaping ((_ parentView: UIView) -> UIButton) = defaultCreateDismissButton
    ) {
        self.backgroundColor = backgroundColor
        self.animationDuration = animationDuration
        self.createDismissButton = createDismissButton
    }
    
    public static let defaultCreateDismissButton = { (parentView: UIView) -> UIButton in
        let button: UIButton
//        if #available(iOS 13.0, *) {
//            button = UIButton(type: .close)
//        } else {
            button = UIButton()
            let title = Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "close", value: "", table: nil) ?? "close"
            button.setTitle(title, for: .normal)
//        }
        button.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(button)
        NSLayoutConstraint.activate([
            parentView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            parentView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: button.topAnchor),
        ])
        return button
    }
}
