//
//  FocusableImageViewManager.swift
//  FocusableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

public protocol FocusableImageViewDelegate: class {
    func focusableImageViewPresentAnimation(views: [FocusableImageView])
    func focusableImageViewDismissAnimation(views: [FocusableImageView])
}

public final class FocusableImageViewManager {
    public init() {}
    
    public var configuration = FocusableImageViewConfiguration.default
    public weak var delegate: FocusableImageViewDelegate?
    
    public func register<S: Sequence>(parentViewController: UIViewController, imageViews: S) where S.Element == FocusableImageView {
        for imageView in imageViews {
            imageView.tappedHandler = { [weak self] (imageView) in
                self?.present(imageView: imageView)
            }
        }
        viewController = parentViewController
        self.imageViews = imageViews.map { .init($0) }
    }
    
    weak var viewController: UIViewController?
    private var imageViews: [ImageViewHolder]?

    private final class ImageViewHolder {
        weak var value: FocusableImageView?
        fileprivate init(_ value: FocusableImageView) { self.value = value }
    }
    
    func present(imageView: FocusableImageView) {
        guard let viewController = viewController, let imageViews = imageViews else { return }
        let vc = ImagesViewController()
        let views = imageViews.compactMap { $0.value }
        vc.prepare(
            delegate: delegate,
            configuration: configuration,
            selectableImageViews: views,
            selectedImageIndex: views.firstIndex(of: imageView) ?? 0
        )
        viewController.present(vc, animated: true, completion: nil)
    }
}
