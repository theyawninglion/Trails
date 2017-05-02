//
//  SearchCollectionTableViewCell.swift
//  Trails
//
//  Created by Taylor Phillips on 5/1/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit

class MainCollectionTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionLabels = [String]()
    
    func setupCollectionView() {
        
        collectionLabels = ["Theater", "Music", "Dance", "Art", "Film", "Festivals", "Family", "Free", "Sports"]
    }
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return collectionLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath)
        
        let label = cell.viewWithTag(1) as? UILabel
        label?.text = collectionLabels[indexPath.row]
        
        return cell
    }


}
