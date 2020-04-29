//
//  GIFSearchView.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import UIKit

protocol GIFSearchViewDataSource: AnyObject {
  func gifSearchViewNumberOfImages(_ gifSearchView: GIFSearchView) -> Int
  func gifSearchView(_ gifSearchView: GIFSearchView, imageAtIndex index: Int) -> GIFImage
}

protocol GIFSearchViewDelegate: AnyObject {
  func gifSearchView(_ gifSearchView: GIFSearchView, didUpdateQuery query: String?)
  func gifSearchView(_ gifSearchView: GIFSearchView, didSearchWithQuery query: String?)
}

class GIFSearchView: UIView {
  weak var dataSource: GIFSearchViewDataSource?
  weak var delegate: GIFSearchViewDelegate?
  
  private static let ImageCellReuseIdentifier = "ImageCell"

  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search GIFs (via GIPHY)"
    return searchBar
  }()
  
  private let layout = CHTCollectionViewWaterfallLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
  
  init() {
    super.init(frame: .zero)
    
    backgroundColor = .white
    configureSearchBar()
    configureCollectionView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func activateSearchField() {
    searchBar.becomeFirstResponder()
  }
  
  func reloadData() {
    collectionView.reloadData()
  }
  
  private func configureSearchBar() {
    addSubview(searchBar)
    searchBar.pinEdgesToParent(excluding: .bottom)
    
    searchBar.delegate = self
    searchBar.searchTextField.delegate = self
  }
  
  private func configureCollectionView() {
    addSubview(collectionView)
    collectionView.pinEdgesToParent(excluding: .top)
    collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true

    collectionView.backgroundColor = .white
    collectionView.register(
      GIFImageCollectionViewCell.self,
      forCellWithReuseIdentifier: GIFSearchView.ImageCellReuseIdentifier
    )
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    collectionView.keyboardDismissMode = .onDrag
  }
}

extension GIFSearchView: UISearchBarDelegate, UITextFieldDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    delegate?.gifSearchView(self, didUpdateQuery: searchText)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    delegate?.gifSearchView(self, didSearchWithQuery: textField.text)
    textField.resignFirstResponder()
    return true
  }
}

extension GIFSearchView: UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
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
    guard let image = dataSource?.gifSearchView(self, imageAtIndex: indexPath.item) else {
      return .zero
    }

    return CGSize(width: image.size.width, height: image.size.height)
  }
}
