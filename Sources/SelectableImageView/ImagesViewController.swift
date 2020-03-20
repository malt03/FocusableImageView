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
    private let scrollContainerView = UIView()
    
    private var presenting = true
    private var constraints: [NSLayoutConstraint]?
    private var lastPanInfo: (velocityY: CGFloat, targetImageView: UIImageView)?
    
    private var pannableConstraints = [UIImageView: NSLayoutConstraint]()
    
    private weak var delegate: SelectableImageViewDelegate?
    private var configuration: SelectableImageViewConfiguration!
    private var selectableImageViews: [SelectableImageView]!
    private var selectedImageIndex: Int!
    private var dismissButton: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        presenting = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenting = false
        super.viewWillDisappear(animated)
    }
    
    func prepare(
        delegate: SelectableImageViewDelegate?,
        configuration: SelectableImageViewConfiguration,
        selectableImageViews: [SelectableImageView],
        selectedImageIndex: Int
    ) {
        self.delegate = delegate
        self.configuration = configuration
        self.selectableImageViews = selectableImageViews
        self.selectedImageIndex = selectedImageIndex
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }
    
    @objc private func tapped() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        view.addGestureRecognizer(pan)
        
        view.backgroundColor = .clear
        backgroundView.backgroundColor = configuration.backgroundColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.isPagingEnabled = true
        
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContainerView)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: scrollContainerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: scrollContainerView.heightAnchor),
        ])

        let button = configuration.createDismissButton?(view)
        button?.addTarget(self, action: #selector(close), for: .touchUpInside)
        dismissButton = button
    }
    
    @objc private func panned(_ sender: UIPanGestureRecognizer) {
        guard let target = pannableConstraints.keys.first(where: { $0.bounds.contains(sender.location(in: $0)) }) else { return }
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: view)
            pannableConstraints[target]?.constant = translation.y
        case .ended, .cancelled:
            lastPanInfo = (sender.velocity(in: view).y, target)
            close()
        default:
            break
        }
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
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
        configuration.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            presentAnimateTransition(using: transitionContext)
        } else {
            dismissAnimateTransition(using: transitionContext)
        }
    }
    
    private func presentAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        var constraints = [NSLayoutConstraint]()

        transitionContext.containerView.addSubview(view)
        view.frame = transitionContext.containerView.bounds
        scrollView.frame = view.bounds
        let widthMultiplier = CGFloat(selectableImageViews.count)
        scrollContainerView.frame = CGRect(
            x: 0, y: 0,
            width: widthMultiplier * scrollView.bounds.width,
            height: scrollView.bounds.height
        )
        scrollContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: widthMultiplier).isActive = true
        
        scrollView.contentOffset.x = scrollView.bounds.width * CGFloat(selectedImageIndex)
        
        view.layoutIfNeeded()
        
        var lastAnchor = scrollContainerView.leadingAnchor
        for selectableImageView in selectableImageViews {
            selectableImageView.removeImageView()
            let imageView = selectableImageView.imageView
            
            scrollContainerView.addSubview(imageView)
            imageView.frame = selectableImageView.convert(selectableImageView.bounds, to: scrollContainerView)
            let imageRatio = imageView.image.map { $0.size.width / $0.size.height } ?? 1
            let centerYConstraint = imageView.centerYAnchor.constraint(equalTo: scrollContainerView.centerYAnchor)
            constraints.append(contentsOf: [
                lastAnchor.constraint(equalTo: imageView.leadingAnchor),
                imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageRatio),
                centerYConstraint,
            ])
            lastAnchor = imageView.trailingAnchor
            pannableConstraints[imageView] = centerYConstraint
        }
        if let last = selectableImageViews.last {
            constraints.append(last.imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
        }
        
        NSLayoutConstraint.activate(constraints)
        self.constraints = constraints
        
        backgroundView.alpha = 0
        dismissButton?.alpha = 0
        backgroundView.frame = view.bounds

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.delegate?.selectableImageViewPresentAnimation(views: self.selectableImageViews)
            self.backgroundView.alpha = 1
            self.dismissButton?.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
    
    private func dismissAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let constraints = constraints {
            NSLayoutConstraint.deactivate(constraints)
        }
        constraints = nil

        var tmpConstraints = [NSLayoutConstraint]()
        var imageViewTargetRects = [UIImageView: CGRect]()
        for selectableImageView in self.selectableImageViews {
            let imageView = selectableImageView.imageView
            let newRect = selectableImageView.convert(selectableImageView.bounds, to: scrollContainerView)
            imageViewTargetRects[imageView] = newRect
            tmpConstraints.append(contentsOf: [
                imageView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: newRect.minX),
                imageView.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: newRect.minY),
                imageView.widthAnchor.constraint(equalToConstant: newRect.width),
                imageView.heightAnchor.constraint(equalToConstant: newRect.height),
            ])
        }
        
        NSLayoutConstraint.activate(tmpConstraints)
        
        let velocity: CGFloat
        if let lastPanInfo = lastPanInfo, let targetRect = imageViewTargetRects[lastPanInfo.targetImageView] {
            let fromCenterY = lastPanInfo.targetImageView.center.y
            let targetCenterY = targetRect.origin.y + targetRect.height / 2
            velocity = lastPanInfo.velocityY / (targetCenterY - fromCenterY)
        } else {
            velocity = 0
        }
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: velocity,
            animations: {
                self.delegate?.selectableImageViewDismissAnimation(views: self.selectableImageViews)
                self.backgroundView.alpha = 0
                self.dismissButton?.alpha = 0
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                NSLayoutConstraint.deactivate(tmpConstraints)
                self.selectableImageViews.forEach { $0.imageView.removeFromSuperview() }
                self.selectableImageViews.forEach { $0.addImageView() }
                transitionContext.completeTransition(true)
            }
        )
    }
}
