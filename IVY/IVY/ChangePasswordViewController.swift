//
//  ChangePasswordViewController.swift
//  IVY
//
//  Created by Singsys on 06/11/15.
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


class ChangePasswordViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate
{
    @IBOutlet var tableview:UITableView!
    var oldpassword:String!
    var newPassword:String!
    var confirmPassword:String!
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
       self.tableview.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChangePasswordViewController.doneTyping))
        self.tableview.addGestureRecognizer(tapGesture)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!
        cellIdentifier = "ChangePasswordCell"
        
        cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell == nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        let settings = cell.viewWithTag(11) as! UILabel!
        if ((indexPath as NSIndexPath).row == 0)
        {
            settings?.text = "Old Password"
        }
        else if ((indexPath as NSIndexPath).row == 1)
        {
            settings?.text = "New Password"
        }
        else if ((indexPath as NSIndexPath).row == 2)
        {
            settings?.text = "Re-Type Password"
        }
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    //MARK: BAck button clicked.
    //MARK:
    
    /**
    Function for navigating to previous screen
    
    - parameter sender: UIButton type.
    */
    
    @IBAction func backBtnClicked(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
        
        
    }
    
    //MARK: SAVE button clicked.
    //MARK:
    
    /**
    Function for navigating to previous screen
    
    - parameter sender: UIButton type.
    */
    
    @IBAction func saveBtnClicked(_ sender: UIButton)
    {
        view.endEditing(true)
        if(oldpassword==nil||oldpassword.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Old Password." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
                        
        else if(newPassword==nil||newPassword.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter New Password." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
            
        else if((newPassword)?.utf16.count<8)
        {
            let msg:AnyObject = "Please enter password of minimum 8 characters." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
            return
        }
        else if((newPassword)?.utf16.count>12)
        {
            let msg:AnyObject = "Please enter password of minimum 8 and maximum 12 characters." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
            return
        }
            
        else if(confirmPassword==nil||confirmPassword.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Re-Type Password." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if(!(confirmPassword == newPassword))
        {
            let msg:AnyObject = "New Password does not match Re-Type Password." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else
        {
            changePassword()
        }
        
    }
    
    //MARK: Done Typing
    func doneTyping()
    {
        view.endEditing(true)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let hitpoint: CGPoint = textField.convert(CGPoint.zero, to: tableview)
        let indexPath: IndexPath = tableview.indexPathForRow(at: hitpoint)!
        
        if ((indexPath as NSIndexPath).row == 0)
        {
            oldpassword = textField.text
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            newPassword = textField.text
        }
        else if (indexPath as NSIndexPath).row == 2
        {
            confirmPassword = textField.text
        }
    }
    
    func textFieldShouldReturn(_ oldpassword: UITextField) -> Bool {
        
        
        oldpassword.resignFirstResponder()
        return true;
        
    }

    
    //MARK: Extract GEneral Settings
    func changePassword()
    {
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
        
        let param = ["user_id":(user_id)!,"old_password":(oldpassword)!,"new_password":(newPassword)!,"confirm_password":(confirmPassword)!,"mode":""] as NSDictionary
        print(param)
        let url="\(base_URL)\(changePassword_URL)"
          
        manager.post("\(url)",
            parameters: param,
            success: { (operation,responseObject)in
             
               print(responseObject)
                
                if let result = responseObject as? NSDictionary{

//                _ = (responseObject as AnyObject).mutableCopy() as! NSMutableDictionary
                
                appdelegate.hideProgressHudInView(self.view)
                    
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
                    
                    self.navigationController?.popViewController(animated: true)
                }
                self.tableview.reloadData()
                }
            },
            failure: { (operation: URLSessionTask?,
                error: Error) in
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
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
