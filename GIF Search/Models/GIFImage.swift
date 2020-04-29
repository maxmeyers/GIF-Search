//
//  GIFImage.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

/// An individual GIF Image
struct GIFImage {
  
  /// The URL of the GIF.
  let url: URL
  
  /// The pixel dimensions of the GIF.
  let size: (width: Int, height: Int)
}
