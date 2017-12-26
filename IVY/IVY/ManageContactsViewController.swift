//
//  ManageContactsViewController.swift
//  IVY
//
//  Created by Singsys on 06/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import AddressBook


class ManageContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,edited , UIAlertViewDelegate {
    
    var refreshControl:UIRefreshControl!
    var edit = true
    var defaultSet = false
    var indexPth = Int()
    var contactList : NSMutableArray = []
    
    var indexpath:IndexPath!
    @IBOutlet var tableView:UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ManageContactsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(refreshControl)
        
        self.tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ManageContactsViewController.longPressGestureRecognized(_:))))
        
        
        let status = ABAddressBookGetAuthorizationStatus()
        
        if status == .denied || status == .restricted
        {
            // user previously denied, to tell them to fix that in settings
            //                    appdelegate.hideProgressHudInView(self)
            //                    appdelegate.showMessageHudWithMessage("Permission Not Granted", delay: 2.0)
            return
        }
        
        var error: Unmanaged<CFError>?
        
        let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        if addressBook == nil {
            print(error?.takeRetainedValue())
            return
        }
        
        ABAddressBookRequestAccessWithCompletion(addressBook)
        {
            granted, error in
            
            
            if !granted
            {
                // warn the user that because they just denied permission, this functionality won't work
                // also let them know that they have to fix this in settings
                //                appdelegate.hideProgressHudInView(self)
                
                
                return
            }
            
                       
        }

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
        let noRecord = view.viewWithTag(777) as! UILabel!
        noRecord?.isHidden = true
        if edit == true
        {
            self.myContacts()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: UITableView Delegates
    //MARK:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return contactList.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        indexPth = (indexPath as NSIndexPath).row
        
        let contactType = (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "contact_type") as? String
        
        let isPhoneBookUser = (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "is_phonebook_user") as? String
        
        if contactType?.lowercased() == "phonebook contact" || isPhoneBookUser == "1"
        {
            defaultSet = true
            let alert = UIAlertView()
            
            alert.title = "Ivy App"
            alert.message = "Do you want to mark this contact as Default Contact?"
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
            alert.delegate=self
            alert.show()
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!

        let contactType = (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "contact_type") as? String
        
        if contactType?.lowercased() == "phonebook contact"
        {
            
             cellIdentifier = "phoneContactsCell"
        }
        else
        {
             cellIdentifier = "contactsCell"
            
        }
        
       
        cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        
        let checkImg = cell.viewWithTag(66) as! UIImageView
        
        let profileImg = cell.viewWithTag(55) as! UIImageView
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        
        profileImg.image = UIImage(named: "myPic")

        
        if UserDefaults.standard.object(forKey: "defaultNumber") as! String == (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as! String
        {
            checkImg.image = UIImage(named: "done_prof")
        }
        else
        {
            checkImg.image = UIImage(named: "")
        }
       
   

        if let photoUrl=(self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "user_image") as? String
        {
            profileImg.clipsToBounds = true
            if photoUrl != ""
            {
                 profileImg.setImageWith(URL(string: "\(photoUrl)")!, placeholderImage: UIImage(named: "myPic"))
            }
            else
            {
                profileImg.image = UIImage(named: "myPic")
            }
            
            
           
//            profileImg.setImageWith(URL(string: photoUrl)!)
        }
        else
        {
            profileImg.image = UIImage(named: "myPic")
        }
        
        
        
        let name = cell.viewWithTag(1) as! UILabel
        name.text=(self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "user_name") as? String
        
        if name.text?.isEmpty == true
        {
            name.text = "No name"
        }
        
        let iconImg = cell.viewWithTag(45) as! UIImageView!
        
        if contactType?.lowercased() == "phonebook contact"
        {
            let phone_number = cell.viewWithTag(2) as! UILabel
            
            phone_number.text=(self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as? String
            
            iconImg?.image = UIImage(named: "phnbk")
        }
        else
        {
            iconImg?.image = UIImage(named: "apusr")
            
        }
        
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    
    //MARK: UIAlertView Delegate
    //MARK:
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
    {
        
        switch buttonIndex {
        case 0:
            print("yes")
            if defaultSet == true
            {
               self.defaultUser()
            }
            else
            {
            self.deleteUser()
            }
            
            break;
        case 1:
            
            print("no")
            
            self.defaultSet = false
            
            break;
        default:
            break
            
        }
        
    }
    
    //MARK:- webservices
    func deleteUser()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"id_contact":((contactList.object(at: indexpath.row) as AnyObject).object(forKey: "id_contact") as! String!),"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(deleteUser_URL)"
            
            let phone_number = (contactList.object(at: indexpath.row) as AnyObject).object(forKey: "phone_number") as! String!
            
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in
                            
                            print(responseObject as Any)
                            
                            appdelegate.hideProgressHudInView(self.view)
                            
                            if let result = responseObject as? NSDictionary{
                            
                            let status = result.value(forKey: "success")! as! Int
                            if(status == 0)
                            {
                                let msg = result.value(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                            }
                            else
                            {
                                let msg = result.value(forKey: "message")! as! String
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                self.contactList.removeObject(at: self.indexpath.row)
                                
                                if UserDefaults.standard.object(forKey: "contact_number") != nil
                                {
                                    let ContactArray = UserDefaults.standard.object(forKey: "contact_number") as! NSArray
                                    
                                    let tempArray = ContactArray.mutableCopy() as! NSMutableArray
                                    
                                        if tempArray.contains(phone_number!)
                                        {
                                           tempArray.remove(phone_number)
                                        }
                                    
                                   
                                    
                                    UserDefaults.standard.setValue(tempArray, forKey: "contact_number")
                                    
                                }
                                
                                if UserDefaults.standard.object(forKey: "defaultNumber") != nil
                                {
                                    if UserDefaults.standard.object(forKey: "defaultNumber") as! String == phone_number!
                                    {
                                        UserDefaults.standard.set("", forKey: "defaultNumber")
                                    }
                                }
                                
                                if self.contactList.count == 0
                                {
                                    UserDefaults.standard.removeObject(forKey: "contact_number")
                                }
                                
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
    
    
    func defaultUser()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"default_number":(contactList.object(at: indexPth) as AnyObject).object(forKey: "phone_number") as! String!,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(defaultUser_URL)"
            
            
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
                                let msg = result.object(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                //self.contactList.removeObjectAtIndex(self.indexpath.row)
                                
                                UserDefaults.standard.setValue((self.contactList.object(at: self.indexPth) as AnyObject).object(forKey: "phone_number") as! String!, forKey: "defaultNumber")
                                
                                self.defaultSet = false
                                
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

    
    func myContacts()
    {
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"search_key":"","page_number":"","mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(manageContact_URL)"
            
            
            manager.post("\(url)",
                         parameters: param,progress: nil,
                         
                         success: {
                            
                            (task, responseObject) in
                            
                            print(responseObject)
                            appdelegate.hideProgressHudInView(self.view)
                            
                              if let result = responseObject as? NSDictionary{
                            
                            let status = result.value(forKey: "success")! as! Int
                                
                            if(status == 0)
                            {
                                let msg = result.object(forKey: "message")! as! String
                                
                                 appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                
                            }
                            else
                            {
//                                  let msg = result.object(forKey: "message")! as! String
//                                
//                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                 self.contactList.removeAllObjects()
                                let temp = result.object(forKey: "data") as! NSArray
                                self.contactList = temp.mutableCopy() as! NSMutableArray
                            }
                                if UserDefaults.standard.object(forKey: "contact_number") != nil
                                {
                                    let ContactArray = UserDefaults.standard.object(forKey: "contact_number") as! NSArray
                                    
                                    let tempArray = ContactArray.mutableCopy() as! NSMutableArray
                                    
                                    for i in 0..<self.contactList.count
                                    {
                                        let contactDictionary = self.contactList.object(at: i) as! NSDictionary
                                        
                                        let phone_number = contactDictionary.object(forKey: "phone_number") as! String
                                        
                                        if !tempArray.contains(phone_number)
                                        {
                                            tempArray.add(phone_number)
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    UserDefaults.standard.setValue(tempArray, forKey: "contact_number")
                                }
                                else
                                {
                                    let tempArray =  NSMutableArray()
                                    
                                    for i in 0..<self.contactList.count
                                    {
                                        let contactDictionary = self.contactList.object(at: i) as! NSDictionary
                                        
                                        let phone_number = contactDictionary.object(forKey: "phone_number") as! String
                                        
                                        if !tempArray.contains(phone_number)
                                        {
                                            tempArray.add(phone_number)
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    UserDefaults.standard.setValue(tempArray, forKey: "contact_number")
                                }
                                
                                
                            self.tableView.reloadData()
                                
                                _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(ManageContactsViewController.refreshTable), userInfo: nil, repeats: false)
                               
                                
                            if self.contactList.count <= 0
                            {
                                let noRecord = self.view.viewWithTag(777) as! UILabel!
                                noRecord?.isHidden = false
                                
                                UserDefaults.standard.removeObject(forKey: "contact_number")
                            }
                            else
                            {
                                let noRecord = self.view.viewWithTag(777) as! UILabel!
                                noRecord?.isHidden = true
                                
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
    
    func refreshTable()
    {
        self.tableView.reloadData()
    }

    
    //MARK:-  @IBAction func
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        let addcontactsview=storyboard?.instantiateViewController(withIdentifier: "AddContactsViewController") as! AddContactsViewController
        addcontactsview.alreadyAddedContact.addObjects(from: [self.contactList])
//        addcontactsview.alreadyAddedContact = self.contactList
        if sender.tag == 50
        {
            addcontactsview.viewType = "appUser"
        }
        else
        {
            addcontactsview.viewType = "PhoneBook"
        }
        
        addcontactsview.delegate = self
        self.navigationController?.pushViewController(addcontactsview, animated: true);
        
    }
    
    //MARK:-  helping func
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer)
    {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.ended)
        {
            
            let longPress = gestureRecognizer as! UILongPressGestureRecognizer
            
            //let state = longPress.state
            
            let locationInView = longPress.location(in: self.tableView)
            
            let indexPath = self.tableView.indexPathForRow(at: locationInView)
            
            indexpath=indexPath
            
            let alert = UIAlertView()
            
            alert.title = "Ivy App"
            alert.message = "Do you want to remove this contact?"
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
            alert.delegate=self
            alert.show()
            
        }
    }

    func contactEdited(_ edited:Bool)
    {
        self.edit = edited
    }
    
    func refresh(_ sender:AnyObject)
    {
        self.refreshControl.endRefreshing()
        self.myContacts()
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
   }
