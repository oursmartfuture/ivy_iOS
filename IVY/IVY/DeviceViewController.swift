//
//  DeviceViewController.swift
//  FindMe
//
//  Created by Singsys on 23/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MapKit
import CoreBluetooth

class DeviceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet var devTitle:UILabel!
    var popupDel:UIView!
    var tapGesture:UITapGestureRecognizer!
    var locationMap:MKMapView!
    var index:IndexPath!
    @IBOutlet var tableView:UITableView!
    var Deviceinfo : NSMutableArray = []
    var device_id = ""
    var device_mac_uuID = ""
    var unique_name = ""
    var detailType = ["Unique ID","Status","Last Seen Location","Last Seen Time"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupDel = view.viewWithTag(100) as UIView! // Delete popup
        popupDel.isHidden = true
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.viewDeviceNew()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    //MARK:- tableview Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //if NSUserDefaults.standardUserDefaults().objectForKey("showMap") as! String != "No"
        //{
       // return 6
        //}
        //else
        //{
            return 3
        //}
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cellIdentifier:String
        var cell:UITableViewCell!
        
        if (indexPath as NSIndexPath).row == 0
        {
            cellIdentifier = "ImageCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
            let devName = cell.viewWithTag(55) as! UILabel
            let profileImage = cell.viewWithTag(555) as! UIImageView
            
            if Deviceinfo.count > 0
            {
                devName.text = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "name") as? String
                
                profileImage.layer.cornerRadius = profileImage.frame.size.width/2
                
                let photoUrl = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "device_image") as! String
                
                profileImage.clipsToBounds = true
                
                profileImage.setImageWith(URL(string: photoUrl)!)
                
            }
            
        }
        else if (indexPath as NSIndexPath).row == 1 || (indexPath as NSIndexPath).row == 2 || (indexPath as NSIndexPath).row == 3 || (indexPath as NSIndexPath).row == 4
        {
            
            cellIdentifier = "PairingStatusCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
            let settingImage = cell.viewWithTag(1) as! UIImageView
            
            let propertyText = cell.viewWithTag(2) as! UILabel
            
            let settingText = cell.viewWithTag(3) as! UILabel
            
            //   settingImage.image=UIImage(named: "\(Deviceinfo[indexPath.row-1])");
            
            propertyText.text=detailType[(indexPath as NSIndexPath).row-1] as String
            
            if (indexPath as NSIndexPath).row == 1
            {
                settingText.text="ID: " + unique_name
                settingImage.image = UIImage(named: "Contactlist")
            }
            else if (indexPath as NSIndexPath).row == 2
            {
                if Deviceinfo.count > 0
                {
                    let status = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "pending_status") as! String
                    
                    
                    if status.lowercased() == "yes"
                    {
                        settingText.text = "Active"
                        settingImage.image = UIImage(named: "activeOn")
                    }
                    else
                    {
                        settingText.text = "Disable"
                        settingImage.image = UIImage(named: "activeOff")
                    }
                }
            }
                
            else if (indexPath as NSIndexPath).row == 3
            {
                index=indexPath
                settingImage.image = UIImage(named: "icon")
                
            }
                
                
            else if (indexPath as NSIndexPath).row == 4
            {
                if Deviceinfo.count > 0
                {
                    
                    let lastTime = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_seen_time") as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    _ = dateFormatter.date(from: lastTime)
                    
                    dateFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
                    
                    
                    // settingText.text=dateFormatter.stringFromDate(lastDate!)
                }
                settingImage.image = UIImage(named: "watch")
            }
            
            
        }
        else if (indexPath as NSIndexPath).row == 5
        {
            cellIdentifier = "MapCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
            
            locationMap = cell.viewWithTag(11) as! MKMapView!
            if Deviceinfo.count > 0
            {
                self.forAnnotation()
            }
            
       }
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if (indexPath as NSIndexPath).row == 3
        {
            let location = storyboard?.instantiateViewController(withIdentifier: "DeviceLocationViewController") as! DeviceLocationViewController
            location.Deviceinfo = self.Deviceinfo
            self.navigationController?.pushViewController(
                location, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0
        {
            return 210
        }
            
        else if (indexPath as NSIndexPath).row == 1 || (indexPath as NSIndexPath).row == 2 || (indexPath as NSIndexPath).row == 3 || (indexPath as NSIndexPath).row == 4
        {
            return 64
            
        }
        else
        {
            return 205
                
        }
        
    }
    

    //MARK:- annotation for Map
    func forAnnotation()
    {
        var arrText = ""
        
        let loc = CLLocation(latitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_lat") as! NSString).doubleValue, longitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_long") as! NSString).doubleValue)
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                print(pm.addressDictionary)
                let cellToUpdate = self.tableView.cellForRow(at: self.index)
                let settingText = cellToUpdate?.viewWithTag(3) as! UILabel!
                
                //let arrCount = (((pm.addressDictionary!["FormattedAddressLines"])! as Any) as AnyObject).count
                
                for i in 0..<(((pm.addressDictionary!["FormattedAddressLines"])! as Any) as AnyObject).count
                {
                    if arrText.isEmpty == true
                    {
                        
                        arrText = arrText + ((pm.addressDictionary!["FormattedAddressLines"] as! NSArray)[i] as! String)
                    }
                    else
                    {
                        arrText = arrText + ", " + ((pm.addressDictionary!["FormattedAddressLines"] as! NSArray)[i] as! String)
                    }
                }
                
                
                settingText?.text = arrText
                self.next(arrText)
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
        })
        
        
    }
    
    
    
    //MARK:- @IBAction func
    @IBAction func okBtnClicked(_ sender:UIButton)
    {
        self.Delete()
    }
    
    @IBAction func deleteBtnClicked(_ sender:UIButton)
    {
        // device_id = DeviceList.objectAtIndex((FieldIndex?.row)!).objectForKey("device_id") as! String
        devTitle.text = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "name") as? String
        
        popupDel.isHidden = false
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(DeviceViewController.doneTyping))
        self.view.addGestureRecognizer(tapGesture)
    }

    //IBaction for back button
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    
    //MARK:- webservices
    
    //Web service to get device detail.
    func viewDeviceNew()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
//            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
//            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
//            manager.responseSerializer = serializer
//            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"device_id":device_id,"mode":""] as NSDictionary
//            print(param)
//            let url="\(base_URL)\(viewDeviceDetail_URL)"
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            
            manager.responseSerializer = serializer
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"device_id":device_id,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(viewDeviceDetail_URL)"
           
            manager.post("\(url)",
                         parameters: param, progress: nil,
                         success: {
                            (task, responseObject) in
                            
                            print(responseObject)
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                             if let result = responseObject as? NSDictionary{
                            let status = result.value(forKey: "success")! as! Int
                            if(status == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                
                                 appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            }
                            else
                            {
//                                 let msg = result.object(forKey: "message")! as! String
//                                
//                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                // self.contactList.removeAllObjects()
                                let temp = result.object(forKey: "data") as! NSArray
                                
                                self.Deviceinfo = temp.mutableCopy() as! NSMutableArray
                                
                                self.tableView.reloadData()
                                
                           
                                }
                            }
                            
                }, failure: {(operation: URLSessionTask?, error: Error) -> Void in
                    print("Error: \(error)")
         //   })

                        // failure: { (operation: URLSessionTask?,
                           // error: Error) in
                          //  print("ERROR")
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

    
    
    func Delete()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
//            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
//            manager.responseSerializer = serializer
            
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"device_id":device_id,"mode":""] as NSDictionary
            print(param)
            
            let url="\(base_URL)\(deleteDevice_URL)"
            //        let url = String(map(s.generate()) {
            //            $0 == " " ? "+" : $0
            //            })
            
            
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in

                            print(responseObject)
                            appdelegate.hideProgressHudInView(self.view)
                            
                            if let result = responseObject as? NSDictionary{
                            
                            let status = result.object(forKey: "success")! as! Int
                            let msg = result.object(forKey: "message") as! String
                            if (status == 0)
                            {
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                            }
                            else
                            {
                                
                                self.popupDel.isHidden = true
                                
                                self.view.removeGestureRecognizer(self.tapGesture)
                                
                                
                                if appdelegate.connectedDeviceDictionary.object(forKey: "\(self.device_mac_uuID)") != nil
                                {
                                    let peripheral = appdelegate.connectedDeviceDictionary.object(forKey: "\(self.device_mac_uuID)") as! CBPeripheral
                                    
                                    let uuid = UUID(uuidString: "\(self.device_mac_uuID)")
                                    
                                    let peripheralDevice =  appdelegate.centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "1802")])
                                    
                                    print(peripheralDevice)
                                    
                                    if peripheralDevice.count > 0
                                    {
                                        for i in 0..<peripheralDevice.count
                                        {
                                            appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
                                            appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
                                            appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
                                            appdelegate.centralManager.cancelPeripheralConnection(peripheralDevice[i])
                                        }
                                    }
                                    
                                    
                                    appdelegate.centralManager.cancelPeripheralConnection(peripheral)
                                    appdelegate.connectedDeviceDictionary.removeObject(forKey: "\(self.device_mac_uuID)")
                                    
                                    if appdelegate.deviceConnected.contains(peripheral)
                                    {
                                        appdelegate.deviceConnected.remove(peripheral)
                                    }
                                    
                                    
                                    
                                }
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(DeviceViewController.navigate), userInfo: nil, repeats: false)
                                
                                
                                
                            }
                            }
                            
                },
                         failure: {(operation: URLSessionTask?, error: Error) -> Void in
                    print("Error: \(error)")
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
    //MARK:- helping func
    
    func next(_ arrText:String)
    {
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_lat") as! NSString).doubleValue, longitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_long") as! NSString).doubleValue)
        
        
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
        
        locationMap.setRegion(theRegion, animated: true)
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = arrText
        //    anotation.subtitle = arrText
        
        
        
        locationMap.addAnnotation(anotation)
        
    }
    
    
    func doneTyping()
    {
        popupDel.isHidden = true
        self.view.removeGestureRecognizer(tapGesture)
    }
    
    
    func navigate()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
