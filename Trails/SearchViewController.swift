//
//  SearchViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 4/3/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UITableViewController, UIGestureRecognizerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate {
    
    static let shared = SearchViewController()
    
    var collectionLabels = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - bottomsheet properties
    
    var searchController = UISearchController(searchResultsController: nil)
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    let fullView: CGFloat = 100
    var bottomView: CGFloat {
        return UIScreen.main.bounds.height - 108
    }
    
    
    //MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gesture()
        configureSearchController()
        setupTableView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let frame = self?.view.frame,
                let yComponent = self?.bottomView
                else { return }
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height - 100)
        }
    }
    
    func prepareBackgroundView() {
        
        let blurEffect = UIBlurEffect.init(style: .regular)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    //MARK: -  gesture recognizer
    
    func gesture() {
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(SearchViewController.panGesture))
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if (y + translation.y >= fullView) && (y + translation.y <= bottomView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: width, height: height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        if recognizer.state == .ended {
            var duration = velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((bottomView - y) / velocity.y)
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: width, height: height)
                }
            }, completion: { [weak self] _ in
                if velocity.y < 0 {
                    self?.tableView.isScrollEnabled = true
                }
            })
        }
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        let direction = gesture.velocity(in: view).y
        let y = view.frame.minY
        
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0 ) || (y == bottomView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        return false
    }
    
    //MARK: - SearchController
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.fullView, width: width, height: height)
        })
//        let collectionView = UIView.insertSubview
//        collectionView.view.frame.height = 99
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
        })
    }
    
    func configureSearchController() {
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.delegate = self
        searchBar.isTranslucent = true
        
        tableView.tableHeaderView = searchBar
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let mapViews = mapView,
            let searchBarText = searchController.searchBar.text
            else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapViews.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(format: "%@%@%@%@%@%@%@",
                                 selectedItem.subThoroughfare ?? "",
                                 firstSpace,
                                 selectedItem.thoroughfare ?? "",
                                 comma,
                                 selectedItem.locality ?? "",
                                 secondSpace,
                                 selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    
    
    //MARK: - UITableViewDataSource
    
    func setupTableView() {
        
        tableView.backgroundView?.isOpaque = true
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
            let selectedItem = matchingItems[indexPath.row].placemark
            searchCell.textLabel?.text = selectedItem.name
            searchCell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
            searchCell.backgroundView?.isOpaque = true
        
            return searchCell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
        })
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - collectionview dataSource
    
    func setupCollectionView() {
        
        collectionLabels = ["Theater", "Music", "Dance", "Art", "Film", "Festivals", "Family", "Free", "Sports"]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return collectionLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath)
        
        let button = cell.viewWithTag(1) as? UIButton
        button?.setTitle( collectionLabels[indexPath.row], for: UIControlState.normal)
        
        return cell
    }
    
}



