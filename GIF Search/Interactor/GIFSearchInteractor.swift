//
//  GIFSearchInteractor.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

class GIFSearchInteractor {
  private let gifSearchClient: GIFSearchClient
  
  private(set) var images: [GIFImage] = []
  
  init(gifSearchClient: GIFSearchClient) {
    self.gifSearchClient = gifSearchClient
  }
  
  func fetchGIFs(with query: String, callback: @escaping ((Result<Void, Error>) -> Void)) {
    gifSearchClient.fetchGIFImages(with: query, limit: 100) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let images):
        self.images = images
        callback(.success(Void()))
      case .failure(let error):
        callback(.failure(error))
      }
    }
  }
}
