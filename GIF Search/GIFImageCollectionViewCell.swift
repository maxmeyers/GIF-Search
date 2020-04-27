//
//  GIFImageCollectionViewCell.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

class GIFImageCollectionViewCell: UICollectionViewCell {
  let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 24)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 1
    
    addSubview(titleLabel)
    titleLabel.centerInParent()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
