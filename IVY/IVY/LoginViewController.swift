//
//  LoginViewController.swift
//  IVY
//
//  Created by Singsys on 10/23/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var check:UIButton!
    
    var checked:Bool=true
    var login:Bool=false
    var tapGesture:UITapGestureRecognizer!
    var c=1
    var role=""
    var valid=""
    var cstep = ""
    var signUpViewController: SignUpViewController!
     var alert : UIAlertController = UIAlertController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        emailField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.black,])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.black])
        
        
        
//        let questionButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-30, y: 30, width: 20, height: 20))
//        questionButton.setImage(UIImage(named: "questionmark.png"), for: UIControlState())
//        questionButton.isUserInteractionEnabled = false
//        scrollView.addSubview(questionButton)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        //let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        if(screenHeight<568)
        { scrollView.contentSize=CGSize(width: 320,height: 570)}
        else
        { scrollView.contentSize=CGSize(width: 320,height: screenHeight)}
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.endTapClicked))
        //tapGesture.addTarget(self, action: tapDetect())
        tapGesture.numberOfTapsRequired=1
        tapGesture.numberOfTouchesRequired=1
        self.view.addGestureRecognizer(tapGesture)
        emailField.delegate=self
        passwordField.delegate=self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let preference = UserDefaults.standard
        if let check_box = preference.object(forKey: "check") as? String
        {
            if(check_box=="true")
            {
                if let _ = preference.object(forKey: "email") as? String {
                    self.emailField.text = preference.object(forKey: "email") as? String
                }
                if (preference.object(forKey: "password") as? String) != nil {
                    self.passwordField.text = preference.object(forKey: "password") as? String
                }
                checked=true
                c=1
                check.setImage(UIImage(named: "checked"), for: UIControlState())
            }
            else
            {
                emailField.text=""
                passwordField.text=""
                checked=false
                c=0
                check.setImage(UIImage(named: "checkbox"), for: UIControlState())
            }
        }
        
        //for key board handling
        self.registerForKeyboardNotifications()

        
        self.navigationController?.isNavigationBarHidden=true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
         self.view.endEditing(true)
        
        //for key board handling
        self.deregisterFromKeyboardNotifications()
    }

    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     This function is used to dismiss the keyboard when background is clicked.
     
     :param: sender UIButton.
     */
    func endTapClicked()
    {
        self.view.endEditing(true)
//        if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
//        {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
//        }
//        else
//        {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
//            
//        }
        
    }
    
    
    //    /**
    //    This function is called when forgot password is selected on login page.
    //
    //    :param: sender UIButton type.
    //    */s
    @IBAction func forgotPwd(_ sender: UIButton) {
        
        
        let forgotpwd=storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotpwd, animated: true);
        
    }
    /**
     This function is called when login button is clicked.
     
     :param: sender UIButton type.
     */
    @IBAction func loginBtnClicked(_ sender: UIButton)
    {
        self.view.endEditing(true)
        
//        if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
//        {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
//        }
//        else
//        {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
//            
//        }
        
        if(emailField.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Email." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if(!commonValidations.isValidEmail(emailField.text!))
        {
            let msg:AnyObject = "Please enter valid Email." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
        else if(passwordField.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg = "Please enter Password."
            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
            return
        }
            
        else
        {
            if(checked==true)
            {
                let preference = UserDefaults.standard
                preference.set(self.emailField.text, forKey: "email")
                preference.set(self.passwordField.text, forKey: "password")
                preference.set("true", forKey: "check")
            }
            else if(checked==false)
            {
                let preference = UserDefaults.standard
                preference.set("false", forKey: "check")
            }
            
            self.loginDetails()
        }
        
        
        
    }
    
    
    
  
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        if (!(fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
//        {
//            
//            view.frame.origin.y = -70
//        }
//        else
//        {
//            view.frame.origin.y = -50
//        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField==self.emailField)
        {
            self.passwordField.becomeFirstResponder()
        }
        if(textField==self.passwordField)
        {
            passwordField.resignFirstResponder()
//            if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
//            {
//                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
//            }
//            else
//            {
//                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
//                
//            }
            
        }
        return true
    }
    
    
    @IBAction func newAccountBtnClicked(_ sender:UIButton)
    {
        let sign=storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(sign, animated: true)
        
    }
    
    
    /**
     This function is called when checkbox is checked.
     
     :param: sender AnyObject type.
     */
    
    @IBAction func checkboxChecked(_ sender:AnyObject)
    {
        if(c%2==0)
        {
            let checkbox=UIImage(named: "checked")
            check.setImage(checkbox, for: UIControlState())
            c=c+1
            checked=true
        }
        else
        {
            let checkbox=UIImage(named: "checkbox")
            check.setImage(checkbox, for: UIControlState())
            c=c+1
            checked=false
            
        }
    }
    
    /**
     This function is called when login webservice is to be fired.
     */
    func loginDetails()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            
            manager.responseSerializer = serializer
            
            let param = NSMutableDictionary()
            
            param.setObject("\((emailField.text)!)", forKey: "email" as NSCopying)
            param.setObject("\((passwordField.text)!)", forKey: "password" as NSCopying)
            param.setObject("", forKey: "mode" as NSCopying)
            param.setObject("2", forKey: "device_type" as NSCopying)
            
//            let param=["email":(emailField.text)!,"password": (passwordField.text)!,"mode":"","device_type":"2"] as NSDictionary
            if UserDefaults.standard.object(forKey: "device_token") != nil
            {
                 param.setObject("\(UserDefaults.standard.object(forKey: "device_token") as! String)", forKey: "device_token" as NSCopying)
//                param["device_token"] = UserDefaults.standard.object(forKey: "device_token") as! String
            }
            else
            {
                 param.setObject("", forKey: "device_token" as NSCopying)
            }
            
            print(param)
            let url="\(base_URL)\(login_URL)"
            //        let url = String(map(s.generate()) {
            //            $0 == " " ? "+" : $0
            //            })
            manager.post("\(url)",
                parameters: param,progress: nil,
                
                success: {
                    
                    (task,responseObject) in
                    
                    print(responseObject)
                    
                    appdelegate.hideProgressHudInView(self.view)
                    
                    if let result = responseObject as? NSDictionary{
                        
                        let status  = result.object(forKey: "success") as! Int
                        
                        if(status  == 0)
                        {
                            //                        let msg:Any = (responseObject as AnyObject).object(forKey: "message")!
                            
                            let msg = result.object(forKey: "message") as! String
                            
                            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            self.passwordField.text = ""
                            
                        }
                        else
                        {
                            let data = result.object(forKey: "data") as! NSDictionary
                            
                            UserDefaults.standard.setValue(data.object(forKey: "id_user"), forKey: "user_id")
                            
                            UserDefaults.standard.set(true, forKey: "login")
                            
                            if let contactNumber = result.object(forKey: "contact_number") as? NSArray
                            {
                                
                                
                                 UserDefaults.standard.setValue(contactNumber, forKey: "contact_number")
                            }
//                            else
//                            {
//                                let contactDictionary = [""]
//                                 UserDefaults.standard.setValue(contactDictionary, forKey: "contact_number")
//                            }
                            
                           
                            
                               UserDefaults.standard.setValue(data.object(forKey: "default_number"), forKey: "defaultNumber")
                            
                                if data.object(forKey: "default_ringtone") as! String != ""
                                {
                                    UserDefaults.standard.setValue(data.object(forKey: "default_ringtone"), forKey: "defaultRingtone")
                                }
                                else
                                {
                                  UserDefaults.standard.setValue("0", forKey: "defaultRingtone")
                                }
                            
                            appdelegate.loactionUpdate()
                            
                            UserDefaults.standard.setValue(data.object(forKey: "default_number"), forKey: "defaultNumber")
                            UserDefaults.standard.setValue(data.object(forKey: "alert_type_ring"), forKey: "alertTypeRing")
                            UserDefaults.standard.setValue(data.object(forKey: "connection_fading"), forKey: "connectionFading")
                            UserDefaults.standard.setValue(data.object(forKey: "left_battery"), forKey: "leftBattery")
                            UserDefaults.standard.setValue(data.object(forKey: "view_notification"), forKey: "viewNotification")
                            
                            appdelegate.isLoggedOut = false
                            
                            if  let tempNotificationArray = result.object(forKey: "notification") as? NSArray
                            {
                                
                                let notificationArray = tempNotificationArray.mutableCopy() as! NSMutableArray
                                
                                if notificationArray.count > 0
                                {
                                    self.sendNotification(notificationArray: notificationArray)
                                    
                                }
                                else
                                {
                                    self.navigate()
                                    
                                }
                                
                            }
                            else
                            {
                                self.navigate()
                                
                            }
                            
                            
                            
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
    
    
    
    //MARK: Local Notification 
    
    func sendNotification(notificationArray:NSMutableArray) {
        
        let localNotification = UILocalNotification()
        
       
            
                       //                    self.sendAlert()
            print("Permission to record not granted")
            
        
            for i in 0..<notificationArray.count
            {
                let str = (notificationArray.object(at: i) as AnyObject).object(forKey: "notification_data") as? String
                
                let result = convertStringToDictionary(text: str!)! as [String:AnyObject]
                
                print(result)
                
                
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
                
                localNotification.alertBody = result["message"] as! String?
                
                localNotification.alertAction = result["action"] as! String?
                
                localNotification.timeZone = NSTimeZone.default
                
                
                
                UIApplication.shared.scheduleLocalNotification(localNotification)
                
            
            
               localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + notificationArray.count
        
        }
        
        let home=storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        if notificationArray.count > 0
        {
            home.pendingNotification = "\(notificationArray.count)"
        }
        
        self.navigationController?.pushViewController(home, animated: true)
        
       
        
       
    }
    
    
 
    
    
    
    // navigating on home view controller
    func navigate()
    {
        
        let home=storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(home, animated: true)
    }
    
    @IBAction func helpButtonClicked(_ sender: AnyObject) {
        
        alert = UIAlertController(title: "Ivy App", message: "Select option", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        
        alert.addAction(UIAlertAction(title: "About us", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            let staticview = self.storyboard?.instantiateViewController(withIdentifier: "StaticViewController") as! StaticViewController
            staticview.viewType = "about"
            self.navigationController?.pushViewController(staticview, animated: true);
        } ))
        
        alert.addAction(UIAlertAction(title: "Privacy Policy", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let staticview = self.storyboard?.instantiateViewController(withIdentifier: "StaticViewController") as! StaticViewController
            staticview.viewType = "privacy"
            self.navigationController?.pushViewController(staticview, animated: true);
        }))
        alert.addAction(UIAlertAction(title: "Terms & Conditions", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let staticview = self.storyboard?.instantiateViewController(withIdentifier: "StaticViewController") as! StaticViewController
            staticview.viewType = "Terms"
            self.navigationController?.pushViewController(staticview, animated: true);
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK:- Key Board Handling
    func registerForKeyboardNotifications ()-> Void   {
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications () -> Void {
        
        let center:  NotificationCenter = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWasShown (notification: NSNotification) {
        
        self.scrollView.isScrollEnabled = true
        
        if let userInfo = notification.userInfo
        {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                
                let insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, (keyboardSize.height)+30, 0)
                
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
                
            }
        }
        
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        
        let info : NSDictionary = notification.userInfo! as NSDictionary
        if let userInfo = notification.userInfo
        {
            if ((userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                let insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
            }
        }
        self.scrollView.scrollsToTop = true
        self.scrollView.isScrollEnabled = true
        
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

    
    
}
