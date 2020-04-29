//
//  GIFImageCollectionViewCell.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import SwiftyGif
import UIKit

class GIFImageCollectionViewCell: UICollectionViewCell {
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 4
    imageView.layer.masksToBounds = true
    return imageView
  }()
  private var imageDownloadTask: URLSessionDataTask?
  
  var imageURL: URL? {
    didSet {
      if let imageURL = imageURL {
        imageDownloadTask = imageView.setGifFromURL(imageURL)
      } else {
        imageDownloadTask?.cancel()
        imageDownloadTask = nil
        imageView.image = nil
      }
    }
  }
  
  var imageData: Data? {
    get {
      return imageView.gifImage?.imageData
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .systemBackground
    
    addSubview(imageView)
    imageView.pinEdgesToParent()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    imageURL = nil
  }
}
