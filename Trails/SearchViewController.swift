//
//  SearchViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 4/3/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var collectionLabels = [String]()
    var searchValues = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - bottomsheet properties
    
    var searchController = UISearchController(searchResultsController: nil)
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    let fullView: CGFloat = 100
    var halfView: CGFloat = 275
    var hasKeyBoard: Bool = false
    var bottomView: CGFloat {
        return UIScreen.main.bounds.height - 64
    }
    
    
    //MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gesture()
        setupTableView()
        setupCollectionView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
    
    func dismissKeyBoard() {
        if hasKeyBoard == true {
            searchBar.endEditing(true)
            hasKeyBoard = false
        }
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
        if hasKeyBoard == true {
            searchBar.endEditing(true)
            hasKeyBoard = false
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let width = self.view.frame.width
        let height = self.view.frame.height
        searchBar.showsCancelButton = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.fullView, width: width, height: height)
        })
        hasKeyBoard = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        searchBar.showsCancelButton = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
        })
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        guard let mapViews = mapView,
            let searchBarText = searchBar.text
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return addressLine
    }
    
    
    
    //MARK: - UITableViewDataSource
    
    func setupTableView() {
        
        tableView.backgroundView?.isOpaque = true
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasKeyBoard == true {
            searchBar.endEditing(true)
            hasKeyBoard = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        searchCell.textLabel?.text = selectedItem.name
        searchCell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        searchCell.backgroundView?.isOpaque = true
        
        return searchCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
        })
        dismiss(animated: true, completion: nil)
        if hasKeyBoard == true {
            searchBar.endEditing(true)
            hasKeyBoard = false
        }
    }
    
    //MARK: - collectionview dataSource
    
    func setupCollectionView() {
        
        collectionLabels = ["Theater", "Music", "Dance", "Arts", "Film", "Festivals", "Family", "Free", "Sports", "Outdoors"]
        searchValues = ["comedy&&performing_arts", "music&&performing_arts", "singles_social", "art&&attractions&&books", "movies_film", "music-festivals", "family_fun_kids", "free", "sports", "outdoors_recreation"]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath)
        
        let button = cell.viewWithTag(1) as? UILabel
        button?.text = collectionLabels[indexPath.row]
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    
        let width = self.view.frame.width
        let height = self.view.frame.height
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
            self.searchBar.endEditing(true)
        })
        
        
        
        // calculation to find the current width of map in miles at the time that the user searches a catagory
        
        let mRect: MKMapRect = mapView!.visibleMapRect
        let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
        let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
        let currentDistWideInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
        let milesWide = currentDistWideInMeters / 1609.34  // number of meters in a mile
        
        let distance = "\(milesWide + 10)"
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            guard let location = LocationManager.shared.cityName
                else { return self.noLocation()}
            EventController.fetchEvent(category: self.searchValues[indexPath.row], userLocation: location, distance: distance, completion: { events in
                
                if events.count == 0 {
                    self.noEventsAlert()
                }
           self.handleMapSearchDelegate?.dropPinZoomIn(events)
            })
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func noEventsAlert() {
        let alertController = UIAlertController(title: "No Events", message: "There are no events for that category today in your area.\nTry expaning or map, searching again tomorrow or search a new event category.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertController.addAction(dismiss)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func noLocation(){
        let alertController = UIAlertController(title: "Still finding you", message: "Give it a second, your location is connecting with the events in your area.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertController.addAction(dismiss)
        
        present(alertController, animated: true, completion: nil)
    }
}



