//
//  SeparatorView.swift
//  Medbrain
//
//  Created by Simon Anreiter on 14/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit

@IBDesignable class SeparatorView: UIView {

    @IBInspectable dynamic var width: CGFloat = -1 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable dynamic var height: CGFloat = -1 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func intrinsicContentSize() -> CGSize {
        var size = CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
        if width >= 0 {
            size.width = width / UIScreen.mainScreen().scale
        }
        if height >= 0 {
            size.height = height / UIScreen.mainScreen().scale
        }
        return size
    }
}
