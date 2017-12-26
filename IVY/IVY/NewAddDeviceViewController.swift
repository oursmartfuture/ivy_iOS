//
//  NewAddDeviceViewController.swift
//  FindMe
//
//  Created by Singsys-114 on 12/28/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import CoreBluetooth

class NewAddDeviceViewController: UIViewController  {
    
    var refreshControl:UIRefreshControl!
    @IBOutlet var tableView:UITableView!
    var deviceArray:NSMutableArray! = []
    @IBOutlet var enableBluetoothView:UIView!
    // var centralManager : CBCentralManager!
    @IBOutlet weak var noRecordsFound: UILabel!
    var bluetoothManager:AnyObject!
    
    //MARK:- override func
    //MARK:-
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        appdelegate.addDevice = self
        
        noRecordsFound.isHidden = true
        
        appdelegate.fromAddDev(enableBluetoothView)
      
        appdelegate.hideProgressHudInView(true as AnyObject)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NewAddDeviceViewController.refereshTable),
            name: NSNotification.Name(rawValue: "addedDevice"),
            object: nil)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ManageNotificationsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(refreshControl)
        
//        NSNotificationCenter.defaultCenter().addObserver(
//            self,
//            selector: #selector(NewAddDeviceViewController.refereshTable),
//            name: "addedDevice",
//            object: nil)

        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if deviceArray != nil
        {
            noRecordsFound.isHidden = true
        }
        else{
            
        noRecordsFound.isHidden = false
        
        }
        
//        appdelegate.centralManagerDidUpdateState(appdelegate.centralManager)
    }
    
    
    
    
    //MARK:- tableView func
    //MARK:-
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if deviceArray.count > 0
        {
            self.noRecordsFound.isHidden = true
        }
        return deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier="cell"
        var cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell?.textLabel?.text = ((deviceArray[(indexPath as NSIndexPath).row]) as AnyObject).name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let add=storyboard?.instantiateViewController(withIdentifier: "AddDeviceViewController") as! AddDeviceViewController
        
        add.viewType = "adddevice"
        
        if ((deviceArray[(indexPath as IndexPath).row]) as AnyObject) != nil
        {
            add.name =  (((deviceArray[(indexPath as NSIndexPath).row]) as AnyObject).name)
        }
        else
        {
            add.name = "myDev"
        }
        add.peripheral = deviceArray[(indexPath as NSIndexPath).row] as! CBPeripheral
        
        self.navigationController?.pushViewController(add, animated: true);
    }
    
    
    
    
    
    
    //MARK:- helping func
    //MARK:-
    
    func refereshTable()
    {
        appdelegate.hideProgressHudInView(self)
        
        tableView.reloadData()
    }

    
    //MARK:- Action func
    //MARK:-
    
    @IBAction func enableBT(_ sender:UIButton)
    {
        if #available(iOS 8.0, *) {
            
            if #available(iOS 10.0, *) {
                
                 UIApplication.shared.openURL(NSURL(string: "prefs:root=Bluetooth")! as URL)
//                appdelegate.showMessageHudWithMessage("Turn On the bluethooth from Phone Setting", delay: 4.0)
                
            }
            else
            {
                UIApplication.shared.openURL(NSURL(string: "prefs:root=Bluetooth")! as URL)
            }

            
//
            
//            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
           
        }
            
        else {
            // Fallback on earlier versions
        }
              
    }

    
    
    @IBAction func back(_ sender:UIButton)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func refresh(_ sender:AnyObject)
    {
        self.refreshControl.endRefreshing()
        noRecordsFound.isHidden = true
        //        notificationArray.removeAllObjects()
        deviceArray.removeAllObjects()
        
        tableView.reloadData()
        
        appdelegate.fromAddDev(enableBluetoothView)
        
    }
    
    
}
