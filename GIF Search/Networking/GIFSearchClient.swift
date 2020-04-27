//
//  GIFSearchClient.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

protocol GIFSearchClient {
  func fetchGIFImages(with query: String, callback: @escaping ((Result<[GIFImage], Error>) -> Void))
}

