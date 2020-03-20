//
//  ViewController.swift
//  Example
//
//  Created by Koji Murata on 2020/03/20.
//  Copyright © 2020 Koji Murata. All rights reserved.
//

import UIKit
import SelectableImageView

class ViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    private let manager = SelectableImageViewManager()
    private var imageViews: [SelectableImageView] { stackView.arrangedSubviews as! [SelectableImageView] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        imageViews.forEach { $0.cornerRadius = 8 }
        manager.register(parentViewController: self, imageViews: imageViews)
    }
}

extension ViewController: SelectableImageViewDelegate {
    func selectableImageViewPresentAnimation(views: [SelectableImageView]) {
        views.forEach { $0.cornerRadius = 0 }
    }
    
    func selectableImageViewDismissAnimation(views: [SelectableImageView]) {
        views.forEach { $0.cornerRadius = 8 }
    }
}

extension SelectableImageView {
    var cornerRadius: CGFloat {
        get { imageView.layer.cornerRadius }
        set {
            imageView.layer.cornerRadius = newValue
            imageView.clipsToBounds = true
        }
    }
}
