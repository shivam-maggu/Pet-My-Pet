//
//  LogoutViewController.swift
//  Pet My Pet
//
//  Created by Shivam Maggu on 11/02/19.
//  Copyright © 2019 Shivam Maggu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftKeychainWrapper
import Poi
import Pods_Pet_My_Pet
import Kingfisher

class MainViewController: UIViewController, PoiViewDataSource, PoiViewDelegate {
    //Set outlet to UIView
    @IBOutlet weak var poiView: PoiView!
    //Array to append Cards
    var sampleCards = [Card]()
    //Array to get data from JSON
    var petListData: [[String:Any]] = [[:]]
    var style: UIStatusBarStyle = .lightContent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        self.navigationItem.title = "Explore"
        let logoutButton = UIBarButtonItem(image: UIImage(named: "logout_white"), style: .plain, target: self, action: #selector(logoutButtonClick))
        let myLikesButton = UIBarButtonItem(image: UIImage(named: "heart_white"), style: .plain, target: self, action: #selector(myLikesButtonClick))
        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItem = myLikesButton
        getPetList()
    }
    //API call to logout from server, delete keychain token content, move view back to login view controller , display error alert in case of failure
    @objc func logoutButtonClick() {
        let logoutUrl: String = "logout"
        AlamofireWrapper().post(parameters: nil, url: logoutUrl) { (tokenStringObject, messageStringObject, codeIntObject) in
            let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "savedToken")
            if codeIntObject == 200 && removeSuccessful == true {
                //print(self.navigationController?.viewControllers.count)
                self.navigationController?.popViewController(animated: true)
                //print("<<logout reached>> \(String(describing: messageStringObject))")
            }
        }
    }
    //Move view to my likes view controller
    @objc func myLikesButtonClick() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "mylikesvc") as! MyLikesViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //API call
    func getPetList() {
        if let retrievedString: String = KeychainWrapper.standard.string(forKey: "savedToken") {
            let headers: HTTPHeaders = ["Authorization" : retrievedString]
            let petaccess: String = "pets"
            AlamofireWrapper().get(url: petaccess, headers: headers) { (petDataStringObject) in
                self.petListData = NSMutableArray(array: petDataStringObject as! [Any], copyItems: true) as! [[String : Any]]
                //print(self.petListData.count)
                self.createViews()
                self.poiView.dataSource = self
                self.poiView.delegate = self
            }
        }
        //else {
            //print("could not retrive keychain")
        //}
    }
    
    //Set data on cards and append card to array
    private func createViews() {
        for i in (0..<self.petListData.count) {
            let texts = self.petListData[i]["name"] as! String
            let images = self.petListData[i]["image"] as! String
            let description = self.petListData[i]["description"] as! String
            let card = UINib(nibName: "Card", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! Card
            card.prepareUI(text: texts, img: images, des: description)
            sampleCards.append(card)
            //print(texts+"   "+images)
        }
    }
    
    //Update like/unlike status on cards to server
    func updateLikeStatus(position: Int, direction: SwipeDirection) {
        switch direction {
        case .left:
            let id = self.petListData[position - 1]["_id"]
            let likeStatus: [String : Any] = ["liked" : false]
            let url: String = "pets/likes/\(id!)"
            AlamofireWrapper().put(parameters: likeStatus, url: url) { (response) in
                //print(response)
            }
        case .right:
            let id = self.petListData[position - 1]["_id"]
            let likeStatus: [String : Any] = ["liked" : true]
            let url: String = "pets/likes/\(id!)"
            AlamofireWrapper().put(parameters: likeStatus, url: url) { (response) in
                //print(response)
            }
        }
    }
    
    //PoiViewDataSource
    func numberOfCards(_ poi: PoiView) -> Int {
        return self.petListData.count
    }
    
    func poi(_ poi: PoiView, viewForCardAt index: Int) -> UIView {
        return sampleCards[index]
    }
    
    func poi(_ poi: PoiView, viewForCardOverlayFor direction: SwipeDirection) -> UIImageView? {
        switch direction {
        case .right:
            let good = UIImageView(image: #imageLiteral(resourceName: "good"))
            good.tintColor = UIColor.green
            return good
        case .left:
            let bad = UIImageView(image: #imageLiteral(resourceName: "bad"))
            bad.tintColor = UIColor.red
            return bad
        }
    }
    
    //PoiViewDelegate
    func poi(_ poi: PoiView, didSwipeCardAt: Int, in direction: SwipeDirection) {
        switch direction {
        case .left:
            updateLikeStatus(position: didSwipeCardAt, direction: SwipeDirection.left)
            //print("left")
        case .right:
            updateLikeStatus(position: didSwipeCardAt, direction: SwipeDirection.right)
            //print("right")
        }
    }
    
    func poi(_ poi: PoiView, runOutOfCardAt: Int, in direction: SwipeDirection) {
        //print("last")
    }
    
    //IBAction for right ,left, cancel swipe
    @IBAction func OKAction(_ sender: UIButton) {
        poiView.swipeCurrentCard(to: .right)
        animateButtons(sender: sender)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        poiView.swipeCurrentCard(to: .left)
        animateButtons(sender: sender)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        poiView.undo()
        animateButtons(sender: sender)
    }
    
    //Function to animate buttons on press
    func animateButtons (sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        sender.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
}
