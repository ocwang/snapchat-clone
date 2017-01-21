//
//  UIButton+Autolayout.swift
//  SnapClone
//
//  Created by Chase Wang on 1/20/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit

extension UIButton {
    override class func newAutoLayoutView() -> Self {
        let view = self.init(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
}
