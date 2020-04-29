//
//  ClipboardClient.swift
//  GIF Search
//
//  Created by Max on 4/28/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation

protocol ClipboardClient {
  func saveGIFDataToClipboard(_ data: Data)
}
