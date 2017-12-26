//
//  ForgotPasswordViewController.swift
//  IVY
//
//  Created by Singsys on 10/23/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController,UITextFieldDelegate
{
    //  private var jobsListing: JobsListingViewController!
    //  private var jpHome: JpHomeViewController!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet var scrollView:UIScrollView!
    var checked:Bool=false
    
    var tapGesture:UITapGestureRecognizer!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let popView = view.viewWithTag(100) as UIView!
        popView?.isHidden = true
        if UIScreen.main.bounds.height>500{
            //bottomConst.constant = 200
        }
        
        emailField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.black])
//        let questionButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-30, y: 30, width: 20, height: 20))
//        questionButton.setImage(UIImage(named: "questionmark.png"), for: UIControlState())
//        questionButton.isUserInteractionEnabled = false
//        scrollView.addSubview(questionButton)
        
        let screenSize: CGRect = UIScreen.main.bounds
        //            let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        //
        
        if(screenHeight<568)
        { scrollView.contentSize=CGSize(width: 320,height: 650)}
        else
        { scrollView.contentSize=CGSize(width: 320,height: screenHeight)}
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.endTapClicked))
        //tapGesture.addTarget(self, action: tapDetect())
        tapGesture.numberOfTapsRequired=1
        tapGesture.numberOfTouchesRequired=1
        self.view.addGestureRecognizer(tapGesture)
        emailField.delegate=self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.navigationController?.isNavigationBarHidden=true
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //        let preference = NSUserDefaults.standardUserDefaults()
        //        if let check_box = preference.objectForKey("check") as? String
        //        {
        //            if(check_box=="true")
        //            {
        //                if let email_id = preference.objectForKey("email") as? String {
        //                    self.emailField.text = preference.objectForKey("email") as? String
        //                }
        //                if let pass = preference.objectForKey("password") as? String {
        //                    self.passwordField.text = preference.objectForKey("password") as? String
        //                }
        //                checked=true
        //                var checkbox=UIImage(named: "check Box_1")
        //                check.setImage(checkbox, forState: UIControlState.Normal)
        //            }
        //            else
        //            {
        //                emailField.text=""
        //                passwordField.text=""
        //            }
        //        }
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
        if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        }
        else
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
            
        }
        
    }
    
    
    //    /**
    //    This function is called when forgot password is selected on login page.
    //
    //    :param: sender UIButton type.
    //    */
    //    @IBAction func forgotPwd(sender: UIButton) {
    //
    //        forgotpwd=storyboard?.instantiateViewControllerWithIdentifier("ForgotPwdViewController") as! ForgotPwdViewController
    //        self.navigationController?.pushViewController(forgotpwd, animated: true);
    //
    
    //    }
    //
    /**
     This function is called when login button is clicked.
     
     :param: sender UIButton type.
     
     */
    
    
    
    @IBAction func backToLogin(_ sender:UIButton)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton)
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
            
        else
        {
            
            self.forgotPassword()
        }
        
        
        
    }
    
    /*  function to be called on keyboard get visible
     *
     *  @param note reference of NSNotofication
     */
    
    func keyboardWillShow(_ note: Notification) {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.endTapClicked))
        //tapGesture.addTarget(self, action: tapDetect())
        tapGesture.numberOfTapsRequired=1
        tapGesture.numberOfTouchesRequired=1
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    /**
     *  function to be called on keyboard get invisible
     *
     *  @param note reference of NSNotofication
     */
    
    
    func keyboardWillHide(_ note: Notification) {
        
        self.view.removeGestureRecognizer(tapGesture)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    
    
    
    /**
     This function is called when checkbox is checked.
     
     :param: sender AnyObject type.
     */
    
    
    /**
     This function is called when Forgot Password webservice is to be fired.
     */
    func forgotPassword()
    {
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            
            
            let param=["email":(emailField.text)!,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(forgotpwd_URL)"
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
                            if(status == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (UIScreen.main.bounds.size.height == 568 ) || (UIScreen.main.bounds.size.height > 568 )
        {
            
            //view.frame.origin.y = -100
        }
        else
        {
            view.frame.origin.y = -100
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField==self.emailField)
        {
            emailField.resignFirstResponder()
            
            if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
            {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
            }
            else
            {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
                
            }
            
            
        }
        return true
    }
    @IBAction func okBtnClicked(_ sender:UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
}
