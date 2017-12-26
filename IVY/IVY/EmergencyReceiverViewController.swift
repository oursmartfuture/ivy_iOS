 //
//  EmergencyReceiverViewController.swift
//  IVY
//
//  Created by SS068 on 06/10/16.
//  Copyright © 2016 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MapKit
 import MediaPlayer
 import AVKit

 class EmergencyReceiverViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate, AVAudioPlayerDelegate,URLSessionDelegate,URLSessionDataDelegate,URLSessionDownloadDelegate {
    
   
    
    var play: UIButton!
    var alert_id = Int()
    var locationMap:MKMapView!
    var alertDetails:NSMutableArray! = []
    @IBOutlet var tableView:UITableView!
    let locationManager = CLLocationManager()
    @IBOutlet var commingHelpButton: UIButton!
    
    var z = ""
    var recipientList:NSMutableArray! = []
    var audioPlayer: AVAudioPlayer!
//    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
//    var audioRecorderVC: AudioRecordViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView!.estimatedRowHeight = 500
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.isHidden = true
        
        commingHelpButton.layer.cornerRadius = 5
        commingHelpButton.layer.borderWidth = 2
        commingHelpButton.layer.borderColor = UIColor.white.cgColor
        
        commingHelpButton.isHidden = true
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
        }
        self.getAlertDetails()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else if section == 1
        {
            if recipientList.count > 0
            {
                return recipientList.count
            }else
            {
                return 1
            }
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return ""
        }
            
        else if section == 1
        {
            return "Recipients Details"
        }
        else
        {
            return "Audio Clip"
            
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
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
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
            
            let profileImg = cell.viewWithTag(2) as! UIImageView!
            
            
            
            profileImg?.layer.borderWidth = 1
            
            profileImg?.layer.masksToBounds = false
            
            profileImg?.layer.borderColor = UIColor.white.cgColor
            
            profileImg?.layer.cornerRadius = (profileImg?.frame.size.width)! / 2
            
            profileImg?.layer.cornerRadius = (profileImg?.frame.size.height)! / 2
            
            profileImg?.clipsToBounds = true

            if alertDetails.count > 0
            {
                
                let a = (((alertDetails.object(at: 0) as AnyObject).object(forKey: "sender_name") as! String).components(separatedBy: " ")[0])
                
                let x = (((alertDetails.object(at: 0) as AnyObject).object(forKey: "send_ago") as! String))
                
                let y = (((alertDetails.object(at: 0) as AnyObject).object(forKey: "send_at") as! String))
                
                //converting string to NSDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                let date = dateFormatter.date(from: y )
                
                //calculated start time
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter1.timeZone = NSTimeZone.local
                let startDateTime = dateFormatter1.string(from: date!)
                
                
//                dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                let startDate = dateFormatter1.date(from: startDateTime)
                
                
                
                
//                let y = (((alertDetails.object(at: 0) as AnyObject).object(forKey: "send_at") as! String).components(separatedBy: " ")[1])
              
                
                
                
                if let b = ((alertDetails.object(at: 0) as AnyObject).object(forKey: "address") as? String)
                {
                    z = b
                }
//                let z = ""
                let w = ((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_duration") as! String)
                
                var ContactNumber = ""
                
                if (alertDetails.object(at: 0) as AnyObject).object(forKey: "sender_number") as! String != ""
                {
                    ContactNumber = (alertDetails.object(at: 0) as AnyObject).object(forKey: "sender_number") as! String
                }
                
                var localTimeZoneName: String { return NSTimeZone.local.abbreviation(for: Date()) ?? ""}
                
//                var localTimeZoneName: String { return (NSTimeZone.local as NSTimeZone).name }
                
                
                lbl?.text = "Last message has been sent on\n\(x) at \(startDateTime)(\(localTimeZoneName)) near \(z) and \(w) seconds recording.\n\nContact: \(ContactNumber)"

            
          
                
                let photoUrl=(self.alertDetails.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "sender_profile_img") as? String
                
                if photoUrl?.isEmpty == false
                {
                    //                    profileImg.clipsToBounds = true
                    profileImg?.setImageWith(URL(string: photoUrl!)!, placeholderImage: UIImage(named: "myPic"))
                    //                    profileImg.setImageWith(URL(string: photoUrl!)!)
                }
                else{
                    profileImg?.image = UIImage(named: "myPic")
                    
                }
            }
        }
            
        else if (indexPath as NSIndexPath).section == 1
        {
            cellIdentifier = "recipientCell"
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            let profileImg = cell.viewWithTag(2) as! UIImageView!
            
            let nameLbl = cell.viewWithTag(3) as! UILabel!
            
            let lbl = cell.viewWithTag(4) as! UILabel!
            
            profileImg?.layer.borderWidth = 1
            
            profileImg?.layer.masksToBounds = false
            
            profileImg?.layer.borderColor = UIColor.white.cgColor
            
            profileImg?.layer.cornerRadius = (profileImg?.frame.size.width)! / 2
            
            profileImg?.layer.cornerRadius = (profileImg?.frame.size.height)! / 2
            
            profileImg?.clipsToBounds = true
            
//            profileImg.clipsToBounds = true
            
            if recipientList.count > 0
            {
                lbl?.isHidden = true
                profileImg?.isHidden = false
                nameLbl?.isHidden = false
                
                let photoUrl=(self.recipientList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "profile_image") as? String
                
                if photoUrl?.isEmpty == false
                {
//                    profileImg.clipsToBounds = true
                     profileImg?.setImageWith(URL(string: photoUrl!)!, placeholderImage: UIImage(named: "myPic"))
//                    profileImg.setImageWith(URL(string: photoUrl!)!)
                }
                else{
                    profileImg?.image = UIImage(named: "myPic")

                }
                 profileImg?.layer.cornerRadius = (profileImg?.frame.size.width)!/2
//                profileImg.clipsToBounds = true
                
                nameLbl?.text=(self.recipientList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "receiver_name") as? String
            }
            else{
                profileImg?.isHidden = true
                nameLbl?.isHidden = true
                lbl?.isHidden = false
                
            }
            
        }
        else
        {
            if (indexPath as NSIndexPath).row == 0
            {
                cellIdentifier = "audioCell"
                cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
                
                if(cell==nil)
                {
                    cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
                }
                
                
                 self.play = cell.viewWithTag(1) as! UIButton
                
                 self.play.addTarget(self, action: #selector(EmergencyReceiverViewController.playRecordAudio(_:)), for: .touchUpInside)
            }
            else
            {
                cellIdentifier = "mapCell"
                cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
                
                if(cell==nil)
                {
                    cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
                }
                locationMap = cell.viewWithTag(11) as! MKMapView!
                if alertDetails.count > 0
                {
                    self.forAnnotation()
                }
            }
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0
        {
            return UITableViewAutomaticDimension
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
    
    //MARK:- web services
    //web service hit
    func getAlertDetails()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"alert_id":alert_id,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(recieverAlert_URL)"
            
            manager.post("\(url)",
                parameters: param,
                success: { (operation,responseObject)in
                    
                    print(responseObject)
                    
                    appdelegate.hideProgressHudInView(self.view)
                    
                    if let result = responseObject as? NSDictionary{
                        
                        let status = result.object(forKey: "success")! as! Int
                        if(status == 0)
                        {
                            let msg = result.object(forKey: "message")! as! String
                            
                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        }
                        else
                        {
                            
//                            let msg = result.object(forKey: "message")! as! String
//                            
//                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            //                                 self.contactList.removeAllObjects()
                            
                            let tempDic  = result.object(forKey: "data") as! NSDictionary
                            
                            let tempDic2 = tempDic.object(forKey: "info") as! NSDictionary
                            
                            if tempDic2.object(forKey: "is_safe") as! String == "1"
                            {
                                appdelegate.showMessageHudWithMessage("This alert has already been Cancelled or Marked as Safe", delay: 2.0)
                             self.navigationController?.popViewController(animated: true)
                            }
                            
                            if tempDic2.object(forKey: "is_coming") as! String == "0"
                            {
                                self.commingHelpButton.isUserInteractionEnabled = true
                                self.commingHelpButton.setTitle(" I am coming to help you", for: .normal)
                            }
                            else
                            {
                                self.commingHelpButton.isUserInteractionEnabled = false
                                self.commingHelpButton.setTitle("You have already marked for coming", for: .normal)
                            }
                            
                            self.alertDetails.add(tempDic2)
                            
                            let tempArray2 = tempDic.object(forKey: "receivers") as! NSArray
                            
                            self.recipientList = tempArray2.mutableCopy() as! NSMutableArray
                            
                            self.commingHelpButton.isHidden = false
                            
                            
                        }
                    
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(EmergencyReceiverViewController.refreshTable), userInfo: nil, repeats: false)
                       
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
    
    func refreshTable()
    {
        self.tableView.reloadData()
    }
    
    //MARK:- map view pin
    //Map annotation
    func forAnnotation()
    {
        
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D((latitude: ((alertDetails.object(at: 0) as AnyObject).object(forKey: "latitude") as! NSString).doubleValue, longitude: ((alertDetails.object(at: 0) as AnyObject).object(forKey: "longitude") as! NSString).doubleValue))
        
        let sourceLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
        
//        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
//         locationMap.setRegion(theRegion, animated: true)
//        
//        let theSourceRegion :MKCoordinateRegion = MKCoordinateRegionMake(sourceLocation,theSpan)
//        locationMap.setRegion(theSourceRegion, animated: true)
//       
//        let anotation = MKPointAnnotation()
//        anotation.coordinate = location
//        
//        anotation.coordinate = sourceLocation
//        locationMap.addAnnotation(anotation)
        
        self.route(sourceLocation: sourceLocation, destinationLocation: location)
        
        
        
    }
    
    func route(sourceLocation:CLLocationCoordinate2D, destinationLocation:CLLocationCoordinate2D)
    {
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 1.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 2.
        let sourceAnnotation = MKPointAnnotation()
        
        sourceAnnotation.title = "My Location"
        
        
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        let destinationAnnotation = MKPointAnnotation()
//        destinationAnnotation.title = ""
        destinationAnnotation.title = "\(self.z )"
//        destinationAnnotation.description = "destinationAnnotation"
        
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 3.
        
        self.locationMap.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // 4.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .any
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 5.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            print("my Route is : \(response.routes)")
            let route = response.routes[0]
            self.locationMap.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.locationMap.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    //MARK:-@IBAction func
    @IBAction func backBtnClicked(_ sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    @IBAction func commingForHelpButtonClicked(_ sender: AnyObject) {
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"alert_id":alert_id,"mode":""] as NSDictionary
            
            print(param)

            let url="\(base_URL)\(alert_response_URL)"
            
            manager.post("\(url)",
                parameters: param,progress: nil,
                
                success: {
                    
                    (task, responseObject) in
                    
                    print(responseObject)
                    appdelegate.hideProgressHudInView(self.view)
                    
                    if let result = responseObject as? NSDictionary{
                        
                        
                        let msg = result.object(forKey: "message")! as! String
                        
                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        
//                        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                        
//                        self.navigationController?.pushViewController(infoVC, animated: true)
                        self.navigationController?.popViewController(animated: true)
                        
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
    
    
    
    //mark as safe btn tap
    @IBAction func markAsSafeBtn(_ sender:UIButton)
    {
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            
            manager.responseSerializer = serializer
            
            let param=["alert_id":alert_id,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(markAsSafe_URL)"
            
            manager.post("\(url)",
                parameters: param,progress: nil,
                
                success: {
                    
                    (task, responseObject) in
                    
                    print(responseObject)
                    appdelegate.hideProgressHudInView(self.view)
                    
                    if (responseObject as? NSDictionary) != nil{
                        
                        //                        let status = result.objectForKey("success")! as Int
                        
//                        let msg = result.object(forKey: "message")! as! String
//                        
//                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                        
                        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        self.navigationController?.pushViewController(infoVC, animated: true)
                        //self.navigationController?.popToRootViewControllerAnimated(true)
                        //self.navigationController?.popViewControllerAnimated(true)
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
    
    //Cancel btn tap
    @IBAction func cancelBtn(_ sender:UIButton)
    {
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["alert_id":alert_id,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(cancel_URL)"
            
            manager.post("\(url)",
                parameters: param,progress: nil,
                
                success: {
                    
                    (task, responseObject) in
                    
                    print(responseObject)
                    
                    appdelegate.hideProgressHudInView(self.view)
                    
                    if (responseObject as? NSDictionary) != nil{
                        //                    let status:AnyObject=responseObject.objectForKey("success")!
                        
//                        let msg = result.object(forKey: "message")! as! String
//                        
//                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                        
                        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        self.navigationController?.pushViewController(infoVC, animated: true)
                        //self.navigationController?.popViewControllerAnimated(true)
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
    
//    func playRecordAudio(_ sender: AnyObject) {
//        
//        //        let hitPoint: CGPoint = sender.convert(CGPoint.zero, to: tableView)
//        //
//        //        let hitIndex = tableView.indexPathForRow(at: hitPoint)
//        
//        let  urlPath = NSURL(string: "\((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_file") as! String)")
//        
////        audioPlayer.delegate = self
//        
//        // let playBtn: UIButton!
//        if audioPlayer != nil
//        {
//            if audioPlayer.isPlaying == true
//            {
//                audioPlayer.pause()
//                //let image = UIImage(named: "Play_1")
//                //playBtn.setImage(image, forState: .Normal)
//                
//            }
//            else
//            {
//                //let image = UIImage(named: "Pause_11")
//                // playBtn.setImage(image, forState: .Normal)
//                audioPlayerCondition(url: urlPath!)
//                                audioPlayer.delegate = self
//                
//            }
//        }
//        else
//        {
//            //let image = UIImage(named: "Pause_11")
//            // playBtn.setImage(image, forState: .Normal)
//            audioPlayerCondition(url: urlPath!)
//                        audioPlayer.delegate = self
//            
//        }
//        
//    }
//    
//    // MARK: AVAudioPlayerDelegate
//    
//    //Audio player func
//    func audioPlayerCondition(url:NSURL)
//    {
//        // Construct URL to sound file
//        
//        
//        
////        let soundUrl = audioRecorderVC.soundFileURL//NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("input_audio", ofType: "m4a")!)
//        // Create audio player object and initialize with URL to sound
//        do {
//            self.audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
//            audioPlayer.delegate = self
//        }
//        catch let error {
//        }
//        audioPlayer.play()
//    }
    
    func playRecordAudio(_ sender: AnyObject) {
        
         let  urlPath = NSURL(string: "\((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_file") as! String)")
        
     if audioPlayer != nil
        {
            if audioPlayer.isPlaying == true
            {
                audioPlayer.pause()
                
                let image = UIImage(named: "PlayBtnEmer.png")
                
                self.play.setImage(image, for: .normal)
                
            }
            else
            {
                self.downloadFileFromURL(url: urlPath!)
            }
        }
        else
        {
            self.downloadFileFromURL(url: urlPath!)
        }
        
    }
    
    // MARK: AVAudioPlayerDelegate
    
    //Audio player func
    func audioPlayerCondition()
    {
        // Construct URL to sound file
        
        //         let  urlPath = NSURL(string: "\((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_file") as! String)m4a")
        
        let  urlPath = NSURL(string: "\(UserDefaults.standard.object(forKey: "soundFileURL")  as! String)")
        
        //
        
        //        let soundUrl = audioRecorderVC.soundFileURL//NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("input_audio", ofType: "m4a")!)
        // Create audio player object and initialize with URL to sound
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: urlPath as! URL)
            
            audioPlayer.delegate = self
            
            audioPlayer.play()
        }
        catch let error {
            print(error)
        }
        //        audioPlayer.play()
    }
    
    func downloadFileFromURL(url:NSURL){
        
        var downloadTask:URLSessionDownloadTask
        
        var session:URLSession!
        
        let configuration = URLSessionConfiguration.default
        
        let manqueue = OperationQueue.main
        
        
        session = URLSession(configuration: configuration, delegate:self, delegateQueue: manqueue)
        
        appdelegate.hideProgressHudInView(self.view)
        
        appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please Wait..", labelText: "Playing")
        
        downloadTask = (session?.downloadTask(with: url as URL))!
        
        downloadTask.resume()
        
    }

    
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print(error)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
           print(error)
        }
    }
    
    func playAudio(url:NSURL) {
        
        
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
        
        
        do {
            
            self.audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
            
           self.audioPlayer.delegate = self
           self.audioPlayer.prepareToPlay()
            
            self.audioPlayer.volume = 1.0
            
            self.audioPlayer.play()
//           self.audioPlayer.volume = .
//           self.audioPlayer.currentTime = 0.0
//           self.audioPlayer.play()
            
        } catch let error as NSError {
            
            let image = UIImage(named: "PlayBtnEmer.png")
            
            self.play.setImage(image, for: .normal)
            
           self.audioPlayer = nil
            
            print(error)
            //            print(error.localizedDescription)
        }
        
    }


    
    
    // extension MicroStepViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        let image = UIImage(named: "PlayBtnEmer.png")
        
        self.play.setImage(image, for: .normal)
    }
    
    //MARK:- Mapview delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    //MARK:- URL Delegates
    
    // Downloding Delegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        appdelegate.hideProgressHudInView(self.view)
        self.playAudio(url: location as NSURL)
        let image = UIImage(named: "Pause_11")
        
        self.play.setImage(image, for: .normal)
       

    }

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
                print("\(bytesWritten)")
        
        
    }
    
    

    
}

