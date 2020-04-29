//
//  Pagination.swift
//  GIF Search
//
//  Created by Max on 4/28/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

/// Indicates the pagination paraemters for a paginated resource request.
struct Pagination {
  /// The offset of the request.
  let offset: Int
  
  /// How many total resources are available for this request.
  let totalCount: Int
  
  /// How many resources are included in the associated response.
  let count: Int
}
