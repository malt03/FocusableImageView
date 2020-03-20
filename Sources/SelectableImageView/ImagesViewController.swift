//
//  ImagesViewController.swift
//  SelectableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

final class ImagesViewController: UIViewController {
    private let backgroundView = UIView()
    private let scrollView = UIScrollView()
    
    private var presenting = true
    private var selectableImageViews: [SelectableImageView]!
    private var constraints: [NSLayoutConstraint]?
    
    override func viewWillAppear(_ animated: Bool) {
        presenting = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenting = false
        super.viewWillDisappear(animated)
    }
    
    func prepare(selectableImageViews: [SelectableImageView]) {
        self.selectableImageViews = selectableImageViews
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.isPagingEnabled = true
        
        view.addSubview(backgroundView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
    }
}

extension ImagesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension ImagesViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.24
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            presentAnimateTransition(using: transitionContext)
        } else {
            dismissAnimateTransition(using: transitionContext)
        }
    }
    
    private func presentAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.addSubview(view)
        view.frame = transitionContext.containerView.bounds
        
        var constraints = [NSLayoutConstraint]()
        var lastAnchor = scrollView.leadingAnchor
        for selectableImageView in selectableImageViews {
            selectableImageView.removeImageView()
            let imageView = selectableImageView.imageView
            scrollView.addSubview(imageView)
            imageView.frame = selectableImageView.convert(selectableImageView.bounds, to: scrollView)
            let imageRatio = imageView.image.map { $0.size.width / $0.size.height } ?? 1
            constraints.append(contentsOf: [
                lastAnchor.constraint(equalTo: imageView.leadingAnchor),
                imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageRatio),
            ])
            lastAnchor = imageView.trailingAnchor
        }
        if let last = selectableImageViews.last {
            constraints.append(last.imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
        }
        
        NSLayoutConstraint.activate(constraints)
        self.constraints = constraints
        
        backgroundView.alpha = 0
        backgroundView.frame = view.bounds

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.backgroundView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
    
    private func dismissAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        if let constraints = constraints {
//            NSLayoutConstraint.deactivate(constraints)
//        }
//        constraints = nil
//
//        let targetRect = sourceRect
//        view.addConstraints(
//            NSLayoutConstraint.constraints(
//                withVisualFormat: "|-(\(targetRect.origin.x))-[v(==\(targetRect.width))]",
//                options: [],
//                metrics: nil,
//                views: ["v": sourceImageView.innerImageView]
//                ) + NSLayoutConstraint.constraints(
//                    withVisualFormat: "V:|-(\(targetRect.origin.y))-[v(==\(targetRect.height))]",
//                    options: [],
//                    metrics: nil,
//                    views: ["v": sourceImageView.innerImageView]
//            )
//        )
//
//        let velocity: CGFloat
//        if let lastVelocityY = lastPanVelocityY {
//            let fromCenterY = sourceImageView.innerImageView.center.y
//            let targetCenterY = targetRect.origin.y + targetRect.height / 2
//            velocity = lastVelocityY / (targetCenterY - fromCenterY)
//        } else {
//            velocity = 0
//        }
//        UIView.animate(
//            withDuration: transitionDuration(using: transitionContext),
//            delay: 0,
//            usingSpringWithDamping: 1,
//            initialSpringVelocity: velocity,
//            options: .curveLinear,
//            animations: {
//                self.sourceImageView.cornerRadius = self.cornerRadius
//                self.backgroundView.alpha = 0
//                self.closeButton.alpha = 0
//                self.view.layoutIfNeeded()
//        },
//            completion: { _ in
//                self.sourceImageView.addSubviewWithFillConstraints(self.sourceImageView.innerImageView)
//                transitionContext.completeTransition(true)
//        }
//        )
    }
}
