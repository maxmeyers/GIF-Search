//
//  ActionSheetOption.swift
//  GIF Search
//
//  Created by Max on 4/28/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

/// Actions that can be taken on an image
enum ActionOption: CaseIterable {
  /// Saves the image to a photo library.
  case saveToPhotos
  
  /// Copies the image to the clipboard.
  case copyToClipboard
  
  /// Shares the image using the system share sheet.
  case share
}
