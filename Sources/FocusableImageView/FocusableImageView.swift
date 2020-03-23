//
//  FocusableImageView.swift
//  FocusableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

public class FocusableImageView: UIView {
    @IBInspectable public var image: UIImage? {
        get { inner.image }
        set { inner.image = newValue }
    }
    public override var contentMode: UIView.ContentMode {
        get { inner.contentMode }
        set { inner.contentMode = newValue }
    }
    
    public let inner = UIImageView()
    private var innerImageViewConstraints: [NSLayoutConstraint]?
    var tappedHandler: ((FocusableImageView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        inner.translatesAutoresizingMaskIntoConstraints = false
        addImageView()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(tapped))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addImageView() {
        addSubview(inner)
        let constraints = [
            topAnchor.constraint(equalTo: inner.topAnchor),
            bottomAnchor.constraint(equalTo: inner.bottomAnchor),
            leadingAnchor.constraint(equalTo: inner.leadingAnchor),
            trailingAnchor.constraint(equalTo: inner.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        innerImageViewConstraints = constraints
    }
    
    func removeImageView() {
        if let innerImageViewConstraints = innerImageViewConstraints {
            NSLayoutConstraint.deactivate(innerImageViewConstraints)
        }
        innerImageViewConstraints = nil
        inner.removeFromSuperview()
    }
    
    @objc private func tapped() {
        tappedHandler?(self)
    }
}
