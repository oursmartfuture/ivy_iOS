

//
//  AppDelegate.swift
//  IVY
//
//  Created by Singsys on 21/10/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MapKit
import Fabric
import Crashlytics
import CoreBluetooth
import AVKit
import AVFoundation
import MediaPlayer
import UserNotifications
import AudioToolbox


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



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate,AVAudioRecorderDelegate{
    
    var window: UIWindow?
    var progressHud: MBProgressHUD!
    let storyboard = UIStoryboard ( name: "Main" , bundle: nil)
    let locationManager = CLLocationManager()
    var notificationCount:Int! = 0
    
    
    var recorder: AVAudioRecorder!
    var soundFileURL:URL!
    var meterTimer:Timer!
    var stopTimer:Timer!
    
    // BLE
    var centralManager : CBCentralManager!
    var connectedPeripheral:CBPeripheral!
    var characteristic:CBCharacteristic!
    
    var peripheralManager : CBPeripheralManager!
    var connectedCentral: CBCentral!
    var requestSend: CBATTRequest!
    
    
    var addDevice:NewAddDeviceViewController!
    
    var playAlert: AudioListViewController = AudioListViewController()
    var badge = 0
    var from = ""
    var counter = 0
    var counterRssi = 0
    var deviceDetect = false
    var timer:Timer!
    var timer2: Timer!
    var enableBluetoothView:UIView!
    
    var deviceConnected = NSMutableArray()
    var deviceConnectedDict = NSMutableDictionary()
    
    var aps:NSDictionary!
    //    var notificationCount = 0
    var firstTimeLocation = true
    var lastLocation:CLLocation!
    var detectId: HomeViewController!
    
    var battery: String = "0"
    var taps: String = "2"
    var connectedDeviceBatteryDictionary = NSMutableDictionary()
    var connectedDeviceDictionary = NSMutableDictionary()
    //var tapChar: CBCharacteristic
    // variables for rssi
    var rssi: Double!
    var txPower: Int! = -67
    var distance: Double = 0.0
    var isLoggedOut:Bool = false
    
    var lat: CLLocationDegrees!
    var long:CLLocationDegrees!
    
    // var devName: String!
    var player: AVQueuePlayer!
    var audioPlayer: AVAudioPlayer!
    var sound = String()
    
    var isDisconnected = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        application.applicationIconBadgeNumber = 0;
        
        
        if (UserDefaults.standard.object(forKey: "login") != nil)
        {
            
            if (UserDefaults.standard.value(forKey: "login") as! Bool) == false
            {
                let viewController: DummyViewController = storyboard.instantiateViewController(withIdentifier: "DummyViewController") as! DummyViewController
                
                // Then push that view controller onto the navigation stack
                let rootViewController = self.window!.rootViewController as! UINavigationController
                
                rootViewController.pushViewController(viewController, animated: false)
            }
            else
            {
                let viewController: HomeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                
                // Then push that view controller onto the navigation stack
                let rootViewController = self.window!.rootViewController as! UINavigationController
                rootViewController.pushViewController(viewController, animated: false)
            }
        }
        
        
        locationManager.delegate = self;
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        locationManager.distanceFilter = kCLDistanceFilterNone;
        
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
                if #available(iOS 11.0, *){
                    
                }
            }
            
            
        } else {
            // Fallback on earlier versions
        }
        
        locationManager.startUpdatingLocation()
        
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:)))
         {
            
            if #available(iOS 8.0, *) {
                let types:UIUserNotificationType = ([.alert, .badge, .sound])
                let settings = UIUserNotificationSettings(types: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                
                application.registerForRemoteNotifications()
                
            } else {
                // Fallback on earlier versions
                application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
            }
            
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
            
        }
        
//        self.centralManager = nil
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:false,CBCentralManagerScanOptionAllowDuplicatesKey:false])
        
        
        
        return true
    }
    
    
    
    //MARK: Push notification functions
    //MARK:
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("Got token data! (deviceToken)")
        var pushToken = String(format: "%@", deviceToken as CVarArg)
        pushToken = pushToken.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        pushToken = pushToken.replacingOccurrences(of: " ", with: "")
        UserDefaults.standard.setValue(pushToken, forKey: "device_token")
        UserDefaults.standard.synchronize()
        print(pushToken)
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
         AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
         UIApplication.shared.applicationIconBadgeNumber = badge + 1
        
        var alert = UIAlertView()
        
        if  let apsTemp = userInfo["aps"] as? NSDictionary
        {
            self.aps = apsTemp
            print(self.aps)
            let state = UIApplication.shared.applicationState
            
            if self.aps.object(forKey: "action") as! NSString == "alert"
            {

                
                if state == .active
                {
                    alert = UIAlertView(title: "Alert!", message: (aps.object(forKey: "message") as! NSString) as String, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "View")
                    alert.tag = 1001
                    
                    alert.show()
                    
                }
                else
                {
                    let notificationDetail = storyboard.instantiateViewController(withIdentifier: "EmergencyReceiverViewController") as! EmergencyReceiverViewController
                    
                    let tempId = self.aps.object(forKey: "alert_id") as! Int
                    
                    notificationDetail.alert_id = Int(tempId)
                    
                    
                    // Then push that view controller onto the navigation stack
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    
                    rootViewController.pushViewController(notificationDetail, animated: false)
                }
                
            }
            if aps.object(forKey: "action") as! NSString == "cancel"
            {
                if state == .active
                {
                    alert = UIAlertView(title: "Alert!", message: (aps.object(forKey: "message") as! NSString) as String, delegate: self, cancelButtonTitle: "Ok")
                    
                    alert.tag = 1002
                    
                    alert.show()
                    
                }
                else
                {
                    
                }
                
            }
            
            if aps.object(forKey: "action") as! NSString == "safe"
            {
                if state == .active
                {
                    alert = UIAlertView(title: "Alert!", message: (aps.object(forKey: "message") as! NSString) as String, delegate: self, cancelButtonTitle: "Ok")
                    
                    alert.tag = 1002
                    
                    alert.show()
                    
                }
                else
                {
                    
                }
                
            }
            else{
                
                if state == .active
                {
                    alert = UIAlertView(title: "Alert!", message: (aps.object(forKey: "message") as! NSString) as String, delegate: self, cancelButtonTitle: "Ok")
                    
                    alert.tag = 1002
                    
                    alert.show()
                    
                }
            }
            
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    
    //MARK: Remote Notification Handeling new method
    
    private func getAlert(notification: [NSObject:AnyObject]) -> (String, String) {
        
        let title = ""
        let body = ""
        
        return (title ?? "-", body ?? "-")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if firstTimeLocation == true
        {
            
            self.lastLocation = locations.last!
            firstTimeLocation = false
        }
        if (locations.last!).distance(from: self.lastLocation) > 300
        {
            lastLocation = locations.last!
            
            self.loactionUpdate()
        }
        
         self.lat = manager.location?.coordinate.latitude
         self.long = manager.location?.coordinate.longitude

    }
 
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
         UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 1001{
            if buttonIndex == 1{
                
                let notificationDetail = storyboard.instantiateViewController(withIdentifier: "EmergencyReceiverViewController") as! EmergencyReceiverViewController
                
                let tempId = aps.object(forKey: "alert_id") as! Int
                
                notificationDetail.alert_id = Int(tempId)
                // Then push that view controller onto the navigation stack
                let rootViewController = self.window!.rootViewController as! UINavigationController
                
                rootViewController.pushViewController(notificationDetail, animated: false)
                
            }
            
        }else if alertView.tag == 1002{
            if buttonIndex == 1{
                
                let destinationViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                let navigationController = self.window?.rootViewController as! UINavigationController
                navigationController.pushViewController(destinationViewController, animated: false)
            }
            
        }
    }
    
    
    
    
    //MARK: Local Notification Methods
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Do something serious in a real app.
        
        application.applicationIconBadgeNumber = 0
        
        print("Received Local Notification:")
        if notification.alertBody! == "Call Trouble"
        {
            
            
            if #available(iOS 8.0, *) {
                
                if UserDefaults.standard.object(forKey: "defaultNumber") != nil
                {
                    let phoneNumber = "tel://".appending(UserDefaults.standard.object(forKey: "defaultNumber")! as! String)
                    print(phoneNumber)
                    UIApplication.shared.openURL(URL(string: phoneNumber)!)
                    
                    print("calling")
                }
                else{
                                        
                }
                
                
            } else {
                // Fallback on earlier versions
            }
        }
        else
        {
//            self.audioPlayerCondition()
        }
        
        print(notification.alertBody!)
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        // Play a sound.
        completionHandler(UNNotificationPresentationOptions.sound)
    }
 
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        if identifier == "editList" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "modifyListNotification"), object: nil)
        }
        else if identifier == "trashAction" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "deleteListNotification"), object: nil)
        }
        
        completionHandler()
    }
    
    
    
    
    //MARK: MBProgressHUD Functions
   
    
    func showProgressHudForViewMy (_ view:AnyObject, withDetailsLabel:NSString, labelText:NSString)
    {
        progressHud = MBProgressHUD.showAdded(to: self.window, animated: true)
        progressHud.mode = MBProgressHUDMode.indeterminate
        progressHud.detailsLabelText = withDetailsLabel as String
        progressHud.labelText = labelText as String
        
    }
    func showMessageHudWithMessage(_ message:NSString, delay:CGFloat)
    {
        progressHud = MBProgressHUD.showAdded(to: self.window, animated: true)
                progressHud.mode = MBProgressHUDMode.text
        progressHud.detailsLabelText = message as String
        let delay = TimeInterval(delay)
        [progressHud .hide(true, afterDelay: delay)]
    }
    func hideProgressHudInView(_ view:AnyObject)
    {
        if progressHud != nil
        {
//            [hud .hide(true)]
            progressHud.hide(true)
            progressHud = nil
        }
    }
    
    func next()
    {
        
        if (UserDefaults.standard.value(forKey: "dummy") as! Bool) == true
        {
            let viewController: LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            // Then push that view controller onto the navigation stack
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            rootViewController.pushViewController(viewController, animated: false)
            
            UserDefaults.standard.set(false, forKey: "dummy")
        }
        
    }
    
    
    func hasConnectivity() -> Bool
    {
        let reachability: Reachability = Reachability.forInternetConnection()
        let networkStatus: NetworkStatus = reachability.currentReachabilityStatus()
        return networkStatus != NetworkStatus.NotReachable
    }
    
    
    //MARK: Function called from add device page.
    //MARK:
    /**
     This function called from add device page.
     - parameter btView:      UIView
     */
    
    func fromAddDev(_ btView:UIView)
    {
        from = "add"
        isDisconnected = false
        
         addDevice.deviceArray.removeAllObjects()
        // Initialize central manager on load
        //        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //        myCentralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "myCentralManagerIdentifier"])
    
         self.enableBluetoothView = btView
        
        self.centralManagerDidUpdateState(centralManager)
        
    }
    
    func fromHome()
    {
        from = "home"
        
        isDisconnected = false
        
       if self.peripheralManager != nil
        {
            if self.peripheralManager.isAdvertising
            {
                self.peripheralManager.stopAdvertising()
                self.peripheralManager = nil
            }
        }
        
        self.bleServer()
            
        self.centralManagerDidUpdateState(centralManager)
    }
    
    func timerDisconnect()
    {
        
        self.timer.invalidate()
        
        self.centralManager.stopScan()
    }
    
    func timerAction() {
        if counter < 20
        {
            counter += 1
        }
        else if counter == 20
        {
            
            timer.invalidate()
            
            if addDevice.deviceArray.count > 0
            {
                addDevice.noRecordsFound.isHidden = true
            }
            else{
                addDevice.noRecordsFound.isHidden = false
            }
            
            //            hideProgressHudInView(true as AnyObject)
            
        }
    }
    
    func timerRssi() {
        if counterRssi < 30
        {
            counterRssi += 1
        }
        else if counterRssi == 30
        {
            //distanceRssi()
            
            // counterRssi = 0
            connectedPeripheral.readRSSI()
        }
    }
    
    //MARK: Advertisement Data Method
    
    func bleServer()
    {
        // Initialize peripheral central manager on load
        
                self.peripheralManager = nil
        
                self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
//        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionRestoreIdentifierKey: "myPeripheralManagerIdentifier"])
        
    }
    
    
    //MARK:- bluetooth delegate func
    
    //if Bluetooth is available (as in "turned on"), you can start scanning for devices.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch(central.state)
        {
        case .unsupported:
            print("Unsupported")
        case .unauthorized:
            print("unauthorized")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        case .poweredOff:
            print("Power off")
            
            if self.enableBluetoothView != nil
            {
                self.enableBluetoothView.isHidden = false
            }
            //
            if from == "add"
            {
                self.enableBluetoothView.isHidden = false
                
                self.hideProgressHudInView(self)
            }
            else
            {
                self.deviceConnectedDict.removeAllObjects()
                
                if detectId != nil
                {
                     detectId.tableView.reloadData()
                }
                
                
            }
            
        case .poweredOn:
            
            
            if from == "add"
            {
                
                print("Start Scanning")
                self.enableBluetoothView.isHidden = true
                
                self.centralManager.scanForPeripherals(withServices: [CBUUID(string: "1802"),
                    CBUUID(string: "180F"),
                    CBUUID(string: "1804")], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
//                central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
                
                counter = 0
                
                // start the timer
                
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
                
                //                showProgressHudForViewMy(addDevice, withDetailsLabel: "Please wait", labelText: "Searching...")
            }
            else if from == "home"
            {
                
                print("Start Scanning")
                
                if isDisconnected == true
                {
                    isDisconnected = false
                    timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(timerDisconnect), userInfo: nil, repeats: true)
                }
                else
                {
                    timer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(timerDisconnect), userInfo: nil, repeats: true)
                }
//                central.scanForPeripherals(withServices: nil, options:[CBCentralManagerScanOptionAllowDuplicatesKey:false])
                
                self.centralManager.scanForPeripherals(withServices: [CBUUID(string: "1802"),
                                                          CBUUID(string: "180F"),
                                                          CBUUID(string: "1804")], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
            }
            else
            {
                
            }
        default:
            print(central.state)
            
        }
    }
    
    
    //find the device you are interested in interacting with
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        self.connectedPeripheral = peripheral
        self.self.connectedPeripheral.delegate = self;
        
//        peripheral.delegate = self;
        print(connectedPeripheral);
        
        let nameOfDeviceFound = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
        
        
        if (nameOfDeviceFound != nil) {
            
            print("Device found = \(nameOfDeviceFound!)")
            
            if from == "add"
            {
                if (!(addDevice.deviceArray.contains(peripheral)))
                {
                    
                    if (nameOfDeviceFound?.contains("IVY"))!
                    {
                        addDevice.deviceArray.add(peripheral)
                        
                        hideProgressHudInView(true as AnyObject)
                        
                        print(addDevice.deviceArray)
                        
                        addDevice.noRecordsFound.isHidden = true
                        
                        addDevice.tableView.reloadData()
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "addedDevice"), object: nil)
                    }
                    
                }
            }
            else if from == "home"
            {
                if (nameOfDeviceFound?.contains("IVY"))!
                {
                    
                    self.timer.invalidate()
                    
                    if detectId != nil
                    {
                        
                        
                        if detectId.DeviceList.count > 0
                        {
                            for i in 0..<detectId.DeviceList.count
                            {
                                let listUuid = (detectId.DeviceList.object(at: i) as AnyObject).object(forKey: "unique_name") as! String
                                
                                let mac_id = (detectId.DeviceList.object(at: i) as AnyObject).object(forKey: "mac_address") as! String
                                
                                
                                
                                print(peripheral.identifier.uuidString)
                                
                                print("\(peripheral.name!) : \(RSSI) dbm")
                                
//                                if listUuid == peripheral.identifier.uuidString
//                                {
//                                    //                                                distanceRssi()
//                                    // Set as the peripheral to use and establish connection
//                                    
//                                    self.centralManager.connect(connectedPeripheral, options: nil)
//                                }
                                if listUuid == nameOfDeviceFound
                                {
                                    let data_deviceTemp = detectId.DeviceList.object(at: i) as! NSDictionary
                                    
                                    let data_device = data_deviceTemp.mutableCopy() as! NSMutableDictionary
                                    
                                    if mac_id != peripheral.identifier.uuidString
                                    {
                                        data_device.setObject("\(peripheral.identifier.uuidString)", forKey: "mac_address" as NSCopying)
                                        detectId.DeviceList.replaceObject(at: i, with: data_device)
                                    }
                                    
                                    //                                                distanceRssi()
                                    // Set as the peripheral to use and establish connection
                                    if peripheral.state == .connected
                                    {
                                        
                                    }
                                    else
                                    {
                                            self.centralManager.connect(self.connectedPeripheral, options: nil)
//                                        self.centralManager.connect(peripheral, options: nil)
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }
                print(peripheral)
            }
            else
            {
                
            }
        }
            
        else {
            print("Sensor Tag NOT Found")
        }
        
    }
    
    //get a list of services on that device.
    // Discover services of the peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Discovering peripheral services")
        
        peripheral.readRSSI()
        
        //        peripheral.delegate = self;
                if self.deviceConnected.contains(peripheral)
                {
        
                }else
                {
                     self.deviceConnected.add(peripheral)
                }
        
        connectedDeviceDictionary.setObject(peripheral, forKey: "\(peripheral.identifier.uuidString)" as NSCopying)
        
        deviceConnectedDict.setObject("connected", forKey: "\(peripheral.name!)" as NSCopying)
        
        
        detectId.tableView.reloadData()
        
        peripheral.discoverServices(nil)
        
        if self.peripheralManager != nil
        {
            if self.peripheralManager.isAdvertising
            {
                
            }
            else
            {
                self.bleServer()
            }
        }
        else
        {
            self.bleServer()
        }
        
        
        print(peripheral)
    }
    
    //list of the characteristics
    func peripheral(_ peripheral: CBPeripheral,didDiscoverServices error: Error?) {
        
        if error != nil{
            print("error!.description")
        }
        else {
            
            for service in peripheral.services as [CBService]!{
                print(service)
                //need to discover characteristics
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
        }
    }
    
    //setup notification
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // update status label
        print("Enabling sensors")
        
        if error != nil{
            print("error!.description")
        }
        else {
            
            print(service.uuid)
            
            
            if (service.uuid == CBUUID(string: "1802")) || (service.uuid == CBUUID(string: "180F")) || (service.uuid == CBUUID(string: "1804")){
                
                // check the uuid of each characteristic to find config and data characteristics
                for characteristic in service.characteristics! as [CBCharacteristic]{
                    
                    
                    
                    print(characteristic)
                    
                    // check for data characteristic
                    switch characteristic.uuid.uuidString {
                   
                        
                    case "2A19":
                        
                        // Enable Sensor Notification for battery notification
                        
                        print("Found Battery Level Characteristic")
                        
                        peripheral.setNotifyValue(true, for: characteristic)
//                        self.connectedPeripheral.setNotifyValue(true, for: characteristic)
                        
//                        self.connectedPeripheral.readValue(for: characteristic)
                        
                    default:
                        break
                    }
                    
                }
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print(peripheral)
        print(characteristic)
        print(characteristic.value)
        
        if characteristic.uuid.uuidString == "2A19"
        {
            if characteristic.value?.description != nil
            {
                var buffer = [UInt8](repeating: 0x00, count: characteristic.value!.count)
                (characteristic.value! as NSData).getBytes(&buffer, length: buffer.count)
                
                print(buffer)
                
                battery = String(describing: buffer)
                
                battery = battery.replacingOccurrences(of: "[", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                battery = battery.replacingOccurrences(of: "]", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                print(battery)
                
                self.connectedDeviceBatteryDictionary.setObject("\(battery)", forKey: "\(peripheral.name!).battery" as NSCopying)
                
                if Int(battery) < 15
                {
//                    let localNotification = UILocalNotification()
//                    localNotification.fireDate = Date(timeIntervalSinceNow: 5)
//                    localNotification.alertBody = "Battery Less than 15%"
//                    localNotification.timeZone = TimeZone.current
//                    localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
//                    UIApplication.shared.scheduleLocalNotification(localNotification)
                }
            }
            
            deviceDetect = true
            
           
                detectId.tableView.reloadData()
            
            
            
            
        }
        
    }
    
    
    //Changes Are Coming
    //Any characteristic changes you have setup to receive notifications for will call this delegate method. You will want to be sure and filter them out to take the appropriate action for the specific change.
    func peripheral(_ peripheral: CBPeripheral,didUpdateValueFor characteristic: CBCharacteristic,error: Error?) {
        
        print(peripheral)
        
        print(characteristic)
        
        print(characteristic.value)
        
         if characteristic.uuid.uuidString == "2A19"
        {
            if characteristic.value?.description != nil
            {
                var buffer = [UInt8](repeating: 0x00, count: characteristic.value!.count)
                (characteristic.value! as NSData).getBytes(&buffer, length: buffer.count)
                
                print(buffer)
                
                battery = String(describing: buffer)
               
                battery = battery.replacingOccurrences(of: "[", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                battery = battery.replacingOccurrences(of: "]", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                print(battery)
                
                self.connectedDeviceBatteryDictionary.setObject("\(battery)", forKey: "\(peripheral.name!).battery" as NSCopying)
                
                if Int(battery) < 15
                {
//                    let localNotification = UILocalNotification()
//                    localNotification.fireDate = Date(timeIntervalSinceNow: 5)
//                    localNotification.alertBody = "Battery Less than 15%"
//                    localNotification.timeZone = TimeZone.current
//                    localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
//                    UIApplication.shared.scheduleLocalNotification(localNotification)
                }
                deviceDetect = true
                
               
                    detectId.tableView.reloadData()
               
            }
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        print("fail to connect")
        
        self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    //Disconnect and Try Again
    func centralManager(_ central: CBCentralManager,didDisconnectPeripheral peripheral: CBPeripheral,error: Error?) {
        
        self.isDisconnected = true
        
        let state = UIApplication.shared.applicationState
        
        if state != .active 
        {
            print("isDisconnected")
            
            central.connect(peripheral, options: nil)
            
            print("Connecting")
        }
        else
        {
            if self.isLoggedOut != false{
                self.centralManager.stopScan()
            }else{
                
                if detectId != nil
                {
                   if detectId.DeviceList.count > 0
                    {
                        for i in 0..<detectId.DeviceList.count
                        {
                            let listUuid = (detectId.DeviceList.object(at: i) as AnyObject).object(forKey: "unique_name") as! String
                            
                            print("\(peripheral.name!) ")
                            
//                             self.connectedPeripheral = peripheral
                         
                            if listUuid == peripheral.name!
                            {
                                 central.connect(peripheral, options: nil)
                               
                            }
                        }
                        
                    }
                }
   
//                 self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
            }
           
        }
        
        
        
        if connectedDeviceDictionary.object(forKey: "\(peripheral.identifier.uuidString)" as NSCopying) != nil
        {
            connectedDeviceDictionary.removeObject(forKey: "\(peripheral.identifier.uuidString)" as NSCopying)
        }
        
        if connectedDeviceDictionary.count == 0
        {
//            if self.peripheralManager != nil
//            {
//                if self.peripheralManager.isAdvertising
//                {
//                    self.peripheralManager.stopAdvertising()
//                    self.peripheralManager = nil
//                }
//            }
        }
        
        if self.connectedDeviceBatteryDictionary.object(forKey: "\(peripheral.name!).battery") != nil
        {
             self.connectedDeviceBatteryDictionary.removeObject(forKey: "\(peripheral.name!).battery")
        }
        
        if self.deviceConnected.contains(peripheral)
        {
            self.deviceConnected.remove(peripheral)
        }
        
        deviceConnectedDict.setObject("disconnectd", forKey: "\(peripheral.name!)" as NSCopying)
        
        
        
        deviceDetect = false
        
        if self.timer2 != nil
        {
            self.timer2.invalidate()
        }
        
        battery = "0"
        
        distance = 0.0
        
       
            detectId.tableView.reloadData()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print(characteristic)
        
    }
    
    //Reading rssi value
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        rssi = Double("\(RSSI)")
        
        print("RSSI = \(RSSI)")
        
        //        distanceRssi()
        
        counterRssi = 0
        
        // start the timer
        //        self.timer2 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRssi), userInfo: nil, repeats: true)
        
        //        detectId.tableView.reloadData()
        // peripheral.readRSSI()
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        
        peripheral.readRSSI()
    }
    
    //MARK:- cbperipheral Manager delegates
    
    // Advertise
    // Receive the update of peripheral manager’s state. **Required**
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("peripheralManagerDidUpdateState")
        
        if peripheral.state != .poweredOn {
            return
        }
        
       
        let transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "2A06"), properties: .writeWithoutResponse, value: nil, permissions: .writeable)
        
        // Then the service
        let transferService = CBMutableService(type: CBUUID(string: "1802"), primary: true)
        
        
        // Add the characteristic to the service
        transferService.characteristics = [transferCharacteristic]
        
        
        self.peripheralManager.add(transferService)
        
        
        self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [transferService.uuid]])
        
    }
    
    //    //Receive the result of starting to advertise.
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("peripheralManagerDidStartAdvertising")
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        print("Succeeded!")
        
        
        
        // Stop advertising.
        // peripheralManager.stopAdvertising()
    }
    //
    //
    //    //    Receive the result of adding a service.
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("didAddService")
        
        if let error = error {
            print("error: \(error)")
            return
        }
        else {
            // Add characteristics to a service.
            //            services.characteristics = [transfer_cha`racteristic]
            
            
            print(service)
            print(service.characteristics)
            
            if (error != nil) {
                print("PerformerUtility.publishServices() returned error: \(error!.localizedDescription)")
                print("Providing the reason for failure: \(error!)")
            }
            else {
                //                peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.uuid]])
                
            }
            
            //
            
        }
    }
    //
    //    Respond to Read requests
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        print("didReceiveReadRequest")
        
        if request.characteristic.uuid.uuidString == "2A06"
        {
            // Set the correspondent characteristic's value
            // to the request
            request.value = characteristic.value
            
            // Respond to the request
            peripheralManager.respond(
                to: request,
                withResult: .success)
        }
        
        
    }
    //
    //   //    Respond to Write requests
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        print("didReceiveWriteRequests")
        
        let array = requests.description.components(separatedBy: "identifier =")
        
        let array2 = array[1].components(separatedBy: ",")
        
        let identifier = array2[0].trimmingCharacters(in: .whitespaces)
      
        
        if connectedDeviceDictionary.object(forKey: "\(identifier)" as NSCopying) != nil
        {
            for request in requests
            {
                if request.characteristic.uuid.uuidString == "2A06"
                {
                    // Set the request's value
                    // to the correspondent characteristic
                    let state = UIApplication.shared.applicationState
                    
                    print(request.value)
                    
                    var buffer = [UInt8](repeating: 0x00, count: request.value!.count)
                    (request.value! as NSData).getBytes(&buffer, length: buffer.count)
                    
                    let value =  request.value(forKey: "value")!
                    
                    
                    self.taps = String(describing: value)
                    
                    self.taps = taps.replacingOccurrences(of: "<", with: "", options: NSString.CompareOptions.literal, range: nil)
                    
                    self.taps = taps.replacingOccurrences(of: ">", with: "", options: NSString.CompareOptions.literal, range: nil)
                    
                    print(self.taps)
                    
                    
                    
                    if state != .active
                    {
                        if self.taps == "02"
                        {
//                            self.audioPlayerCondition()
                            
                            self.sound = self.playAlert.listOfSounds[(Int(UserDefaults.standard.object(forKey: "defaultRingtone") as! String))!]
                            
//                            self.setupNotificationSettings()
                            
                            let localNotification = UILocalNotification()
                            
                            localNotification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
                            
                            localNotification.alertBody = "Trouble"
                            
                            localNotification.alertAction = "sound"
                            
                            localNotification.soundName = "\(sound).aiff"
                            
                          //  localNotification.soundName = "emergency_1.aiff"
//                             localNotification.performSelector(inBackground: #selector(AppDelegate.audioPlayerCondition), with: nil)
                            
                            localNotification.timeZone = NSTimeZone.default
                            
                             UIApplication.shared.scheduleLocalNotification(localNotification)
                          
                            
                        }
                        else if self.taps == "03"
                        {
                            self.sendAlert()
                        }
                        else if self.taps == "04"
                        {
                            
//                            
//                            let localNotification = UILocalNotification()
//                            
//                            localNotification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
//                            
//                            localNotification.alertBody = "Call Trouble"
//                            
//                            localNotification.alertAction = "call"
//                            
//                
//                            
//                            localNotification.timeZone = NSTimeZone.default
//                            
//                            UIApplication.shared.scheduleLocalNotification(localNotification)

                            self.sendCall()
                        }
                        
                    }
                    else
                    {
                        if self.taps == "02"
                        {
                            
                            detectId.twoTapsDone()
                        }
                        else if self.taps == "03"
                        {
                            if self.audioPlayer != nil
                            {
                                if self.audioPlayer.isPlaying == true
                                {
                                    self.audioPlayer.pause()
                                }
                            }
                            detectId.threeTapsDone()
                        }
                        else if self.taps == "04"
                        {
                            if self.audioPlayer != nil
                            {
                                if self.audioPlayer.isPlaying == true
                                {
                                    self.audioPlayer.pause()
                                }
                            }
                            
//                            self.sendCall()
                           detectId.fourTapsDone()
                            
                        }
                    }
                    
                    
                    
                }
            }
        }
        else
        {
            
            //            self.centralManager.cancelPeripheralConnection(peripheral)
        }
        
        peripheralManager.respond(to: requests[0], withResult: .success)
    }
    
    //    Respond to Notifications/Indications
    //    Receive subscribe requests.
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeToCharacteristic")
        //   print("subscribed centrals: \( characteristic.subscribedCentrals)")
        //  peripheral.updateValue("1".data(usingEncoding: String.Encoding.utf8)!, for: readChar, onSubscribedCentrals: nil)
        
    }
    
    //    Receive unsubscribe requests.
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribeToCharacteristic")
        //   print("subscribed centrals: \(characteristic.subscribedCentrals)")
        
    }
    
//    private func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
//        print("will restore state")
//        
//    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReadyToUpdateSubscribers")
        
        // peripheralManager.updateValue(characteristic.value, forCharacteristic: , onSubscribedCentrals:  )
    }
    
    
//    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
//        print(dict)
//    }
    
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        print(dict)
//    }
    
    //MARK:- helpng func
    func distanceRssi()
    {
        // to calculate distance with respect to rssi.
        if rssi == 0 {
            // if we cannot determine accuracy, return -1.
            distance = -1.0
            print(-1.0)
        }
        
        let ratio: Double = rssi * 1.0 / Double(txPower);
        if (ratio < 1.0) {
            distance = pow(ratio, 10)
            print(distance)
        }
        else {
            let accuracy: Double = (0.89976) * pow(ratio, 7.7095) + 0.111;
            distance = accuracy
            print(distance)
        }
        
    }
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.shared.currentUserNotificationSettings
        
        if (notificationSettings.types == []){
            // Specify the notification types.
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
            
            
            // Specify the notification actions.
            let justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "OK, got it"
            justInformAction.activationMode = UIUserNotificationActivationMode.background
            justInformAction.isDestructive = false
            justInformAction.isAuthenticationRequired = false
            
            let modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "Edit list"
            modifyListAction.activationMode = UIUserNotificationActivationMode.foreground
            modifyListAction.isDestructive = false
            modifyListAction.isAuthenticationRequired = true
            
            let trashAction = UIMutableUserNotificationAction()
            trashAction.identifier = "trashAction"
            trashAction.title = "Delete list"
            trashAction.activationMode = UIUserNotificationActivationMode.background
            trashAction.isDestructive = true
            trashAction.isAuthenticationRequired = true
            
            let actionsArray = NSArray(objects: justInformAction, modifyListAction, trashAction)
            let actionsArrayMinimal = NSArray(objects: trashAction, modifyListAction)
            
            // Specify the category related to the above actions.
            let shoppingListReminderCategory = UIMutableUserNotificationCategory()
            shoppingListReminderCategory.identifier = "shoppingListReminderCategory"
            shoppingListReminderCategory.setActions(actionsArray as? [UIUserNotificationAction], for: UIUserNotificationActionContext.default)
            shoppingListReminderCategory.setActions(actionsArrayMinimal as? [UIUserNotificationAction], for: UIUserNotificationActionContext.minimal)
            
            
            let categoriesForSettings = NSSet(objects: shoppingListReminderCategory)
            
            
            // Register the notification settings.
            let newNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: categoriesForSettings as? Set<UIUserNotificationCategory>)
//            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings)
            UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
    
    // MARK: AVAudioPlayerDelegate
    //Audio player func
    func audioPlayerCondition()
    {
        audioPlayer = nil
        
        let session = AVAudioSession.sharedInstance()
        do {
            //            try session.setCategory(AVAudioSessionCategoryPlayback)
            if #available(iOS 10.0, *) {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            } else {
                // Fallback on earlier versions
            }
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }

        
        // Construct URL to sound file
        let soundUrl = URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!)
        
        //        let avSongItem = AVPlayerItem(url: soundUrl)
        //
        //        self.player = AVQueuePlayer(items: [avSongItem])
        //
        //
        //        self.player.actionAtItemEnd = .advance
        //
        //        self.player.play()
        
        // Create audio player object and initialize with URL to sound
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
            self.audioPlayer.delegate = self
        }
        catch let error {
            print(error)
        }
        
        //        if #available(iOS 10.0, *) {
        //            self.audioPlayer.setVolume(1.0, fadeDuration: 0)
        //        } else {
        //             self.audioPlayer.volume = 1.0
        //            // Fallback on earlier versions
        //        }
        
                self.audioPlayer.volume = 1.0
        
        self.audioPlayer.play()
        print("Playing")
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        print("finished playing ")
        detectId.dismiss(animated: true, completion: nil)
        //        detectId.alert.dismiss(animated: true, completion: nil)
        //           detectId.alert.removeFromParentViewController()
        
        //        self.audioPlayer.play()
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            //            print("\(e.localizedDescription)")
        }
        
    }
    
    
    //MARK: Audio Recording Method
    
    func recordWithPermission(_ setup:Bool) {
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    
                    
//                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
//                                                           target:self,
//                                                           selector:#selector(AudioRecordViewController.updateAudioMeter(_:)),
//                                                           userInfo:nil,
//                                                           repeats:true)
                    
                    
                    
                    self.stopTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                          target:self,
                                                          selector:#selector(AppDelegate.stopAudioMeter),
                                                          userInfo:nil,
                                                          repeats:false)
                    
                } else {
                    
                    
                    print("Permission to record not granted")
                }
            })
        } else {
            
            //            self.sendAlert()
            
            print("requestRecordPermission unrecognized")
        }
    }
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).AAC"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 320000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
//            try session.setCategory(AVAudioSessionCategoryPlayback)
           try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .mixWithOthers)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
//    
//    func updateAudioMeter(_ timer:Timer) {
//        
//        if recorder.isRecording {
//            let min = Int(recorder.currentTime / 60)
//            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
//            let s = String(format: "%02d:%02d", min, sec)
//            
//            recorder.updateMeters()
//            
//            
//            // if you want to draw some graphics...
//            //var apc0 = recorder.averagePowerForChannel(0)
//            //var peak0 = recorder.peakPowerForChannel(0)
//        }
//    }
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        print("finished recording \(flag)")
        
        
        self.sendAlert()
        
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
    /**
     To stop audio recording meter.
     */
    func stopAudioMeter() {
        
        print("stop")
        
        
        if recorder != nil
        {
            recorder?.stop()
        }
        if meterTimer != nil{
            meterTimer.invalidate()
        }
        if stopTimer != nil{
            
            stopTimer.invalidate()
        }
        
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            
            //            recordButton.enabled = true
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        
        // if you want to draw some graphics...
        //var apc0 = recorder.averagePowerForChannel(0)
        //var peak0 = recorder.peakPowerForChannel(0)
    }
    
    
    
    
    func sendAlert()
    {

      if appdelegate.hasConnectivity()
        {
            
            if UserDefaults.standard.object(forKey: "contact_number") != nil
            {
                if let ContactArray = UserDefaults.standard.object(forKey: "contact_number") as? NSArray
                {
                    if ContactArray.count > 0
                    {
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
                        
                       let param = NSMutableDictionary()
                        
                        param.setObject("\((user_id)!)", forKey: "user_id" as NSCopying)
                        param.setObject("\((05))", forKey: "audio_duration" as NSCopying)
                        param.setObject("", forKey: "mode" as NSCopying)
                        param.setObject("2", forKey: "device_type" as NSCopying)
                        
                       if lat != nil
                        {
                            param.setObject("\(String(lat!))", forKey: "latitude" as NSCopying)
                        }
                        else
                        {
                            param.setObject("", forKey: "latitude" as NSCopying)
                        }
                        if long != nil
                        {
                            param.setObject("\(String(long!))", forKey: "longitude" as NSCopying)
                            
                        }
                        else
                        {
                            param.setObject("", forKey: "longitude" as NSCopying)
                        }
                        
                        print(param)
                        
                         let url="\(base_URL)\(sendAlert_URL)"
                        
                        manager.post("\(url)",
                            parameters: param,progress: nil,
                            
                            success: {
                                
                                (task, responseObject) in
                                
                                print(responseObject)
                                
                           },
                            failure: { (operation: URLSessionTask?,
                                error: Error!) in
                                print("ERROR")
                                
//                                let msg:AnyObject = "Failed due to an error" as AnyObject
                        })
                    }
                    else
                    {
//                        self.showMessageHudWithMessage("You haven't added any Guardian yet. Goto Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
                    }
                }
                else
                {
//                    self.showMessageHudWithMessage("You haven't added any Guardian yet. Goto Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
                }
            } else
            {
//                self.showMessageHudWithMessage("You haven't added any Guardian yet. Goto Manage Contacts from Settings section to add Guardian contact.", delay: 4.0)
            }
            
            
           
            
        }
                else
                {

                }
        
    }
    
 
    //MARK:- Visible Controller Method
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        var rootViewController = rootViewController
        
        if rootViewController == nil {
            rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if ((rootViewController?.isKind(of: UINavigationController.self)) != nil)
        {
            let navigationController = (rootViewController as! UINavigationController).viewControllers.last
            return navigationController
        }
        
        if let presented = rootViewController?.presentedViewController {
            if presented.isKind(of: UIImagePickerController.self)
            {
                return presented
            }
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
    
    //MARK:- Location update method
    
    func loactionUpdate()
    {
        if self.hasConnectivity()
        {
            
            
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
            
            let lat = self.locationManager.location?.coordinate.latitude
            let long = self.locationManager.location?.coordinate.longitude
           
            let param = NSMutableDictionary()
            
            param.setObject("\((user_id)!)", forKey: "user_id" as NSCopying)
          
            if lat != nil
            {
                param.setObject("\(String(lat!))", forKey: "lat" as NSCopying)
                
            }
            else
            {
                param.setObject("", forKey: "lat" as NSCopying)
            }
            if long != nil
            {
                param.setObject("\(String(long!))", forKey: "long" as NSCopying)
                
            }
            else
            {
                param.setObject("", forKey: "long" as NSCopying)
            }
            
            print(param)
           
            let url="\(base_URL)\(locationUpdate_URL)"
            
            manager.post("\(url)",
                parameters: param,progress: nil,
                
                success: {
                    
                    (task, responseObject) in

                    
                },
                failure: {(operation: URLSessionTask?, error: Error) -> Void in
                    print("Error: \(error)")
                    print("ERROR")
                    
            })
        }
    }
    
 func sendCall()
 {
    if self.hasConnectivity()
    {
        
        
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
        
        let param = NSMutableDictionary()
        let lat = self.locationManager.location?.coordinate.latitude
        let long = self.locationManager.location?.coordinate.longitude
        param.setObject("\((user_id)!)", forKey: "id_user" as NSCopying)
        if lat != nil
        {
            param.setObject("\(String(lat!))", forKey: "lat" as NSCopying)
            
        }
        else
        {
            if self.lat != nil
            {
                param.setObject("\(self.lat!)", forKey: "lat" as NSCopying)
            }
            else
            {
                param.setObject("", forKey: "lat" as NSCopying)
            }
            
        }
        if long != nil
        {
            param.setObject("\(String(long!))", forKey: "long" as NSCopying)
            
        }
        else
        {
            if self.long != nil
            {
                param.setObject("\(self.long!)", forKey: "long" as NSCopying)
            }
            else
            {
                param.setObject("", forKey: "long" as NSCopying)
            }

        }

        
        print(param)
        
        let url="\(base_URL)\(twillio_calling_URL)"
        
        manager.post("\(url)",
            parameters: param,progress: nil,
            
            success: {
                
                (task, responseObject) in
                
                print(responseObject!)
                
                
        },
            failure: {(operation: URLSessionTask?, error: Error) -> Void in
                print("Error: \(error)")
                print("ERROR")
                
        })
    }

    }
    
}

