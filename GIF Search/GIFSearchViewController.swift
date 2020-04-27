//
//  GIFSearchViewController.swift
//  GIF Search
//
//  Created by Max on 4/26/20.
//  Copyright © 2020 Max. All rights reserved.
//

import UIKit

class GIFSearchViewController: UIViewController {

    private let gifSearchView = GIFSearchView()
    
    override func loadView() {
        view = gifSearchView
    }
}
