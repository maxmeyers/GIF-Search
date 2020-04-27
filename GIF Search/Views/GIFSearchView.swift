//
//  GIFSearchView.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

protocol GIFSearchViewDataSource: AnyObject {
  func gifSearchViewNumberOfImages(_ gifSearchView: GIFSearchView) -> Int
  func gifSearchView(_ gifSearchView: GIFSearchView, imageAtIndex index: Int) -> GIFImage
}

class GIFSearchView: UIView {
  weak var dataSource: GIFSearchViewDataSource?
  
  private static let ImageCellReuseIdentifier = "ImageCell"

  private let layout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
  
  init() {
    super.init(frame: .zero)
    
    backgroundColor = .white
    configureCollectionView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func reloadData() {
    collectionView.reloadData()
  }
  
  private func configureCollectionView() {
    collectionView.backgroundColor = .white
    collectionView.register(
      GIFImageCollectionViewCell.self,
      forCellWithReuseIdentifier: GIFSearchView.ImageCellReuseIdentifier
    )
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    addSubview(collectionView)
    collectionView.pinEdgesToParent()
  }
}

extension GIFSearchView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource?.gifSearchViewNumberOfImages(self) ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: GIFSearchView.ImageCellReuseIdentifier,
      for: indexPath
    ) as! GIFImageCollectionViewCell
    
    guard let image = dataSource?.gifSearchView(self, imageAtIndex: indexPath.item) else {
      return cell
    }

    cell.imageURL = image.url
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
    return CGSize(width: itemSize, height: itemSize)
  }
}
