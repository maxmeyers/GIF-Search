//
//  GIFSearchInteractor.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

class GIFSearchInteractor {
  var updateBlock: ((Error?) -> Void)?
  
  private let gifSearchClient: GIFSearchClient
  
  private(set) var images: [GIFImage] = []
  
  init(gifSearchClient: GIFSearchClient) {
    self.gifSearchClient = gifSearchClient
  }
  
  func reset() {
    self.images = []
    self.updateBlock?(nil)
  }
  
  func fetchGIFs(with query: String) {
    gifSearchClient.fetchGIFImages(with: query, limit: 100) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let images):
        self.images = images
        self.updateBlock?(nil)
      case .failure(let error):
        self.updateBlock?(error)
      }
    }
  }
}
