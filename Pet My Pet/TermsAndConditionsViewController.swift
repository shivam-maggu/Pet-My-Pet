//
//  TermsAndConditionsViewController.swift
//  Pet My Pet
//
//  Created by Shivam Maggu on 14/02/19.
//  Copyright © 2019 Shivam Maggu. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class TermsAndConditionsViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    //load webview
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    //set status bar icon color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func onBackButton_Clicked(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //set path of html file and load it on web view
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBarButton = UIBarButtonItem.init(barButtonSystemItem: .cancel , target: self, action: #selector(onBackButton_Clicked(sender:)))
        self.navigationItem.setLeftBarButton(backBarButton, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        do {
            guard let filePath = Bundle.main.path(forResource: "terms", ofType: "html")
                else {
                    print ("File reading error")
                    return
            }
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
    
    //set title header to web view
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
