//
//  AlamofireWrapper.swift
//  Pet My Pet
//
//  Created by Shivam Maggu on 18/02/19.
//  Copyright © 2019 Shivam Maggu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftKeychainWrapper

class AlamofireWrapper {
    
    func post (parameters: Parameters?, url: URL, handler: @escaping ((String?, String?, Int) -> Void)) {
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                //print("Validation Successful")
                if let responseJsonObject: NSDictionary = response.result.value as? NSDictionary {
                    let dataJsonObject: NSDictionary = responseJsonObject["response"] as! NSDictionary
                    let tokenJsonObject: NSDictionary = dataJsonObject["data"] as! NSDictionary
                    let statusJsonObject: NSDictionary = dataJsonObject["status"] as! NSDictionary
                    let messageStringObject: String = statusJsonObject["message"] as! String
                    let tokenStringObject: String? = tokenJsonObject["token"] as? String
                    let codeIntObject: Int = statusJsonObject["code"] as! Int
                    //print("token value \(String(describing: tokenStringObject))")
                    handler(tokenStringObject, messageStringObject, codeIntObject)
                }
            case .failure(let error):
                //print("Validation not successful \(error)")
                if let errorCode = response.response?.statusCode {
                    if errorCode == 404 {
                        handler(nil, error as? String, errorCode)
                    }
                }
            }
            //print("Request: \(String(describing: response.request))")
            //print("Response: \(String(describing: response.response))")
            //print("Error: \(String(describing: response.error))")
        }
    }
    
    func put (parameters: Parameters, url: URL, handler: @escaping ((Any) -> Void)) {
        Alamofire.request(url, method: .put, parameters: parameters).responseJSON /*{ response in
         handler(response.result.value!)
         }*/
    }
    
    func get(url: URL, headers: HTTPHeaders?, handler: @escaping ((NSArray) -> Void)) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let responseJsonObject: NSDictionary = response.result.value as? NSDictionary {
                    let dataJsonObject: NSDictionary = responseJsonObject["response"] as! NSDictionary
                    let petsJsonObject: NSDictionary = dataJsonObject["data"] as! NSDictionary
                    let petDataStringObject: NSArray = petsJsonObject["pets"] as! NSArray
                    //print(petDataStringObject)
                    handler(petDataStringObject)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
