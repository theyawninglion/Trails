//
//  BottomSheetViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 4/3/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

class BottomSheetViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    static let shared = BottomSheetViewController()
    
    @IBOutlet weak var tableView: UITableView!
    //MARK: - locationSearch properties
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    
    //MARK: - bottomsheet properties
    
    let fullView: CGFloat = 100
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 108
    }

    
    //MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
        view.addGestureRecognizer(gesture)

        configureSearchController()
        setupTableView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let frame = self?.view.frame,
                let yComponent = self?.partialView
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
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        let width = self.view.frame.width
        let height = self.view.frame.height
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        
        
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: width, height: height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        if recognizer.state == .ended {
            var duration = velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y)
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: width, height: height)
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
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0 ) || (y == partialView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        return false
    }
    
    //MARK: - tableView
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
            }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "bottomSheetCell", for: indexPath)
//        
//        return cell
//    }
    
    func configureSearchController() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let locationSearchTable = storyboard.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchTable else { return }
        
        
        let searchBar = resultSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.delegate = self
        searchBar.isTranslucent = true
        
        tableView.tableHeaderView = searchBar
        

//        resultSearchController.searchResultsUpdater = locationSearchTable
        
        resultSearchController.searchResultsUpdater = self
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        
        handleMapSearchDelegate = TrailsMainViewController.shared
    }
    
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    
    
    func updateSearchResults(for resultSearchController: UISearchController) {
        
        guard let mapViews = mapView,
            let searchBarText = resultSearchController.searchBar.text
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bottomSheetCell", for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismiss(animated: true, completion: nil)
    }

    
}



