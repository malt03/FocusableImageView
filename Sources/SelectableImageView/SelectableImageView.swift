//
//  SelectableImageView.swift
//  SelectableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

public class SelectableImageView: UIView {
    @IBInspectable public var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    public override var contentMode: UIView.ContentMode {
        get { imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    public let imageView = UIImageView()
    private var imageViewConstraints: [NSLayoutConstraint]?
    var tappedHandler: ((SelectableImageView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addImageView()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(tapped))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addImageView() {
        addSubview(imageView)
        let constraints = [
            topAnchor.constraint(equalTo: imageView.topAnchor),
            bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        imageViewConstraints = constraints
    }
    
    func removeImageView() {
        if let imageViewConstraints = imageViewConstraints {
            NSLayoutConstraint.deactivate(imageViewConstraints)
        }
        imageViewConstraints = nil
        imageView.removeFromSuperview()
    }
    
    @objc private func tapped() {
        tappedHandler?(self)
    }
}
