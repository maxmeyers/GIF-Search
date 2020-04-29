//
//  GIFSearchClient.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

/// An interface for searching for GIFs.
protocol GIFSearchClient {
  /// Retrieves a paginated list of GIFs with a query.
  /// - Parameters:
  ///   - query: the search query for the GIF results
  ///   - limit: the number of results to return
  ///   - offset: the offset to use for pagination
  ///   - callback: a function to be called with the response or error
  func fetchGIFImages(
    with query: String,
    limit: UInt,
    offset: UInt,
    callback: @escaping ((Result<([GIFImage], Pagination), Error>) -> Void)
  )
}

