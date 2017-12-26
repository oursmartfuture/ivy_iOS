//
//  StaticViewController.swift
//  Fun
//
//  Created by Sri Shukla on 15/9/15.
//  Copyright (c) 2015 singsys. All rights reserved.
//

import UIKit

class StaticViewController: UIViewController,UIWebViewDelegate
{
    
    //  @IBOutlet weak var back:UIButton!
    var page_html = ""
    @IBOutlet var webView:UIWebView!
    
    @IBOutlet var navTitle:UILabel!
    
    @IBOutlet var activityIndicator:UIActivityIndicatorView!
    var page_key = ""
    var viewType:String!
    
    override func viewDidLoad()
    {
        
        //back.hidden = true
        //menuButton.hidden = false
        super.viewDidLoad()
        
        
        if(viewType=="Terms")
        {
            //            if page_html.isEmpty == false
            //            {
            //
            //                webView.loadHTMLString(page_html, baseURL: nil)
            //            }
            
            
            page_key = "terms_and_conditions"
            navTitle.text = "Terms & Conditions"
            
             let url="\(base_URL)static-pages.php?page_key=terms_and_conditions"
            
            webView.loadRequest(URLRequest(url: URL(string: url)!))
            
        }
        else if(viewType=="privacy")
        {
            
            
            
            
            page_key = "privacy_policy"
            navTitle.text = "Privacy Policy"
            
            
            let url="\(base_URL)static-pages.php?page_key=privacy_policy"
            
            webView.loadRequest(URLRequest(url: URL(string: url)!))

            
        }
        else if(viewType=="about")
        {
            
            //            if page_html.isEmpty == false
            //            {
            //
            //                webView.loadHTMLString(page_html, baseURL: nil)
            //            }
            
            page_key = "about_us"
            
            navTitle.text = "About Us"
            
            
            let url="\(base_URL)static-pages.php?page_key=about_us"
            
            webView.loadRequest(URLRequest(url: URL(string: url)!))

        }
        
        //    self.static_pages()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UIWebview Delegate
    
    func webViewDidStartLoad(_ webView : UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //println("AA")
        self.activityIndicator .startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        //println("BB")
        appdelegate.hideProgressHudInView(self.view)
        
        self.activityIndicator.stopAnimating()
        
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func back(_ sender:UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
    //    func static_pages()
    //   //{       if appdelegate.hasConnectivity()
    //
    //    {
    //        appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
    //       let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager ()
    //       let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
    //       manager.responseSerializer = serializer
    //       let param=["mode":"","page_key":page_key]
    //       let s="\(base_URL)\(static_URL)"
    //            let url="\(base_URL)\(static_URL)"
    //            //        let url = String(map(s.generate()) {
    //            //            $0 == " " ? "+" : $0
    //            //            })
    //            manager.POST("\(url)",
    //                parameters: param,
    //            success: {
    //                (operation: AFHTTPRequestOperation!,
    //                responseObject: AnyObject!) in
    //                print("SUCCESS")
    //                print(responseObject)
    //               // appdelegate.hideProgressHudInView(self.view)
    //                var data=responseObject["data"] as! NSDictionary
    //               self.page_html = data.objectForKey("page_html") as! String!
    //                self.loading()
    //
    //                self.webView.reload()
    //
    //
    //            },
    //            failure: { (operation: AFHTTPRequestOperation!,
    //                error: NSError!) in
    //                print("ERROR")
    //                appdelegate.hideProgressHudInView(self.view)
    //                let msg:AnyObject = "Failed due to an error"
    //                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
    //            }
    //        )
    //        }
    //       // else
    //        //{
    //
    //            //let msg:AnyObject = "Please check your internet connection"
    //           // appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
    //            
    //       // }
    //
    //    
    //    func loading()
    //    {
    //        if page_html.isEmpty == false
    //        {
    //            
    //            webView.loadHTMLString(page_html, baseURL: nil)
    //        }
    //        
    //        self.webView.reload()
    //        
    //    }
    
    
    
}
