//
//  GeneralSettingsViewController.swift
//  IVY
//
//  Created by Singsys on 02/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//
import UIKit

class GeneralSettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    fileprivate var listOfHeading=["Privacy","Visible to others","Notifications","View Notification","Alert Type","Ring","Notification Type","Show Percentage of left battery","Connection/Disconnection Actions","Connection Fading"]
    
    @IBOutlet var tableView:UITableView!
    var settingsData:NSDictionary!
    var viewNotifications:String!
    var alertTypeRing:String!
    var leftBattery:String!
    var showMap:String!
    var connection:String!
    var connectionfad:String!
    var privacy:String!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        settingsData = NSMutableDictionary()
        showMap = "Yes"
        viewGeneralSettings()        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableView Delegates
    //MARK:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!
        
        if (indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 2 || (indexPath as NSIndexPath).row == 4 || (indexPath as NSIndexPath).row == 6
        {
            
            cellIdentifier = "headingCell"
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            let headingText = cell.viewWithTag(1) as! UILabel
            headingText.text=listOfHeading[(indexPath as NSIndexPath).row]
            // headingText.font = UIFont(name: headingText.font.fontName, size: 23)
        }
        else
        {
            cellIdentifier = "settingsCell"
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
          //  _ = cell.viewWithTag(33) as! UIButton!
            
            let headingText = cell.viewWithTag(2) as! UILabel
            headingText.text=listOfHeading[(indexPath as NSIndexPath).row]
            
        }
        let switchBtn = cell.viewWithTag(33) as! UIButton!
        let bottomLine = cell.viewWithTag(-99) as! UIImageView!
        
        
        if (indexPath as NSIndexPath).row == 1
        {
            if (settingsData.object(forKey: "set_privacy") != nil)
            {
                if ((settingsData.object(forKey: "set_privacy") as! String).lowercased() == "no")
                {
                    switchBtn?.isSelected = true
                    
               }
                else
               {
                    switchBtn?.isSelected = false
            
                }
            }
            else
            {
                switchBtn?.isSelected = false
                
            }
            
            bottomLine?.isHidden = true
            
            
        }

        else if (indexPath as NSIndexPath).row == 3
        {
            if (settingsData.object(forKey: "view_notification") != nil)
            {
                if (((settingsData.object(forKey: "view_notification") as! String).lowercased()) == "yes")
                {
                    switchBtn?.isSelected = true
                    
                }
                else
                {
                    switchBtn?.isSelected = false
                    
                }
            }
            else
            {
                switchBtn?.isSelected = false
            }
            
            bottomLine?.isHidden = true
        }
        else if (indexPath as NSIndexPath).row == 5
        {
            if (settingsData.object(forKey: "alert_type_ring") != nil)
            {
                if (((settingsData.object(forKey: "alert_type_ring") as! String).lowercased()) == "yes")
                {
                    switchBtn?.isSelected = true
                    
                }
                else
                {
                    switchBtn?.isSelected = false
                    
                }
            }
            else
            {
                switchBtn?.isSelected = false
                
            }
            
            bottomLine?.isHidden = true
            
        }
            
        else if (indexPath as NSIndexPath).row == 7
        {
            if (settingsData.object(forKey: "left_battery") != nil)
            {
                if ((settingsData.object(forKey: "left_battery") as! String).lowercased() == "yes")
                {
                    switchBtn?.isSelected = true
                    
                }
                else
                {
                    switchBtn?.isSelected = false
                    
                }
            }
            else
            {
                switchBtn?.isSelected = false
                
            }
            bottomLine?.isHidden = false
            
        }
//        else if indexPath.row == 8
//        {
//            if (settingsData.objectForKey("show_map") != nil)
//            {
//                if (settingsData.objectForKey("show_map")?.boolValue == true)
//                {
//                    switchBtn.selected = true
//                    
//                }
//                else
//                {
//                    switchBtn.selected = false
//                }
//            }
//            else
//            {
//                switchBtn.selected = false
//                
//            }
//            bottomLine.hidden = false
//            
//            
//        }
        else if (indexPath as NSIndexPath).row == 8
        {
            if (settingsData.object(forKey: "connection") != nil)
            {
                if ((settingsData.object(forKey: "connection") as! String).lowercased() == "yes")
                {
                    switchBtn?.isSelected = true
                    
                }
                else
                {
                    switchBtn?.isSelected = false
                    
                }
            }
            else
            {
                switchBtn?.isSelected = false
                
            }
            
            bottomLine?.isHidden = false
            
        }
        else if (indexPath as NSIndexPath).row == 9
        {
            if (settingsData.object(forKey: "connection_fading") != nil)
            {
                if ((settingsData.object(forKey: "connection_fading") as! String).lowercased() == "yes")
                {
                    switchBtn?.isSelected = true
                    
                }
                else
                {
                    switchBtn?.isSelected = false
                    
                }
            }
            else
            {
                switchBtn?.isSelected = false
                
            }
            
            bottomLine?.isHidden = false
            
            
        }
        
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 2 || (indexPath as NSIndexPath).row == 4 || (indexPath as NSIndexPath).row == 6
        {
            return 25
        }
            
        else
        {
            return 50
            
        }
    }
    
    
    //MARK:- @IBAction func
    // function for navigating to previous screen
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        generalSettings()
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    // Web service of View general setting hit on this action
    
    @IBAction func switchClicked(_ sender:UIButton)
        
    {
        let hitPoint: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        let FieldIndex = self.tableView.indexPathForRow(at: hitPoint)
        
        let cellToUpdate = self.tableView.cellForRow(at: FieldIndex!)
        
        let switchBtn = cellToUpdate?.viewWithTag(33) as! UIButton
        
        if switchBtn.isSelected == false
        {
            switchBtn.isSelected = true
        }
        else
        {
            switchBtn.isSelected = false
        }
        
        if ( (FieldIndex as NSIndexPath?)?.row==1 )
        {
            if switchBtn.isSelected
            {
                privacy = "No"
            }
            else
            {
                privacy = "Yes"
            }
        }
        
        if ( (FieldIndex as NSIndexPath?)?.row==3 )
        {
            if switchBtn.isSelected
            {
                viewNotifications = "Yes"
            }
            else
            {
                viewNotifications = "No"
            }
        }
        else if ( (FieldIndex as NSIndexPath?)?.row==5)
            
        {
            if switchBtn.isSelected
            {
                alertTypeRing = "Yes"
            }
            else
            {
                alertTypeRing = "No"
            }
            
        }
            
        else if ( (FieldIndex as NSIndexPath?)?.row==7)
            
        {
            if switchBtn.isSelected
            {
                leftBattery = "Yes"
            }
            else
            {
                leftBattery = "No"
            }
        }
        else if ( (FieldIndex as NSIndexPath?)?.row==8)
        {
            if switchBtn.isSelected
            {
                showMap = "Yes"
            }
            else
            {
                showMap = "No"
            }
           
        }
        else if ( (FieldIndex as NSIndexPath?)?.row==8)
            
            
        {
            if switchBtn.isSelected
            {
                connection = "Yes"
            }
            else
            {
                connection = "No"
            }
        }
        else if ( (FieldIndex as NSIndexPath?)?.row==9 )
        {
            if switchBtn.isSelected
            {
                connectionfad = "Yes"
            }
            else
            {
                connectionfad = "No"
            }
        }
    }
    
    
    //MARK:- hit webservice
    //downloading setting...
    // web service of view general setting
    func viewGeneralSettings()
    {
        appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
        
       let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
        let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
        manager.responseSerializer = serializer
        let user_id:String!
        if (UserDefaults.standard.object(forKey: "user_id") != nil)
        {
            user_id = UserDefaults.standard.object(forKey: "user_id") as! String
        }
        else
        {
            user_id = ""
        }
        
        let param=["user_id":(user_id)!,"mode":""] as NSDictionary
        print(param)
        let url="\(base_URL)\(viewGeneralSettings_URL)"
        
        manager.post("\(url)",
                     parameters: param,
                     success: {
                        (operation,responseObject)in
                        
                        print(responseObject)
                        
                        if let result = responseObject as? NSDictionary{
                        
                        let json  = result as! NSDictionary
                        
                        appdelegate.hideProgressHudInView(self.view)
                        
                        let status = json.object(forKey: "success")! as! Int
                        
                        if(status  == 0)
                        {
                            let msg = json.object(forKey: "message")! as! String
                            
                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            
                        }
                        else
                        {
                            self.settingsData = json.object(forKey: "data") as! NSDictionary
                            
                            self.viewNotifications = self.settingsData.object(forKey: "view_notification") as! String
                            self.alertTypeRing = self.settingsData.object(forKey: "alert_type_ring") as! String
                            self.leftBattery = self.settingsData.object(forKey: "left_battery") as! String
//                            self.showMap = self.settingsData.object(forKey: "show_map") as! String
                            self.connection = self.settingsData.object(forKey: "connection") as! String
                            self.connectionfad = self.settingsData.object(forKey: "connection_fading") as! String
                            self.privacy = self.settingsData.object(forKey: "set_privacy") as! String
                            
                            
                        }
                        self.tableView.reloadData()
                            
                        }
                        
            },
                     failure: { (operation: URLSessionTask?,
                        error: Error) in
                        print("ERROR")
                        appdelegate.hideProgressHudInView(self.view)
                        
                        let msg:AnyObject = "Failed due to an error" as AnyObject
                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
        })
        
    }
    
    // uploading setting...
    // web service of general setting.
    func generalSettings()
    {
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let user_id:String!
            if (UserDefaults.standard.object(forKey: "user_id") != nil)
            {
                user_id = UserDefaults.standard.object(forKey: "user_id") as! String
            }
            else
            {
                user_id = ""
            }
            
            let param=["user_id":(user_id)!,"view_notification":(viewNotifications)!,"alert_type_ring":(alertTypeRing)!,"left_battery":(leftBattery)!,"show_map":(showMap)!,"connection":(connection)!,"connection_fading1":(connectionfad)!,"set_privacy":(privacy)!,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(generalSettings_URL)"
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in
                            
                            print(responseObject)
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                            let result = responseObject as? NSDictionary
                            
                            let status = result?.object(forKey: "success")! as! Int
                            if(status  == 0)
                            {
                                let msg:Any = result!.object(forKey: "message")! as! String
                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                                
                            }
                            else
                            {
                        
                                UserDefaults.standard.setValue(self.viewNotifications, forKey: "viewNotification")
                                
                                UserDefaults.standard.setValue(self.connectionfad, forKey: "connectionFading")
                                UserDefaults.standard.setValue(self.leftBattery, forKey: "leftBattery")
                            }
                            
                },
                         failure: {(operation: URLSessionTask?, error: Error) -> Void in
                    print("Error: \(error)")
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
    
    
}

