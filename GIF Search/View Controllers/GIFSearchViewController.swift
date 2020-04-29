//
//  GIFSearchViewController.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

class GIFSearchViewController: UIViewController {
  private let interactor = GIFSearchInteractor(
    gifSearchClient: GiphyGIFSearchClient(),
    photoLibraryClient: DevicePhotoLibraryClient(),
    clipboardClient: DeviceClipboardClient()
  )
  private let gifSearchView = GIFSearchView()
    
  override func loadView() {
    view = gifSearchView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    interactor.delegate = self
    
    gifSearchView.delegate = self
    gifSearchView.dataSource = self
    gifSearchView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    gifSearchView.activateSearchField()
  }
}

extension GIFSearchViewController: GIFSearchInteractorDelegate {
  func gifSearchInteractorDidUpdateImages(_ interactor: GIFSearchInteractor) {
    DispatchQueue.main.async {
      self.gifSearchView.reloadData()
    }
  }
  
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, failedLoadingImagesWithError error: Error) {
    // TODO: Show an error
    DispatchQueue.main.async {
      self.gifSearchView.reloadData()
    }
  }
  
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, displayActionSheetWithOptions options: [ActionOption], forImageAtIndex index: Int) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    for option in options {
      alertController.addAction(UIAlertAction(title: option.title, style: .default, handler: { [weak self] _ in
        guard let self = self, let imageData = self.gifSearchView.imageDataAtIndex(index) else { return }
        self.interactor.actionOptionSelected(option, withImageData: imageData)
      }))
    }
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alertController, animated: true)
  }
  
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, shareGIFWithData data: Data) {
    let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
    present(activityViewController, animated: true)
  }
}

extension GIFSearchViewController: GIFSearchViewDelegate {
  func gifSearchView(_ gifSearchView: GIFSearchView, didUpdateQuery query: String?) {
    interactor.reset()
  }

  func gifSearchView(_ gifSearchView: GIFSearchView, didSearchWithQuery query: String?) {
    guard let query = query else {
      interactor.reset()
      return
    }
    interactor.fetchGIFs(with: query)
  }

  func gifSearchView(_ gifSearchView: GIFSearchView, didSelectImageAtIndex index: Int) {
    interactor.gifSelected(at: index)
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

fileprivate extension ActionOption {
  var title: String {
    switch self {
    case .saveToPhotos:
      return "Save to Photos"
    case .copyToClipboard:
      return "Copy"
    case .share:
      return "Share"
    case .showFullscreen:
      return "Show Fullscreen"
    }
  }
}
