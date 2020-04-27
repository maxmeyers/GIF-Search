//
//  GIFSearchViewController.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

class GIFSearchViewController: UIViewController {
  private let interactor = GIFSearchInteractor(gifSearchClient: GiphyGIFSearchClient())
  private let gifSearchView = GIFSearchView()
    
  override func loadView() {
    view = gifSearchView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gifSearchView.dataSource = self
    gifSearchView.reloadData()
    
    interactor.fetchGIFs(with: "trains") { [weak self] _ in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.gifSearchView.reloadData()
      }
    }
  }
}

extension GIFSearchViewController: GIFSearchViewDataSource {
  func gifSearchViewNumberOfImages(_ gifSearchView: GIFSearchView) -> Int {
    return interactor.images.count
  }
  
  func gifSearchView(_ gifSearchView: GIFSearchView, imageAtIndex index: Int) -> GIFImage {
    return interactor.images[index]
  }
}
