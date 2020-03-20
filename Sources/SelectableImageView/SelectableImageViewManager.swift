//
//  SelectableImageViewManager.swift
//  SelectableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

public final class SelectableImageViewManager {
    public init() {}
    
    public var configuration = SelectableImageViewConfiguration.default
    
    public func register(parentViewController: UIViewController, imageViews: [SelectableImageView]) {
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
        weak var value: SelectableImageView?
        fileprivate init(_ value: SelectableImageView) { self.value = value }
    }
    
    func present(imageView: SelectableImageView) {
        guard let viewController = viewController, let imageViews = imageViews else { return }
        let vc = ImagesViewController()
        let views = imageViews.compactMap { $0.value }
        vc.prepare(
            configuration: configuration,
            selectableImageViews: views,
            selectedImageIndex: views.firstIndex(of: imageView) ?? 0
        )
        viewController.present(vc, animated: true, completion: nil)
    }
}
