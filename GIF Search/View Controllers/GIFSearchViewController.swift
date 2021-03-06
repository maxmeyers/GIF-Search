//
//  GIFSearchViewController.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

class GIFSearchViewController: UIViewController {
  private let interactor: GIFSearchInteractor
  private let gifSearchView = GIFSearchView()
  private var searchDebounceTimer: Timer?
  
  required init?(coder: NSCoder) {
    guard
      let apiKey = Bundle.main.object(forInfoDictionaryKey: "GiphyAPIKey") as? String,
      apiKey.count > 0
      else {
        fatalError("GiphyAPIKey must be set in Info.plist")
    }
    
    interactor = GIFSearchInteractor(
      gifSearchClient: GiphyGIFSearchClient(apiKey: apiKey),
      photoLibraryClient: DevicePhotoLibraryClient(),
      clipboardClient: DeviceClipboardClient()
    )
    super.init(coder: coder)
  }
  
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
  func gifSearchInteractorDidResetImages(_ interactor: GIFSearchInteractor) {
    DispatchQueue.main.async {
      self.gifSearchView.reloadData()
    }
  }
  
  func gifSearchInteractor(
    _ interactor: GIFSearchInteractor,
    didInsertImagesAtIndices indices: [Int]
  ) {
    DispatchQueue.main.async {
      self.gifSearchView.insertItems(at: indices)
    }
  }
  
  func gifSearchInteractor(
    _ interactor: GIFSearchInteractor,
    displayActionSheetWithOptions options: [ActionOption],
    forImageAtIndex index: Int
  ) {
    guard let sourceView = gifSearchView.viewForImageAtIndex(index) else { return }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.popoverPresentationController?.sourceView = sourceView
    
    for option in options {
      alertController.addAction(
        UIAlertAction(title: option.title, style: .default, handler: { [weak self] _ in
          guard
            let self = self,
            let imageData = self.gifSearchView.imageDataAtIndex(index)
            else { return }
          self.interactor.actionOptionSelected(option, withImageData: imageData)
        })
      )
    }
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alertController, animated: true)
  }
  
  func gifSearchInteractor(_ interactor: GIFSearchInteractor, shareGIFWithData data: Data) {
    let activityViewController = UIActivityViewController(
      activityItems: [data],
      applicationActivities: nil
    )
    present(activityViewController, animated: true)
  }
}

extension GIFSearchViewController: GIFSearchViewDelegate {
  func gifSearchView(_ gifSearchView: GIFSearchView, didUpdateQuery query: String?) {
    searchDebounceTimer?.invalidate()
    
    guard let query = query, query.count > 0 else {
      interactor.reset()
      return
    }
    
    searchDebounceTimer = Timer.scheduledTimer(
      withTimeInterval: 1,
      repeats: false,
      block: { [weak self] _ in
        guard let self = self else { return }
        self.interactor.fetchGIFs(with: query)
    })
  }
  
  func gifSearchView(_ gifSearchView: GIFSearchView, didSearchWithQuery query: String?) {
    searchDebounceTimer?.invalidate()
    
    guard let query = query else {
      interactor.reset()
      return
    }
    interactor.fetchGIFs(with: query)
  }
  
  func gifSearchView(_ gifSearchView: GIFSearchView, didSelectImageAtIndex index: Int) {
    interactor.gifSelected(at: index)
  }
  
  func gifSearchViewDidDisplayEndOfList(_ gifSearchView: GIFSearchView) {
    interactor.fetchMoreGIFsIfNecessary()
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
    }
  }
}
