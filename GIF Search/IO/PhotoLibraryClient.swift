//
//  PhotoLibraryClient.swift
//  GIF Search
//
//  Created by Max on 4/28/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

protocol PhotoLibraryClient {
  func saveGIFImageDataToPhotoLibrary(_ data: Data)
}
