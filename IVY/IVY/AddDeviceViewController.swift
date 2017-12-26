//
//  AddDeviceViewController.swift
//  FindMe
//
//  Created by Singsys on 23/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MapKit
import CoreBluetooth

protocol submit
{
    func submit(_ submit:Bool)
}


class AddDeviceViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,CLLocationManagerDelegate  {
    @IBOutlet var tableView:UITableView!
    var photoEdited = false
    var delegate: submit?
    let Picker=UIImagePickerController()
    var profile:UIImageView!
    var viewRect: CGRect!
    var profileDictionary:NSMutableDictionary!
    var settingsData:NSMutableDictionary!
    var pending_status:String!
    var nameField:UITextField!
    var viewType:String!
    var device_id = ""
    var device_mac_uuID = ""
    var Deviceinfo : NSMutableArray = []
    var status = "yes"
    var name:String!
    var peripheral:CBPeripheral!
    
    
    @IBOutlet var navTitle:UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        if(viewType=="adddevice")
        {
            navTitle.text = "Add Device"
            
            
        }
        else if(viewType=="editdevice")
            
        {
            navTitle.text = "Edit Device"
            self.viewDeviceAdd()
        }
        
        
        
        Picker.delegate = self
        profileDictionary = NSMutableDictionary()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        viewRect = tableView.frame
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddDeviceViewController.doneTyping))
        self.tableView.addGestureRecognizer(tapGesture)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell!
        
        var cellIdentifier:String
        
        if (indexPath as NSIndexPath).row == 0
        {
            
            cellIdentifier = "NameCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            nameField=cell.viewWithTag(15) as! UITextField
            
            if(viewType=="adddevice")
            {
                nameField.text = name
                //nameField.userInteractionEnabled = false
            }
            
            if Deviceinfo.count > 0
            {
                
                nameField.text = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "name") as? String
            }
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            cellIdentifier = "DeviceImageCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
            profile=cell.viewWithTag(123) as! UIImageView!
            
            if Deviceinfo.count > 0
            {
                
                let photoUrl = ((self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "device_image") as? String)!
                
                print(photoUrl)
                
                
                profile.layer.cornerRadius = profile.frame.size.width/2
                profile.clipsToBounds = true
                
                
                profile.setImageWith(URL(string: photoUrl)!, placeholderImage: UIImage(named: "device"))
                
                //profile.setImageWithURL(NSURL(string: photoUrl!)!)
                
                
                
                photoEdited = true
                let fileManager = FileManager.default
                
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                let filePathToWrite = "\(paths)/device_photo.png"
                //  var imageData: NSData = UIImagePNGRepresentation(selectedImage)
                let imageData: Data = UIImageJPEGRepresentation(profile.image!, 0.6)!;
                fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
                
                
                
                
                
            }
        }
            
        else if (indexPath as NSIndexPath).row == 2
        {
            cellIdentifier = "PairingStatusCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
            
            let switchlabel = cell.viewWithTag(6) as! UILabel
            let switchBtn = cell.viewWithTag(33) as! UIButton
            
            if Deviceinfo.count > 0
            {
                //_=self.Deviceinfo.objectAtIndex(0).objectForKey("device_image") as? String
                status = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "pending_status") as! String
            }
            if status.lowercased() == "yes"
            {
                switchlabel.text = "Active"
                switchBtn.isSelected = true
                
            }
            else
            {
                switchlabel.text = "Inactive"
                switchBtn.isSelected = false
            }
            
            
        }
            
            
            
            
        else
        {
            cellIdentifier = "SaveCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            
        }
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0
        {
            return 66
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            return 150
        }
        else if (indexPath as NSIndexPath).row == 2
        {
            return 71
        }
        else
        {
            return 86
        }
        
        
    }
    
    
    //MARK:- textfield Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        nameField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    //MARK: ActionSheet Delegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        print(buttonIndex)
        switch(buttonIndex)
        {
        case 0:
            Picker.allowsEditing = true
            
            Picker.sourceType = .photoLibrary
            
            present(Picker, animated: true, completion: nil)
            
            break
            
        case 1:
            Picker.allowsEditing = true
            
            Picker.sourceType = UIImagePickerControllerSourceType.camera
            
            present(Picker, animated: true, completion: nil)
            
            break
            
        default:break
            
        }
    }
    
    //MARK:- image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        photoEdited = true
        //        edit_img = true
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //profile.contentMode = .ScaleAspectFill
            profile.layer.cornerRadius = profile.frame.size.width/2
            profile.clipsToBounds = true
            profile.image = pickedImage
            
            let selectedImage: UIImage = pickedImage
            let fileManager = FileManager.default
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            let filePathToWrite = "\(paths)/device_photo.png"
            //  var imageData: NSData = UIImagePNGRepresentation(selectedImage)
            let imageData: Data = UIImageJPEGRepresentation(selectedImage, 0.6)!;
            fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
            
            
        }
        //        submit = false
        //        self.photochange()
        
        dismiss(animated: true, completion: nil)
        //        tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- @IBAction func
    
    // Add Image
    @IBAction func addImage(_ sender:UIButton)
    {
        view.endEditing(true)
        let myActionSheet : UIActionSheet  = UIActionSheet()
        myActionSheet.addButton(withTitle: "Use Gallery")
        myActionSheet.addButton(withTitle: "Use Camera")
        myActionSheet.addButton(withTitle: "Cancel")
        myActionSheet.cancelButtonIndex = 2
        myActionSheet.delegate=self
        myActionSheet.show(in: self.view)
    }

    @IBAction func switchClicked(_ sender:UIButton)
    {
        
        let hitPoint: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        let FieldIndex = self.tableView.indexPathForRow(at: hitPoint)
        
        let cellToUpdate = self.tableView.cellForRow(at: FieldIndex!)
        
        let switchBtn = cellToUpdate?.viewWithTag(33) as! UIButton
        let switchlabel = cellToUpdate?.viewWithTag(6) as! UILabel
        
        if status.lowercased() == "yes"
        {
            status = "no"
            switchBtn.isSelected = false
            switchlabel.text = "Inactive"
        }
        else
        {
            status = "yes"
            switchBtn.isSelected = true
            switchlabel.text = "Active"
        }
        //        if switchBtn.selected == false
        //        {
        //
        //            switchBtn.selected = true
        //        }
        //        else
        //        {
        //            switchBtn.selected = false
        //        }
        //        if ( FieldIndex?.row==2)
        //        {
        //            if switchBtn.selected
        //            {
        //               pending_status = "Yes"
        //            }
        //            else
        //            {
        //               pending_status = "No"
        //            }
        //        }
        //
        
        
    }
    
    @IBAction func doneButtonClicked()
    {
        view.endEditing(true)
        
        if(nameField.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Name of Device." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if photoEdited == false
        {
            let msg:AnyObject = "Please add Device Image." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
        else
        {
            self.addDeviceWebService()
        }
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        delegate?.submit(false)
        
        navigationController?.popViewController(animated: true)
    }

    //MARK:- helping func
    func doneTyping()
    {
        view.endEditing(true)
    }
    
    
    
    func back()
    {
        delegate?.submit(true)
        
        var viewControllers = self.navigationController?.viewControllers
        
        appdelegate.from = ""
        
        if(viewType=="adddevice")
        {
            
            self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 3], animated: true)
        }
        else
        {
            self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 2], animated: true)
        }
    }
    //MARK:- webservices
    
    func addDeviceWebService()
    {
        
        var nricdata: NSData!
        
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let getnric = "\(paths)/device_photo.png"
        //var getnric = paths.stringByAppendingPathComponent("nric_photo.png")
        
        if (fileManager.fileExists(atPath: getnric))
        {
            print("FILE AVAILABLE");
            
            //Pick Image and Use accordingly
            //                    var nricimageis: UIImage = UIImage(contentsOfFile: getnric)!
            
           // nricdata = Data.dataWithContentsOfMappedFile(getnric) as! Data!
            
            do {
                
                 var nricimageis: UIImage = UIImage(contentsOfFile: getnric)!
                
                nricdata = try NSData.init(contentsOfFile: getnric)
//                nricdata = try Data.init(contentsOf: URL(string: getnric)!, options: NSData.ReadingOptions())
                print(nricdata)
            } catch {
                print(error)
            }
            
        }
        else
        {
            
            print("FILE NOT AVAILABLE");
            
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
            
            let param:NSDictionary!
            
            
            
            let lat = appdelegate.locationManager.location?.coordinate.latitude
            let long = appdelegate.locationManager.location?.coordinate.longitude
            
            
           

            
            
            //            var baseIntA = Int(arc4random() % 65535)
            //            var baseIntB = Int(arc4random() % 65535)
            
            
            
            
            
            
            if(viewType=="adddevice")
            {
                var str = ""
                if peripheral != nil
                {
                    str = peripheral.identifier.uuidString
                }
                print("\(str)")
                
                
                if lat == nil || long == nil
                {
                    appdelegate.hideProgressHudInView(self.view)
                   self.enableLocationAlert()
                    return
                }
                
                param=["action":"Add","user_id":(user_id)!,"name":(nameField.text)!,"mac_address":str,"last_known_lat":String(lat!),"last_known_long":String(long!),"pending_status":status,"mode":"","unique_name":name] as NSDictionary
                    
                

                
                
                
            }
                
            else
                
            {
                
                
                param=["action":"Edit","user_id":(user_id)!,"name":(nameField.text)!,"mac_address":((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "mac_address") as! String),"last_known_lat":((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_lat") as! NSString).floatValue,"last_known_long":((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_long") as! NSString).floatValue,"pending_status":status,"mode":"","unique_name":name] as NSDictionary
                
            }
            
            
            print(param)
            let url="\(base_URL)\(addDevice_URL)"
            manager.post("\(url)", parameters: param, constructingBodyWith:
                {
                    (formData : AFMultipartFormData!) -> Void in
                    
                    // let imageData = UIImagePNGRepresentation(self.nricImageView.image)
                    if (self.photoEdited == true && nricdata != nil)
                    {
                        formData.appendPart(
                            withFileData: nricdata as Data,
                            name: "device_image",
                            fileName: "device_photo.png",
                            mimeType: "image/png")
                        
                    }
                    
                },
                         
                         success: {
                            (operation,responseObject)in
                            print(responseObject)
                             if let result = responseObject as? NSDictionary{
                                
                            let status = result.object(forKey: "success")! as! Int
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                            
                            
                            if(status  == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            }
                            else
                            {
                                if self.peripheral != nil
                                {
                                    appdelegate.connectedPeripheral = self.peripheral
                                    appdelegate.centralManager.connect(self.peripheral, options: nil)
                                }
//                                let msg = result.object(forKey: "message")! as! String
//                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                                _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(AddDeviceViewController.back), userInfo: nil, repeats: false)
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

    func enableLocationAlert()
    {
        let alertView = UIAlertController(title: "Alert", message: "Enable location to add device.", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertView.addAction(UIAlertAction(title: "Enable", style: .default, handler: { (alertAction) -> Void in
            if #available(iOS 8.0, *) {
                
                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                
            }
                
            else {
                
            }
        }))
        
        present(alertView, animated: true, completion: nil)
    }
    
    func viewDeviceAdd()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"device_id":device_id,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(viewDeviceDetail_URL)"
            
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in
                            
                            print(responseObject)
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                            if let result = responseObject as? NSDictionary{
                            
                            let status = result.object(forKey: "success")! as! Int
                            if(status == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                
                                 appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                            }
                            else
                            {
//                                let msg = result.object(forKey: "message")! as! String
//                                
//                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                                // self.contactList.removeAllObjects()
                                let temp = result.object(forKey: "data")! as! NSArray
                                
                                self.Deviceinfo  = temp.mutableCopy() as! NSMutableArray
                                
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
