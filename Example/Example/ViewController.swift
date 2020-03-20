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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.register(parentViewController: self, imageViews: stackView.arrangedSubviews as! [SelectableImageView])
    }
}
