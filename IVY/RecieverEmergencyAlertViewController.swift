//
//  RecieverEmergencyAlertViewController.swift
//  IVY
//
//  Created by Singsys-114 on 2/11/16.
//  Copyright © 2016 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class RecieverEmergencyAlertViewController: UIViewController {
    
    
    var alertDetails:NSMutableArray! = []
    @IBOutlet var tableView:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableView Delegates
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 3
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return ""
        }
            
        else if section == 1
        {
            return "Listen Audio"
        }
        else
        {
            return "Location Details"
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0
        {
            return 0
        }
        else
        {
            return 30
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!
        
        
        if (indexPath as NSIndexPath).section == 0
        {
            cellIdentifier = "cell1"
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            let lbl = cell.viewWithTag(1) as! UILabel!
            _ = cell.viewWithTag(2) as! UIImageView
            if alertDetails.count > 0
            {
                let a = (((alertDetails.object(at: 0) as AnyObject).object(forKey: "send_at") as! String).components(separatedBy: " ")[0])
                let b = (((alertDetails.object(at: 0) as AnyObject).object(forKey: "send_at") as! String).components(separatedBy: " ")[1])
                let c = ((alertDetails.object(at: 0) as AnyObject).object(forKey: "address") as! String)
                
                let d = ((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_duration") as! String)
                
                lbl?.text = "Last message has been sent on\n " + a + " at " + b + " with near\n" + c + " and " + d + " seconds recording."
            }
            
        }
            
        else if (indexPath as NSIndexPath).section == 1
        {
            cellIdentifier = "audioCell"
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
        }
        else
        {
            cellIdentifier = "mapCell"
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0
        {
            return 78
        }
        else if (indexPath as NSIndexPath).section == 1
        {
            return 57
        }
        else
        {
            if (indexPath as NSIndexPath).row == 0
            {
                return 49
            }
            else
            {
                return 144
            }
        }
    }
    
    
    func getAlertDetails()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"alert_id":"4","mode":""] as NSDictionary
            
            print(param)
            let url="\(base_URL)\(recieverAlert_URL)"
            
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
                                let msg = result.object(forKey: "message")! as! String
                                
                                 appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                            }
                            else
                            {
                                
                                let msg = result.object(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                // self.contactList.removeAllObjects()
                                
                                
                                //                        self.alertDetails=((responseObject["data"] as! NSDictionary).objectForKey("info")) as! NSMutableArray
                                //
                                //                        self.recipientList=((responseObject["data"] as! NSDictionary).objectForKey("receivers")) as! NSMutableArray
                                
                                
                                
                            }
                            self.tableView.reloadData()
                         
                            }
                },
                         failure: {(operation: URLSessionTask?, error: Error) -> Void in
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
    
    
    @IBAction func backBtnClicked(_ sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
