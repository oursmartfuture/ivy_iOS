//
//  ManageContactsViewController.swift
//  IVY
//
//  Created by Singsys on 06/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

protocol getCode
{
    func getCode(_ code:String)
}


class CountryCodeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    var searchBarText : NSString!
    var searchResult:NSArray = NSArray()
    
    var countryList : NSMutableArray = []
    var delegate: getCode?
    var indexpath:IndexPath!
    @IBOutlet var tableView:UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.getcountryList()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(searchResult.count > 0)
        {
            return searchResult.count
        }
        else
        {
            return countryList.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!
        
        
        cellIdentifier = "countryCell"
        cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        //  let Countryname = cell.viewWithTag(1) as! UILabel
        
        //  Countryname.text=self.countryList.objectAtIndex(indexPath.row).objectForKey("user_name") as? String
        
        if countryList.count > 0
        {
            if(searchResult.count > 0)
            {
                cell.textLabel?.text = ((self.searchResult.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "country") as? String)! + "(" + ((self.searchResult.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "country_code") as? String)! + ")"
            }
            else
            {
                cell.textLabel?.text = ((self.countryList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "country") as? String)! + "(" + ((self.countryList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "country_code") as? String)! + ")"
            }
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if(searchResult.count > 0)
        {
            
            delegate?.getCode(((self.searchResult.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "country_code") as? String)!)
            
        }
        else
        {
            
            delegate?.getCode(((self.countryList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "country_code") as? String)!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: UIAlertView Delegate
    //MARK:
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    
    
    
    func getcountryList()
    {
        
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(countryList_URL)"
            
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in
                            
                            print(responseObject)
                                
                            appdelegate.hideProgressHudInView(self.view)
                            
                             if let result = responseObject as? NSDictionary{
                            let status = result.object(forKey: "success")! as! Int
                            if(status == 0)
                            {
                                
                            }
                            else
                            {
                                let tempArray = result.object(forKey: "data") as! NSArray
                          self.countryList = tempArray.mutableCopy() as! NSMutableArray
                            }
                            self.tableView.reloadData()
                            }
         
                }, failure: {(operation: URLSessionTask?, error: Error) -> Void in
                    print("Error: \(error)")
                            print("ERROR")
                            appdelegate.hideProgressHudInView(self.view)
                            
                            let msg:Any = "Failed due to an error" as AnyObject
                            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            })
        }
        else
        {
            let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchBarText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces) as NSString!
        
        if searchBarText.length > 0
        {
            
            self.filterContentForSearchText(searchBarText, scope: "")
        }
        
    }
    
    func filterContentForSearchText(_ searchText: NSString, scope: NSString) {
        let resultPredicate = NSPredicate(format: "country contains[c] %@", searchText)
        searchResult = countryList.filtered(using: resultPredicate) as NSArray!
        print(searchResult)
        tableView.reloadData()
    }
    
}
