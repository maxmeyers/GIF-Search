//
//  UIView+Extensions.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

extension UIView {
  func centerInParent() {
    guard let superview = superview else {
      print("centerInParent failed - no superview!")
      return
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: superview.centerXAnchor),
      centerYAnchor.constraint(equalTo: superview.centerYAnchor),
    ])
  }
  
  func pinEdgesToParent(including edges: [UIRectEdge] = [.left, .right, .top, .bottom]) {
    guard let superview = superview else {
      print("pinEdgesToParent failed - no superview!")
      return
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(edges.map {
      switch $0 {
      case .left:
        return leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor)
      case .right:
        return rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor)
      case .top:
        return topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor)
      case .bottom:
        return bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
      default:
        fatalError("Unsupported UIRectEdge: \($0)")
      }
    })
  }
}
