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
  private var searchDebounceTimer: Timer?
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateColumnCount(withSize: view.bounds.size)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    gifSearchView.activateSearchField()
  }
  
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    updateColumnCount(withSize: size)
  }
  
  private func updateColumnCount(withSize size: CGSize) {
    guard size.width > 0 else { return }
    gifSearchView.numberOfColumns = Int(round(size.width / 200))
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
    guard let sourceView = gifSearchView.viewForImageAtIndex(index) else { return }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.popoverPresentationController?.sourceView = sourceView

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
    searchDebounceTimer?.invalidate()
    searchDebounceTimer = nil

    if let query = query {
      searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] _ in
        guard let self = self else { return }
        self.interactor.fetchGIFs(with: query)
      })
    }
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
