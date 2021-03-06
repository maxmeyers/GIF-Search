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
  /// Returns the number of images to be displayed in the `GIFSearchView`.
  func gifSearchViewNumberOfImages(_ gifSearchView: GIFSearchView) -> Int
  
  /// Returns the image to be displayed at the specified index.
  func gifSearchView(_ gifSearchView: GIFSearchView, imageAtIndex index: Int) -> GIFImage
}

protocol GIFSearchViewDelegate: AnyObject {
  /// Called when the view's query input has been updated.
  func gifSearchView(_ gifSearchView: GIFSearchView, didUpdateQuery query: String?)
  
  /// Called when the view's search button has been pressed.
  func gifSearchView(_ gifSearchView: GIFSearchView, didSearchWithQuery query: String?)
  
  /// Called when an image in the view has been selected.
  func gifSearchView(_ gifSearchView: GIFSearchView, didSelectImageAtIndex index: Int)
  
  /// Called when the last image in the list has been displayed.
  func gifSearchViewDidDisplayEndOfList(_ gifSearchView: GIFSearchView)
}

class GIFSearchView: UIView {
  weak var dataSource: GIFSearchViewDataSource?
  weak var delegate: GIFSearchViewDelegate?
  
  var numberOfColumns: Int = 2 {
    didSet {
      layout.columnCount = numberOfColumns
    }
  }
  
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
    
    backgroundColor = .systemBackground
    configureSearchBar()
    configureCollectionView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Makes the view's search bar active.
  func activateSearchField() {
    searchBar.becomeFirstResponder()
  }
  
  /// Reloads the images from the view's `dataSource`.
  func reloadData() {
    collectionView.reloadData()
  }
  
  /// Loads new images at the specified indices.
  func insertItems(at indices: [Int]) {
    collectionView.insertItems(at: indices.map { IndexPath(item: $0, section: 0) })
  }
  
  /// Returns the image data from the specified index, if it is present.
  func imageDataAtIndex(_ index: Int) -> Data? {
    guard
      let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0))
        as? GIFImageCollectionViewCell else {
          return nil
    }
    return cell.imageData
  }
  
  /// Returns the view for the image at the specified index.
  func viewForImageAtIndex(_ index: Int) -> UIView? {
    return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
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
    
    collectionView.backgroundColor = .systemBackground
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
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return dataSource?.gifSearchViewNumberOfImages(self) ?? 0
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
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
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    guard let image = dataSource?.gifSearchView(self, imageAtIndex: indexPath.item) else {
      return .zero
    }
    
    return CGSize(width: image.size.width, height: image.size.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.gifSearchView(self, didSelectImageAtIndex: indexPath.item)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    if collectionView.numberOfItems(inSection: 0) - 1 == indexPath.item {
      delegate?.gifSearchViewDidDisplayEndOfList(self)
    }
  }
}
