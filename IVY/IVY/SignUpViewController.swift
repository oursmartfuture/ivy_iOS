//
//  SignUpViewController.swift
//  IVY
//
//  Created by Singsys on 10/23/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SignUpViewController: UIViewController,getCode {
    //@IBOutlet weak var bottomConst: NSLayoutConstraint!
    var phonecd = true
    var tapGesture:UITapGestureRecognizer!
    @IBOutlet var name:UITextField!
    @IBOutlet var email:UITextField!
    @IBOutlet var phone:UITextField!
    @IBOutlet var countrycode:UITextField!
    @IBOutlet var password:UITextField!
    @IBOutlet var confirmPassword:UITextField!
    @IBOutlet var scrollView:UIScrollView!
    // @IBOutlet var phoneCode:UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let popView = view.viewWithTag(100) as UIView!
        popView?.isHidden = true
        if UIScreen.main.bounds.height>500{
            //bottomConst.constant = 200
        }
        
        
        name.attributedPlaceholder = NSAttributedString(string:"Name",
                                                        attributes:[NSForegroundColorAttributeName: UIColor.black])
        email.attributedPlaceholder = NSAttributedString(string:"Email",
                                                         attributes:[NSForegroundColorAttributeName: UIColor.black])
        
        phone.attributedPlaceholder = NSAttributedString(string:"Phone",
                                                         attributes:[NSForegroundColorAttributeName: UIColor.black])
        password.attributedPlaceholder = NSAttributedString(string:"Password",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.black])
        confirmPassword.attributedPlaceholder = NSAttributedString(string:"Confirm Password",
                                                                   attributes:[NSForegroundColorAttributeName: UIColor.black])
        
//        let questionButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-30, y: 30, width: 20, height: 20))
//        questionButton.setImage(UIImage(named: "questionmark.png"), for: UIControlState())
//        questionButton.isUserInteractionEnabled = false
//        scrollView.addSubview(questionButton)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.endTapClicked))
        //tapGesture.addTarget(self, action: tapDetect())
        tapGesture.numberOfTapsRequired=1
        tapGesture.numberOfTouchesRequired=1
        self.view.addGestureRecognizer(tapGesture)
        let screenSize: CGRect = UIScreen.main.bounds
        
        //let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        if(screenHeight<568)
        { scrollView.contentSize=CGSize(width: 320,height: 570)}
        else
        { scrollView.contentSize=CGSize(width: 320,height: screenHeight)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func keyboardHide(_ sender:UIBarButtonItem)
    {
        if phonecd == true
        {
            phone.becomeFirstResponder()
            phonecd = false
        }
        else
        {
            password.becomeFirstResponder()
        }
        
    }
    
    
    //MARK: UITextField Delegate
    //MARK:
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == phone || textField == countrycode
        {
            let keyboardDoneButtonView: UIToolbar = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(SignUpViewController.keyboardHide(_:)))
            
            keyboardDoneButtonView.items = [flexSpace , doneButton] as NSArray as? [UIBarButtonItem]
            if textField == countrycode
            {
                phonecd = true
                self.countrycode.inputAccessoryView = keyboardDoneButtonView
            }
            else
            {
                phonecd = false
                self.phone.inputAccessoryView = keyboardDoneButtonView
            }
            //  phonepad = false
        }
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField==self.name)
        {
            self.email.becomeFirstResponder()
        }
        
        if(textField==self.email)
        {
            self.countrycode.becomeFirstResponder()
        }
        if(textField==self.countrycode)
        {
            self.phone.becomeFirstResponder()
        }
        
        if(textField==self.phone)
        {
            self.password.becomeFirstResponder()
        }
        if(textField==self.password)
        {
            self.confirmPassword.becomeFirstResponder()
        }
        
        if(textField==self.confirmPassword)
        {
            confirmPassword.resignFirstResponder()
            
            //           if (!( fabs(UIScreen.mainScreen().bounds.size.height - 568 ) < 1 ))
            //            {
            //                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            //            }
            //            else
            //            {
            //                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width,UIScreen.mainScreen().bounds.size.height);
            //
            //            }
            
            
        }
        return true
    }
    
    
    @IBAction func backToLogin(_ sender:UIButton)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    /**
     This function is called when sign up button is clicked.
     
     :param: sender UIButton type.
     */
    @IBAction func signUpBtn(_ sender:UIButton)
    {
        if(name.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Name." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
        else if(email.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Email." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
        else if(!commonValidations.isValidEmail(email.text!))
        {
            let msg:AnyObject = "Please enter valid Email." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
        else if(countrycode.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Country Code." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
            
        else if(phone.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Phone" as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
            
//        else if(!commonValidations.isValidBNumber(phone.text! + countrycode.text!.replacingOccurrences(of: "+", with: "")) || (phone.text! + countrycode.text!.replacingOccurrences(of: "+", with: "")).utf16.count<8 || (phone.text! + countrycode.text!.replacingOccurrences(of: "+", with: "")).utf16.count>15)
//        {
//            let msg:AnyObject = "Please enter valid Phone." as AnyObject
//            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
//            return
//        }
            
            
        else if(password.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Password" as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if((password.text)?.utf16.count<8)
        {
            let msg:AnyObject = "Please enter password of minimum 8 characters." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if((password.text)?.utf16.count>12)
        {
            let msg:AnyObject = "Please enter password of minimum 8 and maximum 12 characters." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
            
        else if(confirmPassword.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Confirm Password." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if(!(confirmPassword.text==password.text))
        {
            let msg:AnyObject = "Password does not match Confirm Password." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
            
        else
        {
            self.signup()
        }
    }
    
    
    /**
     This function is used to dismiss the keyboard when background is clicked.
     
     :param: sender UIButton.
     */
    func endTapClicked()
    {
        self.view.endEditing(true)
        
        if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        }
        else
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
            
        }
        
        
    }
    
    func signup()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            
            let param=["name":(name.text)!,"email":(email.text)!,"password":(password.text)!,"mode":"","phone_number":(countrycode.text! + phone.text!),"device_type":"","device_token":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(registration_URL)"
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
                if (status  == 0)
                {
                    let msg = result.object(forKey: "message") as! String
                    appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                    
                }
                else
                {
                    
                    let popView = self.view.viewWithTag(100) as UIView!
                    popView?.isHidden = false
                    
                    
                    
                    
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
    
    func keyboardWillShow(_ notification:Notification)
    {
        if let userInfo = (notification as NSNotification).userInfo
        {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                
                var rect = self.view.frame as CGRect
                rect.size.height -= keyboardSize.height
                // ...
            } else {
                // no UIKeyboardFrameBeginUserInfoKey entry in userInfo
            }
        } else {
            // no userInfo dictionary in notification
        }
        
        
    }
    
    
    func keyboardWillHide(_ notification:Notification)
    {
        let contentInsets = UIEdgeInsets.zero as UIEdgeInsets
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    
    
    
    @IBAction func okBtnClicked(_ sender:UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func countryCode(_ sender:UIButton)
    {
        let countrycodeview=storyboard?.instantiateViewController(withIdentifier: "CountryCodeViewController") as! CountryCodeViewController
        
        countrycodeview.delegate = self
        
        self.navigationController?.pushViewController(countrycodeview, animated: true);
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == countrycode
        {
            if countrycode.text?.utf16.count >= 4 && string != ""
            {
                return false
            }
        }
        return true
        
    }
    
    func getCode(_ code: String) {
        countrycode.text = code
    }
    
    
    
}
