//
//  Holder.swift
//  SelectableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

final class Holder {
    weak var viewController: UIViewController?
    private let imageViews: [ImageViewHolder]

    private final class ImageViewHolder {
        weak var value: SelectableImageView?
        fileprivate init(_ value: SelectableImageView) { self.value = value }
    }
    
    init(viewController: UIViewController, imageViews: [SelectableImageView]) {
        self.viewController = viewController
        self.imageViews = imageViews.map { .init($0) }
    }
    
    func hasImageView(_ imageView: SelectableImageView) -> Bool { imageViews.contains(where: { $0.value == imageView }) }
    
    func present() {
        let vc = ImagesViewController()
        vc.prepare(selectableImageViews: imageViews.compactMap { $0.value })
        viewController?.present(vc, animated: true, completion: nil)
    }
}
