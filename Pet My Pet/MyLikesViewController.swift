//
//  MyLikesViewController.swift
//  Pet My Pet
//
//  Created by Shivam Maggu on 11/02/19.
//  Copyright © 2019 Shivam Maggu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher
import SwiftKeychainWrapper

//Structure to store data to be displayed on my likes screen
struct Structure {
    var title: String
    var description: String
    var image: URL
}

//Custom cell outlets
class resuableCell: UITableViewCell {
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeDescription: UILabel!
    @IBOutlet weak var likeName: UILabel!
}

class  MyLikesViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive: Bool = false //to get search status
    var filter = [Structure]() //to filter data for search
    var likedPetList: [[String:Any]] = [[:]] //array to store JSON object from server
    var setPetToList = [Structure]() //structure to store data for liked screen view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        getLikes()
        self.title = "My Likes"
        searchBar.delegate = self //set ui search bar properties to this class
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Deselect a selected row after touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // no of columns in table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // return count of no of rows to be made
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filter.count
        }
        return self.setPetToList.count
    }
    
    //set title to list
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Pet List"
    }
    
    // set reusable cell, set data to table view and set filter data in case of search
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! resuableCell
        if searchActive {
            let setPetArray = filter[indexPath.row]
            cell.likeName?.text = setPetArray.title
            cell.likeDescription?.text = setPetArray.description
            DispatchQueue.main.async {
                cell.likeImage?.kf.setImage(with: setPetArray.image)
            }
        }
        else {
            let setPetArray = setPetToList[indexPath.row]
            cell.likeName?.text = setPetArray.title
            cell.likeDescription?.text = setPetArray.description
            DispatchQueue.main.async {
                cell.likeImage?.kf.setImage(with: setPetArray.image)
            }
        }
        return cell
    }
    
    // API call, set table view data source and delegate to self, show error in case of failure
    func getLikes() {
        let url = URL(string: "http://ec2-3-91-83-117.compute-1.amazonaws.com:3000/pets/likes")
        AlamofireWrapper().get(url: url!, headers: nil) { (petDataStringObject) in
            self.likedPetList = NSMutableArray(array: petDataStringObject as! [Any], copyItems: true) as! [[String : Any]]
            self.setLikedDataToCell()
            self.tableView.dataSource = self
            self.tableView.delegate = self
        }
    }
    
    //get liked pet data and append data to array
    func setLikedDataToCell() {
        for i in (0..<self.likedPetList.count) {
            let nTitle = self.likedPetList[i]["name"] as! String
            let nDescription = self.likedPetList[i]["description"] as! String
            let imgString = self.likedPetList[i]["image"] as! String
            let imgUrl = URL(string: imgString)
            let setPetArray = Structure(title: nTitle, description: nDescription, image: imgUrl!)
            setPetToList.append(setPetArray)
        }
        self.tableView.reloadData()
    }
    
    //search bar delegate functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    // Main search logic
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var range = false
        filter = setPetToList.filter({ (text) -> Bool in
            let temp = text
            if temp.description.localizedCaseInsensitiveContains(searchText) || temp.title.localizedCaseInsensitiveContains(searchText) {
                range = true
            }
            else {
                return false
            }
            return range
        })
        if filter.isEmpty {
            searchActive = false
        }
        else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
}
