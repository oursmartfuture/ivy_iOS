//
//  AudioListViewController.swift
//  IVY
//
//  Created by SS108 on 12/09/16.
//  Copyright © 2016 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit


class AudioListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, AVAudioPlayerDelegate, UIAlertViewDelegate {
    
    var audioPlayer: AVAudioPlayer!
    //var isPlaying = true
    var sound = String()
    
    var listOfSounds = ["emergency_1","emergency_2", "emergency_3","ringtone_1","ringtone_2"]
    var listOfPlaySounds = ["emergency 1","emergency 2", "emergency 3","ringtone 1","ringtone 2"]
    
    var ringNo: Int!
    var flag = false
    @IBOutlet weak var tableView: UITableView!
    
    var oldIndexRef:Int = -1
    var newIndexRef:Int = -1
    var oldImgViewRef: UIImageView!
    
    //MARK:- override func
    //MARK:-

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableView Delegates
    //MARK:-
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listOfSounds.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        cellIdentifier = "soundCell"
        
        var cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let soundText = cell?.viewWithTag(5) as! UILabel
        soundText.text = listOfPlaySounds[(indexPath as NSIndexPath).row].capitalized
        
        let playBtnImg = cell?.viewWithTag(13) as! UIImageView
        playBtnImg.image = UIImage(named:"Play_1")
        
        let check = cell?.viewWithTag(11) as! UIImageView
        if (indexPath as NSIndexPath).row == Int(UserDefaults.standard.object(forKey: "defaultRingtone") as! String)
        {
            check.image = UIImage(named: "done_prof")
        }
        else
        {
            check.image = UIImage(named: "")
        }
        cell?.selectionStyle=UITableViewCellSelectionStyle.none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ringNo = (indexPath as NSIndexPath).row
        let alertView : UIAlertView = UIAlertView(
            title:"IVY",
            message:"Do you want to change audio for emergency alert?",
            delegate:self,
            cancelButtonTitle:"Cancel",
            otherButtonTitles:"Ok")
        alertView.show()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    //MARK:- @IBAction func
    //MARK:-
    
    // Action for navigating on previous screen
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }

    @IBAction func playBtn(_ sender: AnyObject)
    {
        let hitPoint: CGPoint = sender.convert(CGPoint.zero, to: tableView)
        let hitIndex = tableView.indexPathForRow(at: hitPoint)
        let hitCell = tableView.cellForRow(at: hitIndex!)
        let playBtnImg = hitCell?.viewWithTag(13) as! UIImageView
        
        newIndexRef = ((hitIndex as NSIndexPath?)?.row)!
        if oldIndexRef == newIndexRef
        {
            oldIndexRef = ((hitIndex as NSIndexPath?)?.row)!
            if audioPlayer.isPlaying == true
            {
                audioPlayer.pause()
                playBtnImg.image = UIImage(named:"Play_1")
            }
            else
            {
                playBtnImg.image = UIImage(named:"Pause_11")
                sound = listOfSounds[((hitIndex as NSIndexPath?)?.row)!]
                audioPlayerCondition()
            }
        }
        else
        {
            if oldIndexRef == -1
            {
                oldImgViewRef = playBtnImg
                oldIndexRef = newIndexRef
            }
            else
            {
                oldImgViewRef.image = UIImage(named:"Play_1")
                oldImgViewRef = playBtnImg
                oldIndexRef = newIndexRef
            }
            
            playBtnImg.image = UIImage(named:"Pause_11")
            sound = listOfSounds[((hitIndex as NSIndexPath?)?.row)!]
            audioPlayerCondition()
        }
    }
    
    
    // MARK: AVAudioPlayerDelegate
    
    //Audio player func
    func audioPlayerCondition()
    {
        // Construct URL to sound file
        let soundUrl = URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!)
        // Create audio player object and initialize with URL to sound
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
            audioPlayer.delegate = self
        }
        catch let error {
        }
        audioPlayer.play()
    }
    
    // extension MicroStepViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
       tableView.reloadData()
        
    }
    
    // MARK: alertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
    {
        switch buttonIndex
        {
        case 1:
            userRingSet()
            break
        case 0:
            break
        default :
            break
        }
    }
    
    //MARK:- selected sound web service
    func userRingSet()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"default_ringtone":ringNo] as NSDictionary
            print(param)
            let url="\(base_URL)\(userRing_URL)"
            
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in
                            
                            print(responseObject)
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                            if let result = responseObject as? NSDictionary{
                            
                            let status = result.object(forKey: "success")! as! Int
                                
                            if(status  == 0)
                            {
                                let msg  = result.object(forKey: "message")! as! String
                                
                                
                                 appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            }
                            else
                            {
                                let msg = result.object(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                //self.contactList.removeObjectAtIndex(self.indexpath.row)
                                UserDefaults.standard.setValue(String(self.ringNo), forKey: "defaultRingtone")
                                
                                self.tableView.reloadData()
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

    
}
