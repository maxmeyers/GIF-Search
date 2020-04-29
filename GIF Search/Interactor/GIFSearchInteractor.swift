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
  func gifSearchInteractorDidUpdateImages(_ interactor: GIFSearchInteractor)
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, failedLoadingImagesWithError error: Error)
  
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, displayActionSheetWithOptions options: [ActionOption], forImageAtIndex index: Int)
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, shareGIFWithData data: Data)
}

class GIFSearchInteractor {
  weak var delegate: GIFSearchInteractorDelegate?
  
  private let gifSearchClient: GIFSearchClient
  private let photoLibraryClient: PhotoLibraryClient
  private let clipboardClient: ClipboardClient
  
  private(set) var images: [GIFImage] = [] {
    didSet {
      self.delegate?.gifSearchInteractorDidUpdateImages(self)
    }
  }
  
  init(gifSearchClient: GIFSearchClient, photoLibraryClient: PhotoLibraryClient, clipboardClient: ClipboardClient) {
    self.gifSearchClient = gifSearchClient
    self.photoLibraryClient = photoLibraryClient
    self.clipboardClient = clipboardClient
  }
  
  func reset() {
    images = []
  }
  
  func fetchGIFs(with query: String) {
    gifSearchClient.fetchGIFImages(with: query, limit: 100) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let images):
        self.images = images
      case .failure(let error):
        self.delegate?.gifSearchInteractor(self, failedLoadingImagesWithError: error)
      }
    }
  }
  
  func gifSelected(at index: Int) {
    delegate?.gifSearchInteractor(self, displayActionSheetWithOptions: ActionOption.allCases, forImageAtIndex: index)
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
  
}
