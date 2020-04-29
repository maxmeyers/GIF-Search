//
//  DeviceClipboardClient.swift
//  GIF Search
//
//  Created by Max on 4/28/20.
//  Copyright © 2020 Max. All rights reserved.
//

import Foundation
import UIKit

struct DeviceClipboardClient: ClipboardClient {
  func saveGIFDataToClipboard(_ data: Data) {
    UIPasteboard.general.setData(data, forPasteboardType: "com.compuserve.gif")
  }
}
