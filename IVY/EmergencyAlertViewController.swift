//
//  EmergencyAlertViewController.swift
//  IVY
//
//  Created by Singsys-114 on 2/11/16.
//  Copyright © 2016 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MapKit
import MediaPlayer
import AVKit

class EmergencyAlertViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate, AVAudioPlayerDelegate,URLSessionDelegate,URLSessionDataDelegate,URLSessionDownloadDelegate {
    
    var play: UIButton!
    var alert_id = Int()
    var locationMap:MKMapView!
    var alertDetails:NSMutableArray! = []
    @IBOutlet var tableView:UITableView!
    var recipientList:NSMutableArray! = []
    var viewType = ""
    var fromScreen = ""
    var audioPlayer: AVAudioPlayer!
    
    var audioRecorderVC: AudioRecordViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView!.estimatedRowHeight = 500
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.isHidden = true
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
            var z = ""
            if alertDetails.count > 0
            {
                
                let defaultDate = (alertDetails.object(at: 0) as AnyObject).object(forKey: "send_at") as! String
                
                //converting string to NSDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                let date = dateFormatter.date(from: defaultDate as! String)
                
                //calculated start time
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter1.timeZone = NSTimeZone.local
                let startDateTime = dateFormatter1.string(from: date!)
                
                
                let x = ((startDateTime ).components(separatedBy: " ")[0])
                let y = ((startDateTime ).components(separatedBy: " ")[1])
                
//                dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                let startDate = dateFormatter1.dateFromString(startDateTime)
                
//                var localTimeZoneName: String { return (NSTimeZone.local as NSTimeZone).name }
                
                var localTimeZoneName: String { return NSTimeZone.local.abbreviation(for: Date()) ?? ""}
                
                if (alertDetails.object(at: 0) as AnyObject).object(forKey: "address") as! String == ""
                {
                    z = ""
                }
                else
                {
                     z = ((alertDetails.object(at: 0) as AnyObject).object(forKey: "address") as! String)
                }
                
                let w = ((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_duration") as! String)
                
                if z != ""
                {
                    lbl?.text = "Last message has been sent on " + x + " at " + y + "(\(localTimeZoneName)) near " + z + " and " + w + " seconds recording."
                }
                else
                {
                    lbl?.text = "Last message has been sent on " + x + " at " + y + " and " + w + " seconds recording."
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
           
            profileImg?.image = UIImage(named: "myPic")
            profileImg?.layer.borderWidth = 1
            
            profileImg?.layer.masksToBounds = false
            
            profileImg?.layer.borderColor = UIColor.white.cgColor
            
            profileImg?.layer.cornerRadius = (profileImg?.frame.size.width)! / 2
            
            profileImg?.layer.cornerRadius = (profileImg?.frame.size.height)! / 2
            
           profileImg?.clipsToBounds = true
            
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
                    
                    //profileImg.setImageWith(URL(string: photoUrl!)!)
                }
                else
                {
                    profileImg?.image = UIImage(named: "myPic")
                }
                
                
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
                
                
                 play = cell.viewWithTag(1) as! UIButton
                
                play.addTarget(self, action: #selector(EmergencyAlertViewController.playRecordAudio(_:)), for: .touchUpInside)
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
            let url="\(base_URL)\(senderAlert_URL)"
            
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
                                
                              let msg = result.object(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
//                                 self.contactList.removeAllObjects()
                                
                                let tempDic  = result.object(forKey: "data") as! NSDictionary
                                
                                let tempArray = tempDic.object(forKey: "info") as! NSArray
                                
                                self.alertDetails = tempArray.mutableCopy() as! NSMutableArray
                                
                                
                                
                                let tempArray2 = tempDic.object(forKey: "receivers") as! NSArray
                                
                                self.recipientList = tempArray2.mutableCopy() as! NSMutableArray
                                
                                
                                
                            }
                                
                                self.tableView.isHidden = false
                            self.tableView.reloadData()
                                
                        _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(EmergencyAlertViewController.refreshTable), userInfo: nil, repeats: false)
                                
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
        
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
        
        locationMap.setRegion(theRegion, animated: true)
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location

        locationMap.addAnnotation(anotation)
    
    }
    
    //MARK:-@IBAction func
    @IBAction func backBtnClicked(_ sender:UIButton)
    {
        if viewType == "notification"
        {
            self.navigationController?.popViewController(animated: true)

            
        }else
        {
            var viewControllers = self.navigationController?.viewControllers
            self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 3], animated: true)
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
                            
                            if let result = responseObject as? NSDictionary{
                            
                            //                        let status = result.objectForKey("success")! as Int
                            
                            let msg = result.object(forKey: "message")! as! String
                            
                            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                            
                                var viewControllers = self.navigationController?.viewControllers
                                
                              
                                
                                if self.fromScreen == "audio"
                                {
                                    self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 3], animated: true)
                                }
                                else
                                {
                                     self.navigationController?.popViewController(animated: true)
                                }
                                
//                            let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                            self.navigationController?.pushViewController(infoVC, animated: true)
                           //self.navigationController?.popToRootViewControllerAnimated(true)
//
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
                            
                            if let result = responseObject as? NSDictionary{
                            //                    let status:AnyObject=responseObject.objectForKey("success")!
                            
                            let msg = result.object(forKey: "message")! as! String
                            
                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                  var viewControllers = self.navigationController?.viewControllers
                                
                                if self.fromScreen == "audio"
                                {
                                    self.navigationController?.popToViewController((viewControllers?[(viewControllers?.count)! - 2])!, animated: true)
//                                    self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 2], animated: true)
                                }
                                else
                                {
                                    self.navigationController?.popViewController(animated: true)
                                }

                            
//                            let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                            self.navigationController?.pushViewController(infoVC, animated: true)
//                            self.navigationController?.popViewController(animated: true)
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
    
    func playRecordAudio(_ sender: AnyObject) {
        

        
        let  urlPath = NSURL(string: "\((alertDetails.object(at: 0) as AnyObject).object(forKey: "audio_file") as! String)")
        
        self.downloadFileFromURL(url: urlPath!)
        
////         audioPlayer.delegate = self
//        
//   // let playBtn: UIButton!
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
//                self.audioPlayerCondition()
////                audioPlayer.delegate = self
//                
//            }
//        }
//        else
//        {
//            //let image = UIImage(named: "Pause_11")
//            // playBtn.setImage(image, forState: .Normal)
//            self.audioPlayerCondition()
////            audioPlayer.delegate = self
//            
//        }
        
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
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let image = UIImage(named: "PlayBtnEmer.png")
        
        self.play.setImage(image, for: .normal)
        
        if error != nil {
            
           return
        }
        
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


