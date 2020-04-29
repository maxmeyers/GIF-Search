//
//  DevicePhotoLibraryClient.swift
//  GIF Search
//
//  Created by Max on 4/28/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation
import Photos

struct DevicePhotoLibraryClient: PhotoLibraryClient {
  func saveGIFImageDataToPhotoLibrary(_ data: Data) {
    try? PHPhotoLibrary.shared().performChangesAndWait {
      PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
    }
  }
}
