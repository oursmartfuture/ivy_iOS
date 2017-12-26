
//
//  HomeViewController.swift
//  IVY
//
//  Created by Singsys on 10/23/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//
import UIKit
import CoreBluetooth
import AVFoundation

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,AVAudioRecorderDelegate,submit {
    var DeviceList : NSMutableArray = []
    @IBOutlet var tableView:UITableView!
    var popupDel:UIView!
    var pending_status:String!
    var device_id = ""
    var device_mac_uuID = ""
    var viewType:String!
    @IBOutlet var navTitle:UILabel!
    var tapGesture:UITapGestureRecognizer!
    var refreshControl:UIRefreshControl!
    @IBOutlet var devTitle:UILabel!
    var submit = true
    @IBOutlet var notificationButton:UIButton!
    
    var identity: NSMutableArray!
    // var peripheral:CBPeripheral!
    var timer:Timer!
    var counter = 0
    
    var pendingNotification: String = ""
    
    var alert : UIAlertController = UIAlertController()
    
    //MARK:- override func
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appdelegate.detectId = self
        
        let noRecord = view.viewWithTag(777) as! UILabel!
        noRecord?.isHidden = true
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        //table view height
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        popupDel = view.viewWithTag(100) as UIView! // Delete popup
        popupDel.isHidden = true
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.setBadgeCount()
        
        if pendingNotification != ""
        {
            let alert = UIAlertView()
            alert.title = "Ivy App"
            alert.message = "You have \(pendingNotification) pending notifications. Go to notification list to see"
            alert.addButton(withTitle: "Go")
            alert.addButton(withTitle: "Cancel")
            alert.delegate=self
            
            alert.show()

        }
    
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden=true
        
        tableView.reloadData()
        
        if submit == true
        {
            self.viewDevice()
        }
        else if (DeviceList.count == 0)
        {
            self.viewDevice()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        switch buttonIndex {
        case 0:
            print("yes")
            if #available(iOS 8.0, *) {
                
                
                let home=storyboard?.instantiateViewController(withIdentifier: "ManageNotificationsViewController") as! ManageNotificationsViewController
                self.navigationController?.pushViewController(home, animated: true)
                
            } else {
                // Fallback on earlier versions
            }
            break;
        case 1:
            
            print("no")
            
            break;
            
        default:
            break
            
        }
        
    }

    
    //MARK:- tableView Delegate
    //MARK:-
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return DeviceList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        //        var cell:UITableViewCell!
        
        
        cellIdentifier = "devicesCell"
        
        //        cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        //
        var cell:SWTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SWTableViewCell!
        //
        if(cell==nil)
        {
            cell=SWTableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        //
        if DeviceList.count > 0
        {
            let rightUtilityButtons:NSMutableArray! = []
            
            rightUtilityButtons.sw_addUtilityButton(with: UIColor.gray, title: "Edit")
            
            rightUtilityButtons.sw_addUtilityButton(with: UIColor.red, title: "Delete")
            
            cell.rightUtilityButtons = rightUtilityButtons as NSMutableArray as [AnyObject]
            cell.delegate = self
            let settingDevice = cell.viewWithTag(1) as! UILabel
            let settingId = cell.viewWithTag(2) as! UILabel
            let settingDistance = cell.viewWithTag(3) as! UILabel
            settingDistance.isHidden = true
            let batteryImage = cell.viewWithTag(5) as! UIImageView
//            let settingBattery = cell.viewWithTag(4) as! UILabel
            
            settingDevice.text=(self.DeviceList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "device_name") as? String
            
            settingId.text = "ID : " + ((self.DeviceList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "unique_name") as! String)
            
            let listUuid = (self.DeviceList.object(at: indexPath.row) as AnyObject).object(forKey: "unique_name") as! String
            
//            if let yesD = UserDefaults.standard.object(forKey: "connectionFading") as? String
//            {
//                if yesD.lowercased() == "no"
//                {
//                    if appdelegate.distance > 0
//                    {
//                        settingDistance.text = "Distance : " + String(round(appdelegate.distance))
//                    }
//                    else
//                    {
//                        settingDistance.text = ""
//                    }
//                }
//                else
//                {
//                    settingDistance.text = ""
//                }
//            }
//            else
//            {
//                settingDistance.text = ""
//            }
            
            if let yesB = UserDefaults.standard.object(forKey: "leftBattery") as? String
            {
                if yesB.lowercased() == "yes"
                {
                    if appdelegate.connectedDeviceBatteryDictionary.object(forKey: "\(listUuid).battery") != nil
                    {
                        let battery = appdelegate.connectedDeviceBatteryDictionary.object(forKey: "\(listUuid).battery") as! String
                        
                       
                        //                    let intBattery = Int(battery)
                        
                        if Int(battery) > 80
                        {
                            batteryImage.isHidden = false
                            batteryImage.image = UIImage(named: "battery_full")
                            settingDistance.text = "Battery : " + battery
                        }
//                        else if Int(battery) > 60
//                        {
//                            batteryImage.isHidden = false
//                            batteryImage.image = UIImage(named: "battery_charged")
//                            settingDistance.text = "Battery : " + battery
//                        }
                        else if Int(battery) > 40
                        {
                            batteryImage.isHidden = false
                            batteryImage.image = UIImage(named: "battery_sixty")
                            settingDistance.text = "Battery : " + battery
                        }
//                        else if Int(battery) > 20
//                        {
//                            batteryImage.isHidden = false
//                            batteryImage.image = UIImage(named: "battery_low")
//                            settingDistance.text = "Battery : " + battery
//                        }
                        else if Int(battery) > 0
                        {
                            batteryImage.isHidden = false
                            batteryImage.image = UIImage(named: "battery_low")
                            settingDistance.text = "Battery : " + battery
                        }
                        else
                        {
                            batteryImage.isHidden = true
                            settingDistance.text = ""
                        }
 
                    }else
                    {
                        batteryImage.isHidden = true
                        settingDistance.text = ""
                    }
                   
                }
                else
                {
                    batteryImage.isHidden = true
                    settingDistance.text = ""
                }

            }
            else
            {
                batteryImage.isHidden = true
                settingDistance.text = ""
            }
            
            let pendingStatusView = cell.viewWithTag(55) as! UIImageView!
            
            if appdelegate.deviceConnectedDict.object(forKey: "\(listUuid)") != nil
            {
                if appdelegate.deviceConnectedDict.object(forKey: "\(listUuid)") as! String == "connected"
                {
                    pendingStatusView?.image = UIImage(named: "diamondSelected")
                }
                else
                {
                    pendingStatusView?.image = UIImage(named: "diamond")
                }

            }
            else
            {
                pendingStatusView?.image = UIImage(named: "diamond")
            }
            
            
        }
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        //
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        let deviceView = storyboard?.instantiateViewController(withIdentifier: "DeviceViewController") as! DeviceViewController
        
        deviceView.device_id = (DeviceList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "device_id") as! String
        
        
        self.submit = true
        
        deviceView.unique_name = (DeviceList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "unique_name") as! String
        
         deviceView.device_mac_uuID = ((DeviceList.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).object(forKey: "mac_address") as? String)!
        
        self.navigationController?.pushViewController(deviceView, animated: true)
        
    }
    
    
    
    
    //MARK:- SWTableView delegates
    //MARK:-
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        
        let FieldIndex = self.tableView.indexPath(for: cell)
        
        
        switch(index)
        {
        case 0:
            
            let add=storyboard?.instantiateViewController(withIdentifier: "AddDeviceViewController") as! AddDeviceViewController
            
            add.viewType = "editdevice"
            
            add.delegate = self
            
            add.name = ((self.DeviceList.object(at: ((FieldIndex as NSIndexPath?)?.row)!) as AnyObject).object(forKey: "device_name") as? String)!
            
            submit = true
            
            add.device_id = ((self.DeviceList.object(at: ((FieldIndex as NSIndexPath?)?.row)!) as AnyObject).object(forKey: "device_id") as? String)!
            
           
            
            
            //add.photoUrl =
            
            self.navigationController?.pushViewController(add, animated: true);
            
            break
            
            
        case 1:
            
            // let hitPoint: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
            
            
            device_id = (DeviceList.object(at: ((FieldIndex as NSIndexPath?)?.row)!) as AnyObject).object(forKey: "device_id") as! String
            devTitle.text = (DeviceList.object(at: ((FieldIndex as NSIndexPath?)?.row)!) as AnyObject).object(forKey: "device_name") as? String
            
            device_mac_uuID = ((DeviceList.object(at: ((FieldIndex as NSIndexPath?)?.row)!) as AnyObject).object(forKey: "mac_address") as? String)!
            
            popupDel.isHidden = false
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.doneTyping))
            self.view.addGestureRecognizer(tapGesture)
            break
            
        default: break
            
        }
    }
    
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    
    //MARK:- helping func
    //MARK:-
    
    func doneTyping()
    {
        popupDel.isHidden = true
        self.view.removeGestureRecognizer(tapGesture)
    }
    
    
    //To set badge count
    func setBadgeCount()
    {
        //                let badge : CustomBadge = CustomBadge(string: "100", withScale: 0.9, withStyle: BadgeStyle.defaultStyle())
        //               badge.frame = CGRectMake(25, 20, 25, 25)
        //            notificationButton.addSubview(badge)
        if appdelegate.notificationCount == 0
        {
            for view in notificationButton.subviews
            {
                if view.isKind(of: CustomBadge.self)
                {
                    view.removeFromSuperview()
                }
            }
        }
        else
        {
            
            let badge : CustomBadge = CustomBadge(string: (" \(appdelegate.notificationCount)"), withScale: 0.8, with: BadgeStyle.default())
            //add tap gesture on scroll view
            //            let tapGesture = UITapGestureRecognizer(target: self, action: "notificationButtonCLicked:")
            //            badge.addGestureRecognizer(tapGesture)
            
            //              let badge : CustomBadge = CustomBadge(string: (" \(appdelegate.notificationCount)"), withScale: 0.8)
            //  let badge : CustomBadge = CustomBadge(string: (" \(appdelegate.notificationCount)"))
            badge.frame = CGRect(x: 9, y: -10, width: 25, height: 25)
            notificationButton.addSubview(badge)
        }
    }
    
    
    // Webservice of Showing device list
    
    func viewDevice()
    {
        self.DeviceList.removeAllObjects()
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"page_number": 0,"mode":""] as NSDictionary
            // let param=["user_id":NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! String,"device_id":"","mode":""] as NSDictionary
            print(param)
            
            let url="\(base_URL)\(viewDevice_URL)"
            
            manager.post("\(url)",
                parameters: param,progress: nil,
                
                success: {
                    
                    (task, responseObject) in
                    
                    print(responseObject)
                    
                    appdelegate.hideProgressHudInView(self.view)
                    
                    
                    // let status:Any=(((responseObject as Any).object(forKey: "success")
                    
                    if let result = responseObject as? NSDictionary{
                        
                        let status  = result.value(forKey: "success") as! Int
                        
                        if(status  == 0)
                        {
                            //                                let msg = result.object(forKey: "message")! as! String
                            //
                            //                                 appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                        }
                        else
                        {
                            
                            //                                let msg = result.object(forKey: "message")! as! String
                            //
                            //                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                            //                                 self.contactList.removeAllObjects()
                            
                            let temp = result.object(forKey: "data")  as! NSArray
                            self.DeviceList = temp.mutableCopy()  as! NSMutableArray
                            
                        }
                        
                        
                        if self.DeviceList.count <= 0
                        {
                            let noRecord = self.view.viewWithTag(777) as! UILabel!
                            noRecord?.isHidden = false
                            
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
                            
                            
                            
                        }
                        else
                        {
                            let noRecord = self.view.viewWithTag(777) as! UILabel!
                            noRecord?.isHidden = true
                            
                            let session:AVAudioSession = AVAudioSession.sharedInstance()
                            
                            if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
                                AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                                })
                            }
                            else
                            {
                                print("Permission not granted")
                            }
                            
                             appdelegate.fromHome()
                            
                            
                        }
                        self.tableView.reloadData()
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
    
    
    func submit(_ submit: Bool)
    {
        self.submit = submit
    }
    
    
    // delete webservice
    func Delete()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"device_id":device_id,"mode":""] as NSDictionary
            
            print(param)
            
            let url="\(base_URL)\(deleteDevice_URL)"
            //        let url = String(map(s.generate()) {
            //            $0 == " " ? "+" : $0
            //            })
            
            
            manager.post("\(url)", parameters: param, success: {
                
                (operation,responseObject) in
                
                print(responseObject)
                
                appdelegate.hideProgressHudInView(self.view)
                
                if let result = responseObject as? NSDictionary{
                    
                    let status = result.object(forKey: "success")! as! Int
                    
                    let msg = result.object(forKey: "message")! as! String
                    if (status == 0)
                    {
                        
                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        
                    }
                    else
                    {
                        self.popupDel.isHidden = true
                        
                        self.view.removeGestureRecognizer(self.tapGesture)
                        
                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        
                        
//                        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(HomeViewController.viewDevice), userInfo: nil, repeats: false)
                        
                        if appdelegate.connectedDeviceDictionary.object(forKey: "\(self.device_mac_uuID)") != nil
                        {
                            let peripheral = appdelegate.connectedDeviceDictionary.object(forKey: "\(self.device_mac_uuID)") as! CBPeripheral
                            
                            let uuid = UUID(uuidString: "\(self.device_mac_uuID)")
                            
                            let peripheralDevice =  appdelegate.centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "1802")])
                            
                            print(peripheralDevice)
                            if appdelegate.connectedDeviceBatteryDictionary.object(forKey: "\(peripheral.name!).battery") != nil
                            {
                                appdelegate.connectedDeviceBatteryDictionary.removeObject(forKey: "\(peripheral.name!).battery")
                            }
                            
                            appdelegate.deviceConnectedDict.setObject("disconnectd", forKey: "\(peripheral.name!)" as NSCopying)
                            
//                        if peripheralDevice.count > 0
//                        {
//                            for i in 0..<peripheralDevice.count
//                            {
//                                 appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
////                                appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
////                                appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
////                                appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
//                            }
//                        }
                            
                           
                             appdelegate.centralManager.cancelPeripheralConnection(peripheral)
                            
                            appdelegate.connectedDeviceDictionary.removeObject(forKey: "\(self.device_mac_uuID)")
                            
                            if appdelegate.deviceConnected.contains(peripheral)
                            {
                                appdelegate.deviceConnected.remove(peripheral)
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
                        
                        
                        self.viewDevice()
                        
                    }
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
    
    func refresh(_ sender:AnyObject)
    {
        self.refreshControl.endRefreshing()
        
        DeviceList.removeAllObjects()
        
        self.viewDevice()
        
    }
    
    func timerAlert() {
        if counter < 5
        {
            counter += 1
        }
        else if counter == 5
        {
            timer.invalidate()
            notifyFriends()
        }
    }
    
    
    //MARK:- @IBAction func
    //MARK:-
    
    // for delete action
    @IBAction func okBtnClicked(_ sender:UIButton)
    {
        self.Delete()
    }
    
    // Action on clicking setting button
    @IBAction func settingCliked(_ sender: UIButton) {
        
        self.submit = false
        
        let sign=storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(sign, animated: true)
    }
    
    //Action of  Navigation to adding device screen
    
    @IBAction func addbtnClicked(_ sender: UIButton) {
        
        //
        //        let add=storyboard?.instantiateViewControllerWithIdentifier("AddDeviceViewController") as! AddDeviceViewController
        //
        //        add.viewType = "adddevice"
        //        add.delegate = self
        //        self.navigationController?.pushViewController(add, animated: true);
        
        self.submit = true
        
        let newAddDevPage = storyboard?.instantiateViewController(withIdentifier: "NewAddDeviceViewController") as! NewAddDeviceViewController
        
//        appdelegate.centralManager.stopScan()
        
        self.navigationController?.pushViewController(newAddDevPage, animated: true)
        
        
    }
    
    @IBAction func goToNotificationList(_ sender:UIButton)
    {
        let notification = storyboard?.instantiateViewController(withIdentifier: "ManageNotificationsViewController") as! ManageNotificationsViewController
        notification.alert_type = "Incoming Notifications"
        self.navigationController?.pushViewController(notification, animated: true)
        
    }
    
    
    //MARK:- @IBAction func for tappings
    //MARK:-
    
    
    @IBAction func twoTaps(_ sender: AnyObject) {
        
        appdelegate.sound = appdelegate.playAlert.listOfSounds[(Int(UserDefaults.standard.object(forKey: "defaultRingtone") as! String))!]
        
        appdelegate.audioPlayerCondition()
        
        alert = UIAlertController(title: "Ivy App", message: "stop sound alert", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        } ))
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            appdelegate.audioPlayer.pause()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func twoTapsDone() {
        
        appdelegate.sound = appdelegate.playAlert.listOfSounds[(Int(UserDefaults.standard.object(forKey: "defaultRingtone") as! String))!]
        
        appdelegate.audioPlayerCondition()
        
        alert = UIAlertController(title: "Ivy App", message: "stop sound alert", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        } ))
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
//            appdelegate.player.pause()
            appdelegate.audioPlayer.pause()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func threeTaps(_ sender: AnyObject) {
        //let alertView : UIAlertView = UIAlertView()
        
        if UserDefaults.standard.object(forKey: "contact_number") != nil
        {
            if let ContactArray = UserDefaults.standard.object(forKey: "contact_number") as? NSArray
            {
                if ContactArray.count > 0
                {
                    counter = 0
                    // start the timer
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAlert), userInfo: nil, repeats: true)
                    
                    alert = UIAlertController(title: "Ivy App", message: "Are you in Danger!!!", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "No Need", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.timer.invalidate()
                    } ))
                    
                    alert.addAction(UIAlertAction(title: "Notify Friend", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.notifyFriends()
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    appdelegate.showMessageHudWithMessage("You haven't added any Guardian yet. Go to Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
                }
            }
            else
            {
                appdelegate.showMessageHudWithMessage("You haven't added any Guardian yet. Go to Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
            }
        } else
        {
            appdelegate.showMessageHudWithMessage("You haven't added any Guardian yet. Go to Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
        }
        

        
        
    }
    
    func threeTapsDone() {
        
        self.submit = false
        
        if UserDefaults.standard.object(forKey: "contact_number") != nil
        {
            if let ContactArray = UserDefaults.standard.object(forKey: "contact_number") as? NSArray
            {
                if ContactArray.count > 0
                {
                    counter = 0
                    // start the timer
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAlert), userInfo: nil, repeats: true)
                    
                    alert = UIAlertController(title: "Ivy App", message: "Are you in Danger!!!", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "No Need", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.timer.invalidate()
                    } ))
                    
                    alert.addAction(UIAlertAction(title: "Notify Friend", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.notifyFriends()
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    appdelegate.showMessageHudWithMessage("You haven't added any Guardian yet. Go to Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
                }
            }
            else
            {
                appdelegate.showMessageHudWithMessage("You haven't added any Guardian yet. Go to Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
            }
        } else
        {
            appdelegate.showMessageHudWithMessage("You haven't added any Guardian yet. Go to Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
        }
        
        
    }

    
    func notifyFriends()
    {
        
        self.dismiss(animated: true, completion: nil)
        timer.invalidate()
        let audioRecord = storyboard?.instantiateViewController(withIdentifier: "AudioRecordViewController") as! AudioRecordViewController
        self.navigationController?.pushViewController(audioRecord, animated: true)
    }
    
    
    @IBAction func fourTaps(_ sender: AnyObject) {
        
        if #available(iOS 8.0, *) {
            UIApplication.shared.openURL(URL(string: "tel://\(UserDefaults.standard.object(forKey: "defaultNumber")!)")!)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func fourTapsDone()
    {
        if #available(iOS 8.0, *) {
            if UserDefaults.standard.object(forKey: "defaultNumber") != nil
            {
                if UserDefaults.standard.object(forKey: "defaultNumber")! as! String != ""
                {
                    let phoneNumber = "tel://".appending(UserDefaults.standard.object(forKey: "defaultNumber")! as! String)
                    print(phoneNumber)
                    UIApplication.shared.openURL(URL(string: phoneNumber)!)
                    
                    print("calling")
                }
                else{
                    var alert : UIAlertController = UIAlertController()
                    alert = UIAlertController(title: "Ivy App", message: "No default number exist .Make  a contact a default from added contacts to call", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        alert.dismiss(animated: true, completion: nil)
                    } ))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            else{
                var alert : UIAlertController = UIAlertController()
                alert = UIAlertController(title: "Ivy App", message: "No default number exist .Make  a contact a default from added contacts to call", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    alert.dismiss(animated: true, completion: nil)
                } ))
                self.present(alert, animated: true, completion: nil)
            }
            
            //                                let phoneNumber = "tel://".appending(UserDefaults.standard.object(forKey: "defaultNumber")! as! String)
            //                                print(phoneNumber)
            //                                UIApplication.shared.openURL(URL(string: phoneNumber)!)
            //                                print("Calling")
        } else {
            // Fallback on earlier versions
        }
        
    }
    
   
    
    
}
