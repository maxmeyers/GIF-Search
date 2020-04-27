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
  
  func pinEdgesToParent(excluding excludedEdges: UIRectEdge) {
    let edges = ([.left, .right, .top, .bottom] as [UIRectEdge]).filter {
      !excludedEdges.contains($0)
    }
    pinEdgesToParent(including: UIRectEdge(edges))
  }
  
  func pinEdgesToParent(including edges: UIRectEdge = [.left, .right, .top, .bottom]) {
    guard let superview = superview else {
      print("pinEdgesToParent failed - no superview!")
      return
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    
    var constraints: [NSLayoutConstraint] = []
    if edges.contains(.left) {
      constraints.append(leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor))
    }
    
    if edges.contains(.right) {
      constraints.append(rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor))
    }
    
    if edges.contains(.top) {
      constraints.append(topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor))
    }
    
    if edges.contains(.bottom) {
      constraints.append(bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor))
    }
    
    NSLayoutConstraint.activate(constraints)
  }
}
