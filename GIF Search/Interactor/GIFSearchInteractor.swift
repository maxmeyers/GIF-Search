//
//  GIFSearchInteractor.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation
import UIKit

protocol GIFSearchInteractorDelegate: AnyObject {
  /// Called when the interactor has reset all the images.
  
  func gifSearchInteractorDidResetImages(_ interactor: GIFSearchInteractor)
  
  /// Called when the interactor as inserted new images.
  
  func gifSearchInteractor(
    _ interactor: GIFSearchInteractor,
    didInsertImagesAtIndices indices: [Int]
  )
  
  /// Called when the interactor wants the delegate to display an action sheet with various options.
  
  func gifSearchInteractor(
    _ interactor: GIFSearchInteractor,
    displayActionSheetWithOptions options: [ActionOption],
    forImageAtIndex index: Int
  )
  
  /// Called when the interactor wnats the delegate to open a share sheet.
  
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, shareGIFWithData data: Data)
}

class GIFSearchInteractor {
  weak var delegate: GIFSearchInteractorDelegate?
  
  private let gifSearchClient: GIFSearchClient
  private let photoLibraryClient: PhotoLibraryClient
  private let clipboardClient: ClipboardClient
  
  private(set) var images: [GIFImage] = [] {
    didSet {
      if images.isEmpty {
        self.delegate?.gifSearchInteractorDidResetImages(self)
      }
    }
  }
  
  private var currentResult: (query: String, pagination: Pagination)?
  
  init(
    gifSearchClient: GIFSearchClient,
    photoLibraryClient: PhotoLibraryClient,
    clipboardClient: ClipboardClient
  ) {
    self.gifSearchClient = gifSearchClient
    self.photoLibraryClient = photoLibraryClient
    self.clipboardClient = clipboardClient
  }
  
  /// Remove any existing images.
  func reset() {
    images = []
    currentResult = nil
  }
  
  /// Start a new GIF search with the given query string.
  func fetchGIFs(with query: String) {
    images = []
    loadGIFs(with: query, offset: 0)
  }
  
  /// Continue the previous GIF search if there are more GIFs to be fetched.
  func fetchMoreGIFsIfNecessary() {
    guard let currentResult = currentResult else {
      return
    }
    
    let newOffset = currentResult.pagination.offset + currentResult.pagination.count
    if newOffset < currentResult.pagination.totalCount {
      loadGIFs(with: currentResult.query, offset: newOffset)
    } else {
      print("Reached end of GIFs for \(currentResult.query)")
    }
  }
  
  /// Should be called when the user has selected a particular image.
  func gifSelected(at index: Int) {
    delegate?.gifSearchInteractor(
      self,
      displayActionSheetWithOptions: ActionOption.allCases,
      forImageAtIndex: index
    )
  }
  
  /// Should be called when the user has selected a particular action from an action sheet.
  func actionOptionSelected(_ actionOption: ActionOption, withImageData imageData: Data) {
    switch actionOption {
    case .saveToPhotos:
      photoLibraryClient.saveGIFImageDataToPhotoLibrary(imageData)
    case .copyToClipboard:
      clipboardClient.saveGIFDataToClipboard(imageData)
    case .share:
      delegate?.gifSearchInteractor(self, shareGIFWithData: imageData)
    }
  }
  
  private func loadGIFs(with query: String, offset: Int) {
    gifSearchClient.fetchGIFImages(
      with: query,
      limit: 25,
      offset: UInt(offset)
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success((let images, let pagination)):
        let previousLength = self.images.count
        self.images.append(contentsOf: images)
        self.currentResult = (query, pagination)
        
        let range = Array(previousLength..<self.images.count)
        self.delegate?.gifSearchInteractor(self, didInsertImagesAtIndices: range)
      case .failure(let error):
        print("Error loading images: \(error.localizedDescription)")
      }
    }
  }
}
