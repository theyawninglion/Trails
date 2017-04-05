//
//  BottomSheetViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 4/3/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

class BottomSheetViewController: UIViewController, UIGestureRecognizerDelegate {
    
    static let shared = BottomSheetViewController()
    
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
        
        searchBarView()
//        setupTableView()
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
                    //                    self?.tableView.isScrollEnabled = true
                }
                
                
            })
        }
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        //        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0 ) || (y == partialView) {
        //            tableView.isScrollEnabled = false
        //        } else {
        //            tableView.isScrollEnabled = true
        //        }
        return false
    }
    
    //MARK: - tableView
    //    func setupTableView() {
    //        tableView.delegate = self
    //        tableView.dataSource = self
    //
    //        self.view.addSubview(tableView)
    //
    //        tableView.translatesAutoresizingMaskIntoConstraints = false
    //
    //        let tableViewConstraints = [
    //
    //            tableView.topAnchor.constraint(equalTo: view.topAnchor),
    //            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    //            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
    //            tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
    //        ]
    //        self.view.addConstraints(tableViewConstraints)
    //    }
    
    
    
    
    
    func searchBarView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let locationSearchTable = storyboard.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchTable else { return }
        
        locationSearchTable.mapView = TrailsMainViewController.shared.mapView
        locationSearchTable.handleMapSearchDelegate = TrailsMainViewController.shared
        
        let searchBar = resultSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController.searchBar
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
    }
    
    
    
    
}



