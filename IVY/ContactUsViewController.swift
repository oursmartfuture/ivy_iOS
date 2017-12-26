//
//  ContactUsViewController.swift
//  IVY
//
//  Created by Singsys on 02/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var user_id = ""
    var emailTextfield: UITextField!
    var descriptionTextview: UITextView!
    var popupDel:UIView!
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user_id = UserDefaults.standard.object(forKey: "user_id") as! String
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ContactUsViewController.doneTyping))
        self.tableView.addGestureRecognizer(tapGesture)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
       
        popupDel = view.viewWithTag(100) as UIView! // Delete popup
        popupDel.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hideButtonClicked(_ sender: AnyObject) {
        
        popupDel.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell!
        
        let cellIdentifier:String
        
        if (indexPath as NSIndexPath).row == 0
        {
            cellIdentifier = "emailCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            emailTextfield = cell.viewWithTag(22) as! UITextField!
            
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            cellIdentifier = "descriptionCell"
            
            cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
            
            if(cell==nil)
            {
                cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            }
            descriptionTextview = cell.viewWithTag(12) as! UITextView
        }
        
        
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0
        {
            return 89
        }
            
        else
            
        {
            return 175
            
        }
    }
    
    /**
     This function is called when Contacts Us webservice is to be fired.
     */
    @IBAction func submitBtnClicked(_ sender:UIButton)
    {
        
        if(emailTextfield.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="")
        {
            let msg:AnyObject = "Please enter Email." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
        }
        else if(!commonValidations.isValidEmail(emailTextfield.text!))
        {
            let msg:AnyObject = "Please enter valid Email." as AnyObject
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            return
            
        }
        else if(descriptionTextview.text!.trimmingCharacters(in: CharacterSet.whitespaces)=="" || descriptionTextview.text == "Write a description text here...")
        {
            let msg = "Please enter Description."
            appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
            return
        }
            
        else
        {
            if appdelegate.hasConnectivity()
            {
                appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
                
               let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
                let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
                manager.responseSerializer = serializer
                
                
                let param=["user_id":user_id,"email":(emailTextfield.text)!,"message":"","description":descriptionTextview.text,"mode":""] as NSDictionary
                print(param)
                let url="\(base_URL)\(contactUs_URL)"
                //        let url = String(map(s.generate()) {
                //            $0 == " " ? "+" : $0
                //            })
                manager.post("\(url)",
                             parameters: param,
                             success: {
                                (operation,responseObject)in
                                print(responseObject)
                                
                                appdelegate.hideProgressHudInView(self.view)
                                
                                if let result = responseObject as? NSDictionary{
                                
                                let status = result.object(forKey: "success")! as! Int
                                
                                if(status  == 0)
                                {
                                    let msg = result.object(forKey: "message")! as! String
                                    
                                    appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                }
                                else
                                {
                                    self.popupDel.isHidden = false
                                    self.emailTextfield.text = ""
                                    self.descriptionTextview.text = "Write a description text here..."
                                 }
                                }
                    },
                             failure: { (operation: URLSessionTask?,
                                error: Error) in
                                print("ERROR")
                                appdelegate.hideProgressHudInView(self.view)
                                let msg:AnyObject = "Failed due to an error" as AnyObject
                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                })}
                
            else
            {
                let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
            }
            
            
        }
        
    }
    
    
    
    // function for navigating to previous screen
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
       
    }
    
    @IBAction func okButtonClicked(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    func textViewDidBeginEditing(_ descriptionTextview: UITextView) {
        if descriptionTextview.text == "Write a description text here..."
            
        {
            descriptionTextview.text = ""
            
        }
        if (!(fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
        {
            // view.frame.origin.y = -90
        }
        else
        {
            view.frame.origin.y = -20
        }
        
        
    }
    
    func doneTyping()
    {
        
        view.endEditing(true)
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
    
    
    
    func textFieldShouldReturn(_ emailTextfield: UITextField) -> Bool {
        if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        }
        else
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
            
        }
        
        
        emailTextfield.resignFirstResponder()
        return true;
        
    }
    
    
    
    func textViewShouldReturn(_ descriptionTextview: UITextView) -> Bool {
        
        if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        }
        else
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
            
        }
        descriptionTextview.resignFirstResponder()
        return true;
        
    }
    
    
    func textView(_ descriptionTextview: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            if (!( fabs(UIScreen.main.bounds.size.height - 568 ) < 1 ))
            {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
            }
            else
            {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: UIScreen.main.bounds.size.height);
                
            }
            descriptionTextview.resignFirstResponder()
            return false
        }
        return true
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
