//
//  GiphyGIFSearchClient.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

private enum GiphyResponseError: Error {
  case invalidResponse
}

private struct GiphySearchResponse: Decodable {
  let data: [GiphyGIF]
  let pagination: GiphyPagination
}

private struct GiphyGIF: Decodable {
  let url: String
  let images: GiphyGIFImages
}

private struct GiphyPagination: Decodable {
  let offset: Int
  let total_count: Int
  let count: Int
}

private struct GiphyGIFImages: Decodable {
  let fixed_width: GiphyGIFImage
}

private struct GiphyGIFImage: Decodable {
  let url: String
  let width: String
  let height: String
  
  var size: (width: Int, height: Int)? {
    guard let width = Int(self.width), let height = Int(self.height) else {
      return nil
    }
    return (width: width, height: height)
  }
}

class GiphyGIFSearchClient: GIFSearchClient {
  private static let searchURLString = "https://api.giphy.com/v1/gifs/search"
  
  private let apiKey: String
  private let jsonDecoder = JSONDecoder()
  
  init(apiKey: String) {
    self.apiKey = apiKey;
  }
  
  func fetchGIFImages(
    with query: String,
    limit: UInt,
    offset: UInt,
    callback: @escaping ((Result<([GIFImage], Pagination), Error>) -> Void)
  ) {
    var urlComponents = URLComponents(string: GiphyGIFSearchClient.searchURLString)!
    urlComponents.queryItems = [
      "api_key": apiKey,
      "q": query,
      "limit": "\(limit)",
      "offset": "\(offset)",
      ].map { URLQueryItem(name: $0.key, value: $0.value) }
    
    let task = URLSession.shared.dataTask(
      with: URLRequest(url: urlComponents.url!)
    ) { (data, response, error) in
      if let error = error {
        callback(.failure(error))
        return
      }
      
      guard
        let data = data,
        let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200 else {
          callback(.failure(GiphyResponseError.invalidResponse))
          return
      }
      
      do {
        let decodedResponse = try self.jsonDecoder.decode(GiphySearchResponse.self, from: data)
        let images: [GIFImage] = decodedResponse.data.compactMap { (giphyImage: GiphyGIF) in
          let image = giphyImage.images.fixed_width
          guard let url = URL(string: image.url), let size = image.size else {
            return nil
          }
          
          return GIFImage(url: url, size: size)
        }
        let giphyPagination = decodedResponse.pagination
        let pagination = Pagination(
          offset: giphyPagination.offset,
          totalCount: giphyPagination.total_count,
          count: giphyPagination.count
        )
        callback(.success((images, pagination)))
      } catch let jsonError {
        callback(.failure(jsonError))
      }
    }
    task.resume()
  }
}
