//
//  ViewController.swift
//  Example
//
//  Created by Koji Murata on 2020/03/20.
//  Copyright © 2020 Koji Murata. All rights reserved.
//

import UIKit
import FocusableImageView

class ViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    private let manager = FocusableImageViewManager()
    private var imageViews: [FocusableImageView] { stackView.arrangedSubviews as! [FocusableImageView] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        imageViews.forEach { $0.cornerRadius = 8 }
        manager.register(parentViewController: self, imageViews: imageViews)
    }
}

extension ViewController: FocusableImageViewDelegate {
    func selectableImageViewPresentAnimation(views: [FocusableImageView]) {
        views.forEach { $0.cornerRadius = 0 }
    }
    
    func selectableImageViewDismissAnimation(views: [FocusableImageView]) {
        views.forEach { $0.cornerRadius = 8 }
    }
}

extension FocusableImageView {
    var cornerRadius: CGFloat {
        get { imageView.layer.cornerRadius }
        set {
            imageView.layer.cornerRadius = newValue
            imageView.clipsToBounds = true
        }
    }
}
