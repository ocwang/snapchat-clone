//
//  UIView+AutoLayout.swift
//  SnapClone
//
//  Created by Chase Wang on 1/20/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit

extension UIView {
    class func newAutoLayoutView() -> Self {
        let view = self.init()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }
}
