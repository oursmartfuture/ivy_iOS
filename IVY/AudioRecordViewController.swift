//
//  AudioRecordViewController.swift
//  IVY
//
//  Created by Singsys-114 on 2/1/16.
//  Copyright © 2016 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI

class AudioRecordViewController: UIViewController,AVAudioRecorderDelegate, MFMessageComposeViewControllerDelegate {
    
    var recorder: AVAudioRecorder!
    @IBOutlet var progress:KDCircularProgress!
    var player:AVAudioPlayer!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var stopButton: UIButton!
    var alert_id = Int()
    @IBOutlet var playButton: UIButton!
    var meterTimer:Timer!
    var stopTimer:Timer!
    var soundFileURL:URL!
    var audioDuration:String = "0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        statusLabel.text = ""
        
        progress.startAngle = -90
        
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = false
        progress.glowMode = .forward
        progress.setColors(commonValidations.UIColorFromRGB(0xff2990))

        
        if appdelegate.audioPlayer != nil
        {
            if appdelegate.audioPlayer.isPlaying == true
            {
                appdelegate.audioPlayer.stop()
            }
        }

        
        
            if recorder == nil {
                print("recording. recorder nil")
                //            recordButton.setTitle("Pause", forState:.Normal)
                playButton.isEnabled = false
                stopButton.isEnabled = true
                recordWithPermission(true)
                
            }

                
    }
    
    
    func recordWithPermission(_ setup:Bool) {
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
       
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    
                   self.audioRecordSetup()
                    
                } else {
                    
                    let alert = UIAlertView()
                    
                    alert.title = "Ivy App"
                    alert.message = "Does not have permission to use microphone. Please change permission in setting"
                    alert.addButton(withTitle: "Yes")
                    alert.addButton(withTitle: "No")
                    alert.delegate=self
                    alert.show()
//                    self.sendAlert()
                    print("Permission to record not granted")
                }
            })
        } else {
            
//            self.sendAlert()
            
            print("requestRecordPermission unrecognized")
        }
    }
    
    func audioRecordSetup()
    {
        print("Permission to record granted")
        self.setSessionPlayAndRecord()
        
        self.setupRecorder()
        
        
        self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                               target:self,
                                               selector:#selector(AudioRecordViewController.updateAudioMeter(_:)),
                                               userInfo:nil,
                                               repeats:true)
        
        
        
        
        self.progress.animateFromAngle(0, toAngle: 360, duration: 5) { completed in
            if completed {
                print("animation stopped, completed")
            } else {
                print("animation stopped, was interrupted")
            }
        }
        
        self.stopTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                              target:self,
                                              selector:#selector(AudioRecordViewController.stopAudioMeter),
                                              userInfo:nil,
                                              repeats:false)
    }
    
    
    //MARK:- UIAlertView Delegate
    //MARK:
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        switch buttonIndex {
        case 0:
            print("yes")
            if #available(iOS 8.0, *) {
                
                
                // UIApplication.shared.openURL(NSURL(string: "prefs:root=Bluetooth")! as URL)
                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                
            } else {
                // Fallback on earlier versions
            }
            break;
        case 1:
            
            print("no")
            
            self.navigationController?.popViewController(animated: true)
            
             break;
            
        default:
            break
            
        }
        
    }
    
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).aac"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVNumberOfChannelsKey: 1 as AnyObject,
            AVSampleRateKey : 1200.0 as AnyObject
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            // creates/overwrites the file at soundFileURL
            recorder.record()
            
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
//    AVEncoderBitRateKey : 320000 as AnyObject,
//    ,
//
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // For timer
    //To update timer label.
 
    func updateAudioMeter(_ timer:Timer) {
        
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            
            audioDuration = String(format: "%02d", sec)
            statusLabel.text = s
            
            
            recorder.updateMeters()
            
            
            // if you want to draw some graphics...
            //var apc0 = recorder.averagePowerForChannel(0)
            //var peak0 = recorder.peakPowerForChannel(0)
        }
    }
    
    
    /**
     To stop audio recording meter.
     */
    func stopAudioMeter() {
        
        print("stop")
        
        progress.pauseAnimation()
        
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
            playButton.isEnabled = true
            stopButton.isEnabled = false
            //            recordButton.enabled = true
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        
        // if you want to draw some graphics...
        //var apc0 = recorder.averagePowerForChannel(0)
        //var peak0 = recorder.peakPowerForChannel(0)
        
         self.sendAlert()
    }
    
    
    
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
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
    
    func setSessionPlayAndRecord() {
       
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
           
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
    
    
    
    
    // MARK: AVAudioRecorderDelegate

    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        print("finished recording \(flag)")
        stopButton.isEnabled = false
        playButton.isEnabled = true
        // recordButton.setTitle("Record", forState:.Normal)
       
        
    }
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder,
                                          error: NSError?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
    
    //        func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    //        {
    //
    //            switch buttonIndex
    //            {
    //            case 0:
    //                print("keep was tapped")
    //                break;
    //            case 1:
    //                print("delete was tapped")
    //                self.recorder.deleteRecording()
    //            default :
    //                break
    //            }
    //        }
    //
    
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
    
    
        func updateProgressViewWithPlayer(player: AVAudioPlayer!) {
//            print(CircularProgressView.duration)
        }
    //
    //    func playerDidFinishPlaying() {
    //
    //    }
    //
    //    func updatePlayOrPauseButton() {
    //
    //    }
    //
    
    
    func sendAlert()
    {
       
        var audioData: Data!
        
        if FileManager.default.fileExists(atPath: self.soundFileURL.path)
        {
    
            do {
               audioData = try Data.init(contentsOf: soundFileURL, options: NSData.ReadingOptions())
                print(audioData)
            } catch {
                print(error)
            }
            
            
           
        }
        
        
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
            
            let lat = appdelegate.locationManager.location?.coordinate.latitude
            let long = appdelegate.locationManager.location?.coordinate.longitude
            
            
            
//            param=["user_id":(user_id)!, "latitude":String(lat!),"longitude":String(long!),"audio_duration":
//                (statusLabel.text)!,"mode":""] as NSDictionary
            
            let param = NSMutableDictionary()
            
            param.setObject("\((user_id)!)", forKey: "user_id" as NSCopying)
            param.setObject("\((self.audioDuration))", forKey: "audio_duration" as NSCopying)
            param.setObject("", forKey: "mode" as NSCopying)
            param.setObject("2", forKey: "device_type" as NSCopying)
            
           
            if lat != nil
            {
                param.setObject("\(String(lat!))", forKey: "latitude" as NSCopying)
                
            }
            else
            {
                if appdelegate.lat != nil
                {
                     param.setObject("\(appdelegate.lat!)", forKey: "latitude" as NSCopying)
                }
                else
                {
                     param.setObject("", forKey: "latitude" as NSCopying)
                }
               
            }
            if long != nil
            {
                param.setObject("\(String(long!))", forKey: "longitude" as NSCopying)
                
            }
            else
            {
                if appdelegate.long != nil
                {
                    param.setObject("\(appdelegate.long!)", forKey: "longitude" as NSCopying)
                }
                else
                {
                    param.setObject("", forKey: "longitude" as NSCopying)
                }
                
            }
            
            print(param)

            
            let url="\(base_URL)\(sendAlert_URL)"
            manager.post("\(url)", parameters: param, constructingBodyWith:
                {
                    (formData : AFMultipartFormData!) -> Void in
                    
                    // let imageData = UIImagePNGRepresentation(self.nricImageView.image)
                    
                    formData.appendPart(
                        withFileData: audioData,
                        name: "input_audio",
                        fileName: "input_audio.aac",
                        mimeType: "audio/aac")
     
                },
                        
                         success: {
                            
                            (operation,responseObject)in
                            
                            print("SUCCESS")
                            
                            if let result = responseObject as? NSDictionary{
                            
                            let status = result.object(forKey: "success")! as! Int
                            
                            print(responseObject)
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                            if(status == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            }
                            else
                            {
                                
                                self.alert_id = (result.object(forKey: "data")! as AnyObject).object(forKey: "alert_id") as! Int
                                UserDefaults.standard.setValue("\(self.soundFileURL)", forKey: "soundFileURL")
                                
                                let msg = result.value(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AudioRecordViewController.navigateToNextPage), userInfo: nil, repeats: false)
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
            self.sendMessage()
//            let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
//            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
        }
        
    }
    
    func sendMessage() {
        
        let composeVC = MFMessageComposeViewController()
        
        composeVC.messageComposeDelegate = self
        
        
        if UserDefaults.standard.object(forKey: "contact_number") != nil
        {
            if let ContactArray = UserDefaults.standard.object(forKey: "contact_number") as? NSArray
            {
                composeVC.recipients = ContactArray as? [String]
            }
            else
            {
                composeVC.recipients = [""]
            }
        }
        else
        {
            composeVC.recipients = [""]
        }
        
        
        // Configure the fields of the interface.
       
        composeVC.body = "I am in Trouble"
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func navigateToNextPage()
    {
        let emergencyAlert = storyboard?.instantiateViewController(withIdentifier: "EmergencyAlertViewController") as! EmergencyAlertViewController
        emergencyAlert.alert_id = self.alert_id
        emergencyAlert.fromScreen = "audio"
        self.navigationController?.pushViewController(emergencyAlert, animated: true)
    }
    
    //MARK:- @IBAction func
    
    
    @IBAction func saveBtn(_ sender:UIButton)
    {
//        self.stopAudioMeter()
        
        progress.pauseAnimation()
        
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
            playButton.isEnabled = true
            stopButton.isEnabled = false
            //            recordButton.enabled = true
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }

        self.sendAlert()
        
    }
    
    // Pop to previous view.
    @IBAction func backButton(_ sender:UIButton)
    {
        progress.pauseAnimation()
        
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
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func discardButtonClicked(_ sender: AnyObject) {
        
        progress.pauseAnimation()
        
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
        self.navigationController?.popViewController(animated: true)
    }
    
    // Stop button tapped.
    @IBAction func stopButtonTapped(_ sender: UIButton)
    {
//        self.stopAudioMeter()
    }
    
    //Record button tapped.
    //To start audio recording.
     
 
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        stopButton.isEnabled = false
        
        if recorder == nil {
            print("recording. recorder nil")
            //   recordButton.setTitle("Pause", forState:.Normal)
            playButton.isEnabled = false
            stopButton.isEnabled = true
            recordWithPermission(true)
            return
        }
            
        else {
            print("recording")
            //recordButton.setTitle("Pause", forState:.Normal)
            playButton.isEnabled = false
            stopButton.isEnabled = true
                        recorder.record()
            recordWithPermission(false)
        }
        
        
        progress.animateFromAngle(0, toAngle: 360, duration: 5) { completed in
            if completed {
                print("animation stopped, completed")
            } else {
                
                print("animation stopped, was interrupted")
            }
        }
    }

    @IBAction func discardBtn(_ sender: AnyObject) {
        
        self.stopAudioMeter()
        
        let infoVC = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(infoVC, animated: true)
       // self.navigationController?.popToViewController(infoVC, animated: true)
    }
    
    //MARK: MFMessage Deligate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didCancelWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    
   
    
//    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
//        switch (result.value) {
//        case MessageComposeResultCancelled.value:
//            print("Message was cancelled")
//            self.dismiss(animated: true, completion: nil)
//        case MessageComposeResultFailed.value:
//            print("Message failed")
//            self.dismiss(animated: true, completion: nil)
//        case MessageComposeResultSent.value:
//            print("Message was sent")
//            self.dismissViewControllerAnimated(true, completion: nil)
//        default:
//            break;
//        }
//    }
}
