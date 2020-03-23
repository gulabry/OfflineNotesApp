//
//  NSLayoutConstraint+Extension.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit

public typealias CornerPinConstraints = (top: NSLayoutConstraint, bottom: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint)
public typealias LeftRightPinConstraints = (left: NSLayoutConstraint, right: NSLayoutConstraint)
public typealias SizeConstraints = (width: NSLayoutConstraint, height: NSLayoutConstraint)
public typealias CenterConstraints = (centerX: NSLayoutConstraint, centerY: NSLayoutConstraint)

public extension NSLayoutConstraint {
    @discardableResult
    func activate(_ activate: Bool = true) -> NSLayoutConstraint
    {
        self.isActive = activate
        return self
    }
}

public extension UIView {
    
    func setup(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }
            
    //  Constraints are accessable and transforable, can be made into array
    //        stack.top
    //        stack.bottom
    //        stack.leading
    //        stack.trailing
    //
    //  let array: [NSLayoutConstraint] = Tuple.makeArray(from: stackConstraints)
    //
    @discardableResult
    func addAndConstrainToParent(_ view: UIView, padding: CGFloat? = nil) -> CornerPinConstraints {
        setup(view)
        return (view.topAnchor.constraint(equalTo: self.topAnchor, constant: (padding ?? 0)).activate(), view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(padding ?? 0)).activate(), view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: (padding ?? 0)).activate(), view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(padding ?? 0)).activate())
    }
    
    @discardableResult
    func constrainTo(size: CGFloat) -> SizeConstraints {
        return (self.widthAnchor.constraint(equalToConstant: size).activate(), self.heightAnchor.constraint(equalToConstant: size).activate())
    }
    
    @discardableResult
    func centerIn(view: UIView) -> CenterConstraints {
        return (self.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate(), self.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate())
    }
    
    @discardableResult
    func constrainTo(left: CGFloat, right: CGFloat, of view: UIView) -> LeftRightPinConstraints {
        return (self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: left).activate(), self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: right).activate())
    }
    
    @discardableResult
    func constrainTo(top: CGFloat, bottom: CGFloat, of view: UIView) -> LeftRightPinConstraints {
        return (self.topAnchor.constraint(equalTo: view.topAnchor, constant: top).activate(), self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).activate())
    }
    
    @discardableResult
    func centerY(in view: UIView) -> NSLayoutConstraint {
        return centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
    }
    
    @discardableResult
    func centerX(in view: UIView) -> NSLayoutConstraint {
        return centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
    }
}
