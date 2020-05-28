//
//  FocusableImageViewConfiguration.swift
//  FocusableImageView
//
//  Created by Koji Murata on 2020/03/21.
//

import UIKit

public struct FocusableImageViewConfiguration {
    let backgroundColor: UIColor
    let animationDuration: TimeInterval
    let pageControlConfiguration: PageControlConfiguration
    let maximumZoomScale: CGFloat
    let createDismissButton: ((_ parentView: UIView) -> UIButton)?
    
    public static var `default` = FocusableImageViewConfiguration()
    
    public init(
        backgroundColor: UIColor = .init(white: 0, alpha: 0.5),
        animationDuration: TimeInterval = 0.3,
        pageControlConfiguration: PageControlConfiguration = .init(),
        maximumZoomScale: CGFloat = 1,
        createDismissButton: ((_ parentView: UIView) -> UIButton)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.animationDuration = animationDuration
        self.pageControlConfiguration = pageControlConfiguration
        self.maximumZoomScale = maximumZoomScale
        self.createDismissButton = createDismissButton
    }

    public struct PageControlConfiguration {
        let hidesForSinglePage: Bool
        let pageIndicatorTintColor: UIColor?
        let currentPageIndicatorTintColor: UIColor?
        
        public init(
            hidesForSinglePage: Bool = true,
            pageIndicatorTintColor: UIColor? = nil,
            currentPageIndicatorTintColor: UIColor? = nil
        ) {
            self.hidesForSinglePage = hidesForSinglePage
            self.pageIndicatorTintColor = pageIndicatorTintColor
            self.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
}
