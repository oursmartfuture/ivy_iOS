//
//  SettingsViewController.swift
//  IVY
//
//  Created by Singsys on 30/10/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import CoreBluetooth

class SettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    fileprivate var listOfSettings=["General Settings", "Audio Settings", "Notifications","My Alerts","My Profile","Manage Contacts","About us","Contact Us","Terms & Conditions","Privacy Policy","Logout"]
    fileprivate var listIcons=["settings","Icon", "notification","alert","myProfile1","managecontact","aboutus","contactus","T&C","privacypolicy","logout"]
    
    @IBOutlet var tableView:UITableView!
    
    var forAudio = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Do any additional  setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableView Delegates
    //MARK:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 11
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cellIdentifier:String
        
        
        
        cellIdentifier = "settingsCell"
        
        var cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        
        let settingImage = cell?.viewWithTag(1) as! UIImageView
        
        let settingText = cell?.viewWithTag(2) as! UILabel
        
        settingImage.image=UIImage(named: "\(listIcons[(indexPath as NSIndexPath).row])");
        
        settingText.text=listOfSettings[(indexPath as NSIndexPath).row]
        
        cell?.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 6 || (indexPath as NSIndexPath).row == 8 || (indexPath as NSIndexPath).row == 9
        {
            let staticview=storyboard?.instantiateViewController(withIdentifier: "StaticViewController") as! StaticViewController
            
            if (indexPath as NSIndexPath).row == 6
            {
                staticview.viewType = "about"
            }
            else if (indexPath as NSIndexPath).row == 8
            {
                staticview.viewType = "Terms"
            }
                
            else
            {
                
                staticview.viewType = "privacy"
            }
            
            
            
            self.navigationController?.pushViewController(staticview, animated: true);
            
            
        }
        else if (indexPath as NSIndexPath).row == 7
        {
            let contactusview = storyboard?.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(contactusview, animated: true);
        }
        else if (indexPath as NSIndexPath).row == 0
        {
            let generalsettingview=storyboard?.instantiateViewController(withIdentifier: "GeneralSettingsViewController") as! GeneralSettingsViewController
            self.navigationController?.pushViewController(generalsettingview, animated: true);
        }
            
        else if (indexPath as NSIndexPath).row == 2
        {
            //    let manageNotifications = storyboard?.instantiateViewControllerWithIdentifier("ManageNotificationsViewController") as! ManageNotificationsViewController
            //
            //    self.navigationController?.pushViewController(manageNotifications, animated: true)
            
            let notification = storyboard?.instantiateViewController(withIdentifier: "ManageNotificationsViewController") as! ManageNotificationsViewController
            notification.alert_type = "Sent Emergency Notifications"
            self.navigationController?.pushViewController(notification, animated: true)
            
            
            
        }
            
            
        else if (indexPath as NSIndexPath).row == 3
        {
            let notification = storyboard?.instantiateViewController(withIdentifier: "ManageNotificationsViewController") as! ManageNotificationsViewController
            notification.alert_type = "My Notification"
            self.navigationController?.pushViewController(notification, animated: true)
            
       
        }
            //    else if indexPath.row == 7
            //{
            //
            //    forAudio = true
            //
            //    var alertView : UIAlertView = UIAlertView()
            //
            //    alertView .delegate = self
            //
            //    alertView .title = "Ivy App"
            //    alertView .message = "Hello.. I'm in danger..!!"
            //    alertView .addButtonWithTitle("Help")
            //    alertView .addButtonWithTitle("Cancel")
            //
            //    alertView .show()
            //}
            
            
        else if (indexPath as NSIndexPath).row == 4
        {
            let myprofileview=storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
            self.navigationController?.pushViewController(myprofileview, animated: true);
        }
        else if (indexPath as NSIndexPath).row == 10
        {
            forAudio = false
            
            let alertView : UIAlertView = UIAlertView()
            
            alertView .delegate = self
            
            alertView .title = "Ivy App"
            alertView .message = "Do you want to logout from this app?"
            alertView .addButton(withTitle: "Ok")
            alertView .addButton(withTitle: "Cancel")
            
            alertView .show()
            
            
        }
        else if (indexPath as NSIndexPath).row == 5
        {
            let managecontactsview=storyboard?.instantiateViewController(withIdentifier: "ManageContactsViewController") as! ManageContactsViewController
            self.navigationController?.pushViewController(managecontactsview, animated: true);
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            let infoVC=storyboard?.instantiateViewController(withIdentifier: "AudioListViewController") as! AudioListViewController
            self.navigationController?.pushViewController(infoVC, animated: true);
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if forAudio
        {
            
            switch buttonIndex
            {
            case 0:
                let audioRecord = storyboard?.instantiateViewController(withIdentifier: "AudioRecordViewController") as! AudioRecordViewController
                
                self.navigationController?.pushViewController(audioRecord, animated: true)
                
                break;
                
            default :
                break
            }
        }
        else
        {
            switch buttonIndex
            {
            case 0:
                
                self.logout()
                
               
                break;
                
            default :
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    
    
    
   
        //MARK: Notification Listing
        
        func logout()
        {
            if appdelegate.hasConnectivity()
            {
                appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
                
                let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
                let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
                manager.responseSerializer = serializer
                let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"mode":""] as NSDictionary
                print(param)
                let url="\(base_URL)\(logout_URL)"
                
                manager.post("\(url)",parameters: param,
                    success: {
                        (operation: URLSessionTask!,responseObject: Any!)in
                        print("SUCCESS")
                        
                        print(responseObject)
                        
                        appdelegate.hideProgressHudInView(self.view)
                        
                        if let result = responseObject as? NSDictionary{
                            
                            let status = result.object(forKey: "success") as! Int
                            
                            if(status == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            }
                            else
                            {
                                
                                if appdelegate.deviceConnected.count > 0
                                {
                                    for i in 0..<appdelegate.deviceConnected.count
                                    {
                                       let peripheral = appdelegate.deviceConnected.object(at: i) as! CBPeripheral
                                       appdelegate.centralManager.cancelPeripheralConnection(peripheral)
                                    }
                                    
                                    appdelegate.deviceConnected.removeAllObjects()
                                }
                                if appdelegate.peripheralManager != nil
                                {
                                    if appdelegate.peripheralManager.isAdvertising
                                    {
                                        appdelegate.peripheralManager.stopAdvertising()
                                        appdelegate.peripheralManager = nil
                                    }
                                }
                                
                                if appdelegate.centralManager != nil
                                {
                                    if #available(iOS 9.0, *) {
                                        if appdelegate.centralManager.isScanning
                                        {
                                            appdelegate.centralManager.stopScan()
                                        }
                                    } else {
                                        appdelegate.centralManager.stopScan()
                                    }
                                }
                                
                                appdelegate.isLoggedOut = true
                                appdelegate.from = ""
                                let storyboard = UIStoryboard ( name: "Main" , bundle: nil)
                                
                                let loginView = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                
                                UserDefaults.standard.set(false, forKey: "login")
                                
                                appdelegate.connectedDeviceDictionary.removeAllObjects()
                                appdelegate.connectedDeviceBatteryDictionary.removeAllObjects()
                                
                                //            self.navigationController?.popToViewController(loginView, animated: true)
                                let nav = UINavigationController(rootViewController: loginView)
                                
                                appdelegate.window!.rootViewController = nav
                                
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
    
    // Action for navigating on previous screen
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
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
