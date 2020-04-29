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
  func gifSearchInteractorDidResetImages(_ interactor: GIFSearchInteractor)
  func gifSearchInteractor(
    _ interactor: GIFSearchInteractor,
    didInsertImagesAtIndices indices: [Int]
  )

  func gifSearchInteractor(
    _ interactor: GIFSearchInteractor,
    displayActionSheetWithOptions options: [ActionOption],
    forImageAtIndex index: Int
  )
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
  
  func reset() {
    images = []
  }
  
  func fetchGIFs(with query: String) {
    images = []
    loadGIFs(with: query, offset: 0)
  }
  
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
  
  func gifSelected(at index: Int) {
    delegate?.gifSearchInteractor(
      self,
      displayActionSheetWithOptions: ActionOption.allCases,
      forImageAtIndex: index
    )
  }
  
  func actionOptionSelected(_ actionOption: ActionOption, withImageData imageData: Data) {
    switch actionOption {
    case .saveToPhotos:
      photoLibraryClient.saveGIFImageDataToPhotoLibrary(imageData)
    case .copyToClipboard:
      clipboardClient.saveGIFDataToClipboard(imageData)
    case .share:
      delegate?.gifSearchInteractor(self, shareGIFWithData: imageData)
    default:
      print("selected \(actionOption)")
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
