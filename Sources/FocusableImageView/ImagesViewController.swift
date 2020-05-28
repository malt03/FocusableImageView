//
//  ImagesViewController.swift
//  FocusableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

final class ImagesViewController: UIViewController {
    private let backgroundView = UIView()
    private let scrollView = UIScrollView()
    private let scrollContainerView = UIView()
    private let pageControl = UIPageControl()
    
    private var presenting = true
    private var constraints: [NSLayoutConstraint]?
    private var imageScrollViews = [UIScrollView]()
    private var lastPanInfo: (velocityY: CGFloat, targetImageView: UIImageView)?
    
    private var pannableConstraints = [UIView: NSLayoutConstraint]()
    
    private weak var delegate: FocusableImageViewDelegate?
    private var configuration: FocusableImageViewConfiguration!
    private var selectableImageViews: [FocusableImageView]!
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
        delegate: FocusableImageViewDelegate?,
        configuration: FocusableImageViewConfiguration,
        selectableImageViews: [FocusableImageView],
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
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        backgroundView.addSubview(pageControl)
        scrollView.addSubview(scrollContainerView)
        
        pageControl.hidesForSinglePage = configuration.pageControlConfiguration.hidesForSinglePage
        pageControl.pageIndicatorTintColor = configuration.pageControlConfiguration.pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = configuration.pageControlConfiguration.currentPageIndicatorTintColor
        pageControl.numberOfPages = selectableImageViews.count
        pageControl.currentPage = selectedImageIndex

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            backgroundView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 8),
            backgroundView.centerXAnchor.constraint(equalTo: pageControl.centerXAnchor),
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
        guard let target = pannableConstraints.keys.first(where: { (0...view.bounds.width).contains(scrollView.convert($0.center, to: view).x) }) else { return }
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: view)
            pannableConstraints[target]?.constant = translation.y
        case .ended, .cancelled:
            lastPanInfo = (sender.velocity(in: view).y, target.subviews.first! as! UIImageView)
            close()
        default:
            break
        }
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.scrollView { return }
        let page = Int((scrollView.contentOffset.x / scrollView.bounds.width) + 0.5)
        pageControl.currentPage = min(max(0, page), pageControl.numberOfPages - 1)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == self.scrollView { return nil }
        return scrollView.subviews.first
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView { return }
        let v = scrollView.subviews.first!
        scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - v.frame.height)/2, 0),
            left: 0,
            bottom: max((scrollView.frame.width - v.frame.width)/2, 0),
            right: 0
        )
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
        imageScrollViews = []
        for (i, selectableImageView) in selectableImageViews.enumerated() {
            selectableImageView.removeImageView()
            let imageView = selectableImageView.inner
            let imageScrollView = UIScrollView()
            imageScrollViews.append(imageScrollView)
            imageScrollView.clipsToBounds = false
            imageScrollView.translatesAutoresizingMaskIntoConstraints = false
            imageScrollView.delegate = self
            imageScrollView.maximumZoomScale = configuration.maximumZoomScale
            imageScrollView.bouncesZoom = false
            imageScrollView.bounces = false
            imageScrollView.showsVerticalScrollIndicator = false
            imageScrollView.showsHorizontalScrollIndicator = false
            
            scrollContainerView.addSubview(imageScrollView)
            imageScrollView.addSubview(imageView)

            imageScrollView.frame = CGRect(origin: CGPoint(x: CGFloat(i) * scrollView.bounds.width, y: 0), size: scrollView.bounds.size)
            
            let imageRatio = imageView.image.map { $0.size.width / $0.size.height } ?? 1
            let inset = max((imageScrollView.bounds.height - imageScrollView.bounds.width / imageRatio) / 2, 0)
            imageScrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
            
            imageView.frame = selectableImageView.convert(selectableImageView.bounds, to: imageScrollView)
            
            let centerYConstraint = imageScrollView.centerYAnchor.constraint(equalTo: scrollContainerView.centerYAnchor)
            constraints.append(contentsOf: [
                lastAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
                scrollView.widthAnchor.constraint(equalTo: imageScrollView.widthAnchor),
                scrollView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
                imageScrollView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                imageScrollView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                imageScrollView.topAnchor.constraint(equalTo: imageView.topAnchor),
                imageScrollView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                imageScrollView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageRatio),
                centerYConstraint,
            ])
            lastAnchor = imageScrollView.trailingAnchor
            pannableConstraints[imageScrollView] = centerYConstraint
        }
        if let last = imageScrollViews.last {
            constraints.append(last.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor))
        }
        
        NSLayoutConstraint.activate(constraints)
        self.constraints = constraints
        
        backgroundView.alpha = 0
        dismissButton?.alpha = 0
        backgroundView.frame = view.bounds

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.delegate?.focusableImageViewPresentAnimation(views: self.selectableImageViews)
            self.backgroundView.alpha = 1
            self.dismissButton?.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
    
    private func dismissAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        imageScrollViews.forEach { $0.setZoomScale(1, animated: true) }
        if let constraints = constraints {
            NSLayoutConstraint.deactivate(constraints)
        }
        constraints = nil

        var tmpConstraints = [NSLayoutConstraint]()
        var imageViewTargetRects = [UIImageView: CGRect]()
        for selectableImageView in self.selectableImageViews {
            let imageView = selectableImageView.inner
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
                self.delegate?.focusableImageViewDismissAnimation(views: self.selectableImageViews)
                self.backgroundView.alpha = 0
                self.dismissButton?.alpha = 0
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                NSLayoutConstraint.deactivate(tmpConstraints)
                self.selectableImageViews.forEach { $0.inner.removeFromSuperview() }
                self.selectableImageViews.forEach { $0.addImageView() }
                transitionContext.completeTransition(true)
            }
        )
    }
}
