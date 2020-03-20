//
//  SelectableImageViewManager.swift
//  SelectableImageView
//
//  Created by Koji Murata on 2020/03/20.
//

import UIKit

public final class SelectableImageViewManager {
    public static let shared = SelectableImageViewManager()
    
    private init() {}
    
    public func register(parentViewController: UIViewController, imageViews: [SelectableImageView]) {
        for imageView in imageViews {
            imageView.tappedHandler = { [unowned self] (imageView) in
                guard let holder = self.holders.first(where: { $0.hasImageView(imageView) }) else { return }
                holder.present()
            }
        }
        holders.append(.init(viewController: parentViewController, imageViews: imageViews))
    }
    
    private var holders = [Holder]()
}
