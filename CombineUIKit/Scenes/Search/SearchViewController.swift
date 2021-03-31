//
//  SearchViewController.swift
//  CombineUIKit
//
//  Created by Greg Price on 30/03/2021.
//

import UIKit
import Combine
import CombineCocoa
import CombineDataSources

final class SearchViewController: UIViewController {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = SearchViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        viewModel.bind(searchQuery: searchBar.textDidChangePublisher)
        
        viewModel.$photos
            .bind(subscriber: collectionView.itemsSubscriber(cellIdentifier: "Cell", cellType: PhotoCell.self, cellConfig: { cell, _, photo in
                cell.bind(photo)
              }))
              .store(in: &subscriptions)
        
        viewModel.$searching
            .sink { [weak activityView] searching in
                searching ? activityView?.startAnimating() : activityView?.stopAnimating()
            }
            .store(in: &subscriptions)
        
        searchBar.searchButtonClickedPublisher
            .sink { [weak searchBar] in
                searchBar?.resignFirstResponder()
            }
            .store(in: &subscriptions)
    }
}
