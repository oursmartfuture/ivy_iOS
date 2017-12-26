//
//  MyProfileViewController.swift
//  FindMe
//
//  Created by Singsys-114 on 11/2/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

import AssetsLibrary


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


class MyProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate
{
    
    var phonepad = false
    fileprivate var profileArray=["Name","Email","Address","Phone Number"]
    var photoEdited = false
    var keyboardShow = false
    @IBOutlet var tableView:UITableView!
    @IBOutlet var editButton:UIButton!
    @IBOutlet var doneButton:UIButton!
    
    let Picker=UIImagePickerController()
    
    var profile:UIImageView!
    var profileDictionary:NSDictionary!
    var editButtonSelected = true
    
    var nameTextField:UITextField!
    var addressTextField:UITextField!
    
    //  @IBOutlet var toolbar:UIToolbar!
    
    var nameField:UITextField!
    var phone:UITextField!
    var addressField:UITextField!
    var emailTextField:UITextField!
    var viewRect: CGRect!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // toolbar.hidden = true
        Picker.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        profileDictionary = NSMutableDictionary()
        getProfileDetails()
        editButton.isHidden = false
        doneButton.isHidden = true
        // Do any additional  setup after loading the view.
        editButtonSelected = false
        viewRect = tableView.frame
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.doneTyping))
        self.tableView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    //this function will be called when keyboard is shown
    func keyboardWillShow(_ notification:Notification)
    {
        _ = (notification as NSNotification).userInfo
        if let info = (notification as NSNotification).userInfo
        {
            
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
            
            
            
            self.tableView.isScrollEnabled = true
            
            if let userInfo = notification.userInfo
            {
                if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    
                    let insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, (keyboardSize.height)+30, 0)
                    
                    self.tableView.contentInset = insets
                    self.tableView.scrollIndicatorInsets = insets
                    
                }
            }

            
            
            
            
            //            var contentInsets:UIEdgeInsets
            //            contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
            //            tableView.contentInset = contentInsets
            //            tableView.scrollIndicatorInsets = tableView.contentInset
//            if keyboardShow == false
//            {
//                keyboardShow = true
//                
//                
//                tableView.frame.origin.y = tableView.frame.origin.y - keyboardSize.height + 5
//            }
            
            //            if phonepad.boolValue
            //            {
            //
            //                let keyboardDoneButtonView: UIToolbar = UIToolbar()
            //                keyboardDoneButtonView.sizeToFit()
            //                let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            //                let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "keyboardHide:")
            //
            //                keyboardDoneButtonView.items = [flexSpace , doneButton] as NSArray as? [UIBarButtonItem]
            //                self.phone.inputAccessoryView = keyboardDoneButtonView
            //                phonepad = false
            //            }
            
            
            
        } else {
            // no user info
        }
        
    }
    
    @IBAction func keyboardHide(_ sender:UIBarButtonItem)
    {
        phone.resignFirstResponder()
    }
    
    //This function will be called when keyboard will hide
    func keyboardWillHide(_ notification:Notification)
    {
        
        let info : NSDictionary = notification.userInfo! as NSDictionary
        if let userInfo = notification.userInfo
        {
            if ((userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                let insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                
                self.tableView.contentInset = insets
                self.tableView.scrollIndicatorInsets = insets
            }
        }
        self.tableView.scrollsToTop = true
        self.tableView.isScrollEnabled = true

        
//        phonepad = false
//        keyboardShow = false
//        tableView.frame.origin.y = 68
    }
    
    
    
    
    
    //MARK: TextField Delegates
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //  toolbar.hidden = false
        if textField == phone
        {
            let keyboardDoneButtonView: UIToolbar = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(MyProfileViewController.keyboardHide(_:)))
            
            keyboardDoneButtonView.items = [flexSpace , doneButton] as NSArray as? [UIBarButtonItem]
            self.phone.inputAccessoryView = keyboardDoneButtonView
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        if textField == nameField{
            addressField.becomeFirstResponder()
        }
        else if textField == addressField
        {
            phone.becomeFirstResponder()
        }
        else if textField == phone
        {
            phone.resignFirstResponder()
        }
        return true
    }
    
    
    
    
    //MARK: UITableView Delegates
    //MARK:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        var cellIdentifier:String
        
        var cell:UITableViewCell!
        
        if (indexPath as NSIndexPath).row == 0
        {
            
            cellIdentifier = "cell1"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            if (profileDictionary.object(forKey: "profile_pic") != nil)// /*&& ((profileDictionary.object(forKey: "profile_pic") as! NSString) != nil)*/ && ((profileDictionary.object(forKey: "profile_pic") as AnyObject).length>0)
            {
                
                let img_url : NSString = ((profileDictionary.object(forKey: "profile_pic") as! NSString) as String as String as NSString)
                let urlStr : NSString = img_url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
                
                let imageUrl : URL = URL(string: urlStr as String)!
                let data = try? Data(contentsOf: imageUrl)
                //  print(data)
                profile=cell.viewWithTag(2) as! UIImageView!
                
                profile.layer.cornerRadius = profile.frame.size.width/2
                profile.clipsToBounds = true
                if data != nil
                {
                    profile.layer.cornerRadius = profile.frame.size.width/2
                    profile.clipsToBounds = true
                    profile.image = UIImage(data: data!)
                }
            }
            
            let editImageButton = cell.viewWithTag(34) as! UIButton
            if (editButtonSelected)
            {
                editImageButton.isHidden = false
            }
            else
            {
                editImageButton.isHidden = true
            }
        }
            
        else if (indexPath as NSIndexPath).row == 5
        {
            cellIdentifier = "cell3"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
        }
        else
        {
            
            cellIdentifier = "cell2"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            let nameTextField = cell.viewWithTag(10) as! UITextField
            if (editButtonSelected)
            {
                nameTextField.isUserInteractionEnabled = true
            }
            else
            {
                nameTextField.isUserInteractionEnabled = false
            }
            let profileText = cell.viewWithTag(11) as! UILabel
            
            profileText.text=profileArray[(indexPath as NSIndexPath).row-1]
            
            if ((indexPath as NSIndexPath).row == 1)
            {
                nameField = cell.viewWithTag(10) as! UITextField
                
               // if (profileDictionary.object(forKey: "name") != nil) && ((profileDictionary.object(forKey: "name") as AnyObject).isKind(of: NSString()) != nil) && ((profileDictionary.object(forKey: "name") as AnyObject).length>0)
                    
                if (profileDictionary.object(forKey: "name") != nil)
                {
                    self.nameField.text = profileDictionary.object(forKey: "name") as? String
                }
                else
                {
                    self.nameField.text = ""
                }
            }
            else if ((indexPath as NSIndexPath).row == 2)
            {
                emailTextField = cell.viewWithTag(10) as! UITextField
                
                
//                self.nameTextField.isUserInteractionEnabled = false
                if (profileDictionary.object(forKey: "email") != nil) //&& ((profileDictionary.object(forKey: "email") as AnyObject).isKind(of: NSString()) != nil) && ((profileDictionary.object(forKey: "email") as AnyObject).length>0)
                {
                    self.emailTextField.text = profileDictionary.object(forKey: "email") as? String
                }
                else
                {
                    self.emailTextField.text = ""
                }
            }
            else if ((indexPath as NSIndexPath).row == 3)
            {
                addressField = cell.viewWithTag(10) as! UITextField
                
                if (profileDictionary.object(forKey: "address") != nil) //&& //((profileDictionary.object(forKey: "address") as AnyObject).isKind(of: NSString()) != nil) && ((profileDictionary.object(forKey: "address") as AnyObject).length>0)
                {
                    addressField.text = profileDictionary.object(forKey: "address") as? String
                    
                }
                else
                {
                    addressField.text = ""
                }
            }
            else if ((indexPath as NSIndexPath).row == 4)
            {
                phone = cell.viewWithTag(10) as! UITextField
                
                if (profileDictionary.object(forKey: "phone_number") != nil) //&& ((profileDictionary.object(forKey: "phone_number") as AnyObject).isKind(of: NSString()) != nil) && ((profileDictionary.object(forKey: "phone_number") as AnyObject).length>0)
                {
                    phone.text = profileDictionary.object(forKey: "phone_number") as? String
                }
                else
                {
                    phone.text = ""
                }
                phone.keyboardType = UIKeyboardType.phonePad
            }
            
            
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
  
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0
        {
            return 160
        }
        else if (indexPath as NSIndexPath).row == 5
        {
            return 65
        }
        else
        {
            return 68
        }
        
        
    }
    
    
    /**
    This IBAction is called to pop back to previous screen.
    
    - parameter sender: UIButton type
    */
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Add Image
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        photoEdited = true
        //        edit_img = true
//        let url = info[UIImagePickerControllerReferenceURL] as! NSURL
//        print("url:\(url)")
        
//
//        
//        let mediaurl = info[UIImagePickerControllerMediaURL]
//        print("mediaurl:\(mediaurl)")
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //profile.contentMode = .ScaleAspectFill
            profile.layer.cornerRadius = profile.frame.size.width/2
            profile.clipsToBounds = true
            profile.image = pickedImage
            
            let selectedImage: UIImage = pickedImage
            let fileManager = FileManager.default
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            let filePathToWrite = "\(paths)/nric_photo.png"
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
    
    func doneTyping()
    {
        view.endEditing(true)
    }
    
    //MARK: Get Profile Details
    func getProfileDetails()
    {
        if appdelegate.hasConnectivity()
        {
            
            
            //appdelegate.showCustomHudLoader(self.view)
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
            
            let param=["id_user":(user_id)!,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(viewProfile_URL)"
           
            manager.post("\(url)",parameters: param, success: {
                    (operation,responseObject)in
                
                    print(responseObject)
                 if let result = responseObject as? NSDictionary{
                    
                    let json = result.mutableCopy() as! NSMutableDictionary
                    
                    appdelegate.hideProgressHudInView(self.view)
                    
                    let status = result.object(forKey: "success")! as! Int
                    if(status == 0)
                    {
                        let msg = result.object(forKey: "message")! as! String
                        
                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        
                    }
                    else
                    {
                        self.profileDictionary = json.object(forKey: "data") as! NSDictionary
                        
                        if (self.profileDictionary.object(forKey: "name") != nil) //&& ((self.profileDictionary.object(forKey: "name")? as AnyObject).isKind(of: NSString) != nil) && ((self.profileDictionary.object(forKey: "name")? as AnyObject).length>0)
                        {
                            self.nameField.text = (self.profileDictionary.object(forKey: "name") as? String)
                        }
                        else
                        {
                            self.nameField.text = ""
                        }
                        if (self.profileDictionary.object(forKey: "phone_number") != nil)// && ((self.profileDictionary.object(forKey: "phone_number")? as AnyObject).isKind(of: NSString) != nil) && (self.profileDictionary.object(forKey: "phone_number")?.length>0)
                        {
                            self.phone.text = self.profileDictionary.object(forKey: "phone_number") as? String
                        }
                        else
                        {
                            self.phone.text = ""
                        }
                        
                        if (self.profileDictionary.object(forKey: "address") != nil) //&& ((self.profileDictionary.object(forKey: "address") as AnyObject).isKind(of: NSString) != nil) && (self.profileDictionary.object(forKey: "address")?.length>0)
                        {
                            self.addressField.text = self.profileDictionary.object(forKey: "address") as? String
                        }
                        else
                        {
                            self.addressField.text = ""
                        }
                        
                    }
                    self.tableView.reloadData()
                    
                }
                }, failure: { (operation: URLSessionTask?,
                    error: Error) in
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
    
    //MARK: Edit Button Action
    @IBAction func editButtonClicked()
    {
        editButtonSelected = true
        
        editButton.isHidden = true
        
        doneButton.isHidden = false
        
        let btn = self.view.viewWithTag(34) as! UIButton
        
        btn.isHidden = false
        
        let textfield = self.view.viewWithTag(10) as! UITextField
        
        textfield.isUserInteractionEnabled = true
        
        self.nameField.isUserInteractionEnabled = true
        
        self.phone.isUserInteractionEnabled = true

        self.addressField.isUserInteractionEnabled = true
        
//        tableView.reloadData()
    }
    
    //MARK: Change Password Button Action
    @IBAction func changePasswordButton()
    {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ChangePasswordVC: ChangePasswordViewController! = mainStoryboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        
        self.navigationController?.pushViewController(ChangePasswordVC, animated: true)
    }
    
    //MARK: While editing Done Button Action
    @IBAction func doneButtonClicked()
    {
        view.endEditing(true)
        
        if(nameField.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Name." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
            
        else if(addressField.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Address." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
            
        else if(phone.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Phone Number." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
//        else if(!commonValidations.isValidBNumber(phone.text!.replacingOccurrences(of: "+", with: "") ) || (phone.text!.replacingOccurrences(of: "+", with: "")).utf16.count<8 || (phone.text!.replacingOccurrences(of: "+", with: "") ).utf16.count>15)
//        {
//            let msg:AnyObject = "Please enter valid Phone Number." as AnyObject
//            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//            return
//        }

//        else if(!commonValidations.isValidBNumber(phone.text) || (count(phone.text)<8 || count(phone_no.text)>15))
//        {
//            let msg:AnyObject = "Please enter valid Phone Number."
//            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//            return
//            
//        }
        
        self.profileEdited()
        
    }
    
    //MARK: Save Edited Data
    func profileEdited()
    {
        
        var nricdata: NSData!
        
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let getnric = "\(paths)/nric_photo.png"

        if (fileManager.fileExists(atPath: getnric))
        {
            print("FILE AVAILABLE");
            
            //Pick Image and Use accordingly
            
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
            
            let param=["id_user":(user_id)!,"name":(nameField.text)!,"email":(profileDictionary.object(forKey: "email"))!,"address":(addressField.text)!,"phone_number":(phone.text)!,"password":"","mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(editProfile_URL)"
            manager.post("\(url)", parameters: param, constructingBodyWith:
                {
                    (formData : AFMultipartFormData!) -> Void in
                    
                    // let imageData = UIImagePNGRepresentation(self.nricImageView.image)
                    if (self.photoEdited == true)
                    {
                        formData.appendPart(
                            withFileData: nricdata as Data,
                            name: "profile_pic",
                            fileName: "nric_photo.png",
                            mimeType: "image/png")
                        
                    }
                    
                },
                
                success: {
                    (operation,responseObject)in
                    
                    
                    if let result = responseObject as? NSDictionary{
                    print(responseObject)
                    let status = result.object(forKey: "success")! as! Int
                    
                    appdelegate.hideProgressHudInView(self.view)
                    
                 
                    if(status == 0)
                    {
                        let msg = result.object(forKey: "message")! as! String
                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                    }
                    else
                    {
                        
                         let msg = result.object(forKey: "message")! as! String
                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                        self.editButtonSelected = false
                        self.editButton.isHidden = false
                        self.doneButton.isHidden = true
                        var timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(MyProfileViewController.getProfileDetails), userInfo: nil, repeats: false)
                    }
                    }
                    
                },
                failure: { (operation: URLSessionTask?,
                    error: Error) in
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
