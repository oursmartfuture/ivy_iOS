//
//  ManageNotificationsViewController.swift
//  FindMe
//
//  Created by Singsys on 23/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class ManageNotificationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
   // var notificationList:NSMutableArray! = []
     var refreshControl:UIRefreshControl!
    
    var notifications:NSArray! = NSArray()
    
    var notificationArray = NSMutableArray()
    
    @IBOutlet var tableView:UITableView!
    var alert_type = ""
    var page = 1
    @IBOutlet var notificationLAbel: UILabel!
    override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ManageNotificationsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(refreshControl)

        
       // self.getNotificationList()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        page = 1
        
        if alert_type == "My Notification"
        {
            notificationLAbel.text = "My Alerts"
            self.myNotificationList()
        }
        else
        {
            notificationLAbel.text = "Notifications"
            self.notificationList()
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- tableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notificationArray.count//notificationList.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if alert_type == "Incoming Notifications"
//        {
//        return "Notification List"
//        }
//        else
//        {
//             return "Device Notification List"
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cellIdentifier:String
        
        cellIdentifier = "DeviceNotifictaionCell"
        
        var cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        
         let timeText = cell?.viewWithTag(1) as! UILabel
        
        let deviceText = cell?.viewWithTag(2) as! UILabel
        
        deviceText.text = (notificationArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "notification_msg") as? String
        timeText.text=(notificationArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "addedon") as? String
        
        if (indexPath as NSIndexPath).row == notificationArray.count - 1
        {
            self.loadMore(indexPath)
        }
        
        cell?.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let str = (notificationArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "notification_data") as? String
        
        let redirection = (notificationArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "redirection") as! Int
        
        let result = convertStringToDictionary(text: str!)! as [String:AnyObject]

        print(result)
        
        
        if result != nil
        {
            if result["action"] as! String == "alert" 
            {
                if redirection == 0
                {
                    if alert_type == "My Notification"
                    {
                        let notificationDetail = storyboard?.instantiateViewController(withIdentifier: "EmergencyAlertViewController") as! EmergencyAlertViewController
                        
                        let tempId = (notificationArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "notification_type_id") as! String
                        
                        notificationDetail.fromScreen = "notification"
                        
                        notificationDetail.viewType = "notification"
                        
                        notificationDetail.alert_id = Int(tempId)!
                        
                        self.navigationController?.pushViewController(notificationDetail, animated: true)
                    }
                    else
                    {
                        let notificationDetail = storyboard?.instantiateViewController(withIdentifier: "EmergencyReceiverViewController") as! EmergencyReceiverViewController
                        
                        let tempId = (notificationArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "notification_type_id") as! String
                        
                        notificationDetail.alert_id = Int(tempId)!
                        
                        self.navigationController?.pushViewController(notificationDetail, animated: true)
                    }

                }
                else
                {
                    appdelegate.showMessageHudWithMessage("This alert has already been either \"Marked as Safe\" or \"Cancelled\".", delay: 4.0)
                }
               
            }
           
        }
     
    }
    
    

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return 70
        
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
  //MARK:-@IBAction func

    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    //MARK:- Web Service...
    /**
     Get notification list
     */
 //   func getNotificationList()
//    {
//        
//        if appdelegate.hasConnectivity()
//        {
//            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
//            
//           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
//            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
//            manager.responseSerializer = serializer
//            let param=["user_id":NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! String,"mode":"","alert_type":alert_type] as NSDictionary
//            print(param)
//            let url="\(base_URL)\(notificationList_URL)"
//            
//            manager.POST("\(url)",
//                parameters: param,
//                success: {
//                    (operation: URLSessionTask!,responseObject: AnyObject!)in
//                    print("SUCCESS")
//                    
//                    print(responseObject)
//                    appdelegate.hideProgressHudInView(self.view)
//                    
//                    let status:AnyObject=responseObject.objectForKey("success")!
//                    if(status as! NSObject == 0)
//                    {
//                        //let msg:AnyObject=responseObject.objectForKey("message")!
//                        
//                        // appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//                    }
//                    else
//                    {
//                        //let msg:AnyObject=responseObject.objectForKey("message")!
//                        
//                        //appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//                        // self.contactList.removeAllObjects()
//                        if ((responseObject["data"]) != nil && ((responseObject["data"])?!.isKindOfClass(NSMutableArray)) != nil && (responseObject["data"] as! NSArray).count > 0)
//                        {
//                            self.notificationList=(responseObject["data"] as! NSMutableArray)
//                        }
//                        else
//                        {
//                            
//                        }
////                        appdelegate.markNotificationAsRead("")
//                        
//                    }
//                    self.tableView.reloadData()
//                    
//                
//                    
//                },
//                failure: { (operation: URLSessionTask?,
//                    error: NSError!) in
//                    print("ERROR")
//                    appdelegate.hideProgressHudInView(self.view)
//                    
//                    let msg:AnyObject = "Failed due to an error"
//                    appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//            })
//        }
//        else
//        {
//            let msg:AnyObject = "No internet connection available. Please check your internet connection."
//            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//        }
//        
//    }
    
    //MARK: My Notification listing
    
    func myNotificationList()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"mode":"","page_no":page] as NSDictionary
            print(param)
            let url="\(base_URL)\(myNotificationListData_URL)"
            
            manager.post("\(url)",
                parameters: param,
                success: {
                    (operation: URLSessionTask!,responseObject: Any!)in
                    print("SUCCESS")
                    
                    print(responseObject)
                    appdelegate.hideProgressHudInView(self.view)
                    
                    if let result = responseObject as? NSDictionary{
                        
                        let status = result.object(forKey: "success") as! Int
                        
                        if(status == 0)
                        {
                            let msg = result.object(forKey: "No record found")! as! String
                            
                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        }
                        else
                        {
//                            let msg = result.object(forKey: "message")! as! String
//                            
//                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            // self.contactList.removeAllObjects()
                            if (result.object(forKey: "data")) != nil // && ((responseObject["data"])?!.isKind(of: NSMutableArray)) != nil && (responseObject["data"] as! NSArray).count > 0)
                            {
                                self.notifications = result.object(forKey: "data") as! NSArray
                                
                                let tempArray = result.object(forKey: "data") as! NSArray
                                
                                if tempArray.count>0
                                {
                                    if self.page == 1
                                    {
                                        self.notificationArray.removeAllObjects()
                                        
                                    }
                                    
                                    self.notificationArray.addObjects(from: (result.object(forKey: "data") as! NSArray).mutableCopy() as! [AnyObject])
                                    if self.page == 1
                                    {
                                        self.tableView.setContentOffset(CGPoint.zero, animated:true)
                                    }
                                    self.tableView.reloadData()
                                    if self.page == 1
                                    {
                                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
                                        
                                    }
                                }
                                
                            }
                            //else
                            // {
                            
                            // }
                            //appdelegate.markNotificationAsRead("")
                            
                        }
                       
                        
                        
                    }
                },
                failure: { (operation: URLSessionTask?,
                    error: Error!) in
                    print("ERROR")
                    appdelegate.hideProgressHudInView(self.view)
                    
                    let msg:AnyObject = "Failed due to an error" as AnyObject
                    appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            })
        }
        else
        {
            let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
        }
        
    }
    
    //MARK: Notification Listing
    
    func notificationList()
    {
            if appdelegate.hasConnectivity()
            {
                appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
                
               let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
                let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
                manager.responseSerializer = serializer
                let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"mode":"","page_no":page] as NSDictionary
                print(param)
                let url="\(base_URL)\(notificationListData_URL)"
                
                manager.post("\(url)",
                             parameters: param,
                             success: {
                                (operation: URLSessionTask!,responseObject: Any!)in
                                print("SUCCESS")
                                
                                print(responseObject)
                                appdelegate.hideProgressHudInView(self.view)
                                
                                 if let result = responseObject as? NSDictionary{
                                
                                let status = result.object(forKey: "success") as! Int
                                    
                                if(status == 0)
                                {
                                    let msg = result.object(forKey: "No record found")! as! String
                                    
                                     appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                }
                                else
                                {
//                                    let msg = result.object(forKey: "message")! as! String
//                                    
//                                    appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                    // self.contactList.removeAllObjects()
                                    if (result.object(forKey: "data")) != nil // && ((responseObject["data"])?!.isKind(of: NSMutableArray)) != nil && (responseObject["data"] as! NSArray).count > 0)
                                    {
                                        self.notifications = result.object(forKey: "data") as! NSArray
                                        
                                        let tempArray = result.object(forKey: "data") as! NSArray
                                        
                                        if tempArray.count>0
                                        {
                                            
                                            if self.page == 1
                                            {
                                                self.notificationArray.removeAllObjects()
                                                
                                            }
                                            
                                            self.notificationArray.addObjects(from: (result.object(forKey: "data") as! NSArray).mutableCopy() as! [AnyObject])
                                            
                                            if self.page == 1
                                            {
                                                  self.tableView.setContentOffset(CGPoint.zero, animated:true)
                                            }
                                            
                                            self.tableView.reloadData()
                                            
                                            if self.page == 1
                                            {
                                                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
                                                
                                            }
                                        }

                                        
                                        
                                    }
                                    //else
                                   // {
                                        
                                   // }
                                //appdelegate.markNotificationAsRead("")
                                    
                                }
                               
                                
                                
                                }
                    },
                             failure: { (operation: URLSessionTask?,
                                error: Error!) in
                                print("ERROR")
                                appdelegate.hideProgressHudInView(self.view)
                                
                                let msg:AnyObject = "Failed due to an error" as AnyObject
                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                })
            }
            else
            {
                let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            }
      
    }
    func refresh(_ sender:AnyObject)
    {
        self.refreshControl.endRefreshing()
        
//        notificationArray.removeAllObjects()
        
        if alert_type == "My Notification"
        {
            notificationLAbel.text = "My Alerts"
            page = 1
            self.myNotificationList()
        }
        else
        {
            notificationLAbel.text = "Notifications"
            page = 1
            self.notificationList()
        }
       
    }
    
    /**
     This function is called when page is changed.
     
     - parameter indexPath: NSIndexPath.
     */
    func loadMore(_ indexPath:IndexPath)
    {
        if (indexPath as NSIndexPath).row == notificationArray.count - 1
        {
            if ((indexPath as NSIndexPath).row+1)%10 == 0 && notificationArray.count>0
            {
                page = notificationArray.count/10
                if page == 0
                {
                    
                }
                page = page + 1
                
                if alert_type == "My Notification"
                {
                    notificationLAbel.text = "My Alerts"
                    self.myNotificationList()
                }
                else
                {
                    notificationLAbel.text = "Notifications"
                    self.notificationList()
                }
            }
        }
        
        
    }
   

    
}





