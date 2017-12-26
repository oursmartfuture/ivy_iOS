//
//  ManageContactsViewController.swift
//  IVY
//
//  Created by Singsys on 06/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import AddressBook


class ManageContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,edited {
    
    var refreshControl:UIRefreshControl!
var edit = true
    var contactList : NSMutableArray = []
  let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var indexpath:NSIndexPath!
    @IBOutlet var tableView:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:"))

        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBarHidden = true
        var noRecord = view.viewWithTag(777) as! UILabel!
        noRecord.hidden = true
        if edit == true
        {
        self.myContacts()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refresh(sender:AnyObject)
    {
        self.refreshControl.endRefreshing()
                    self.myContacts()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return contactList.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!
        
        
        cellIdentifier = "contactsCell"
        cell=tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let profileImg = cell.viewWithTag(55) as! UIImageView

        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        
    
        var photoUrl=self.contactList.objectAtIndex(indexPath.row).objectForKey("user_image") as? String
        
        if photoUrl?.isEmpty == false
        {
        
            profileImg.clipsToBounds = true
        profileImg.setImageWithURL(NSURL(string: photoUrl!)!)
        }

        let name = cell.viewWithTag(1) as! UILabel
        
        name.text=self.contactList.objectAtIndex(indexPath.row).objectForKey("user_name") as? String
        
        if name.text?.isEmpty == true
        {
            name.text = "No name"
        }
        
        var iconImg = cell.viewWithTag(45) as! UIImageView!
        var contactType = self.contactList.objectAtIndex(indexPath.row).objectForKey("contact_type") as? String
        if contactType?.lowercaseString == "phonebook contact"
        {
            
            iconImg.image = UIImage(named: "phnbk")
            
            
        }
        else
        {
            iconImg.image = UIImage(named: "apusr")
        
        }
        
        
        cell.selectionStyle=UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer)
    {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        
        //let state = longPress.state
        
        let locationInView = longPress.locationInView(self.tableView)
        
        let indexPath = self.tableView.indexPathForRowAtPoint(locationInView)
        
        indexpath=indexPath
        
        let alert = UIAlertView()
        
        alert.title = "Ivy App"
        alert.message = "Do you want to remove this contact?"
        alert.addButtonWithTitle("Yes")
        alert.addButtonWithTitle("No")
        alert.delegate=self
        alert.show()

        
    }
    //MARK: UIAlertView Delegate
    //MARK:
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        switch buttonIndex {
        case 0:
            print("yes")
            
            self.deleteUser()
            
            break;
        case 1:
            
            print("no")
            
            break;
        default:
            break
            
        }
        
    }

   
    func deleteUser()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! String,"id_contact":(contactList.objectAtIndex(indexpath.row).objectForKey("id_contact") as! String!),"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(deleteUser_URL)"
            
            
            manager.POST("\(url)",
                parameters: param,
                success: {
                    (operation: AFHTTPRequestOperation!,responseObject: AnyObject!)in
                    print("SUCCESS")
                    
                    print(responseObject)
                    appdelegate.hideProgressHudInView(self.view)
                    
                    let status:AnyObject=responseObject.objectForKey("success")!
                    if(status as! NSObject == 0)
                    {
                        let msg:AnyObject=responseObject.objectForKey("message")!
                        
                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
                    }
                    else
                    {
                        let msg:AnyObject=responseObject.objectForKey("message")!
                        
                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
                       
                        self.contactList.removeObjectAtIndex(self.indexpath.row)
                        self.tableView.reloadData()
                    }
                    
                },
                failure: { (operation: AFHTTPRequestOperation!,
                    error: NSError!) in
                    print("ERROR")
                    appdelegate.hideProgressHudInView(self.view)
                    
                    let msg:AnyObject = "Failed due to an error"
                    appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
            })
        }
        else
        {
            let msg:AnyObject = "No internet connection available. Please check your internet connection."
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
        }
        
    }

   
    
    @IBAction func backBtnClicked(sender: UIButton) {
        
        navigationController?.popViewControllerAnimated(true)
        
        
    }
    
    @IBAction func addBtnClicked(sender: UIButton) {
        let addcontactsview=storyboard?.instantiateViewControllerWithIdentifier("AddContactsViewController") as! AddContactsViewController
        
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
    
    
    
    func myContacts()
    {
        
        
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! String,"search_key":"","page_number":"","mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(manageContact_URL)"
            
            
            manager.POST("\(url)",
                parameters: param,
                success: {
                    (operation: AFHTTPRequestOperation!,responseObject: AnyObject!)in
                    print("SUCCESS")
                    
                    print(responseObject)
                    appdelegate.hideProgressHudInView(self.view)
                    
                    let status:AnyObject=responseObject.objectForKey("success")!
                    if(status as! NSObject == 0)
                    {
                        //let msg:AnyObject=responseObject.objectForKey("message")!
                        
                        // appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
                    }
                    else
                    {
                        //let msg:AnyObject=responseObject.objectForKey("message")!
                        
                        //appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
                        // self.contactList.removeAllObjects()
                        self.contactList=responseObject["data"] as! NSMutableArray
                    }
                    self.tableView.reloadData()
                    if self.contactList.count <= 0
                    {
                        var noRecord = self.view.viewWithTag(777) as! UILabel!
                        noRecord.hidden = false
                    }
                    else
                    {
                        var noRecord = self.view.viewWithTag(777) as! UILabel!
                        noRecord.hidden = true
                        
                    }
                    

                    
                },
                failure: { (operation: AFHTTPRequestOperation!,
                    error: NSError!) in
                    print("ERROR")
                    appdelegate.hideProgressHudInView(self.view)
                    
                    let msg:AnyObject = "Failed due to an error"
                    appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
            })
        }
        else
        {
            let msg:AnyObject = "No internet connection available. Please check your internet connection."
            appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
        }
        
    }
    
    
    func contactEdited(edited:Bool)
    {
        self.edit = edited
    }

    
  //  @IBAction func longPress(sender:)
    
    
          /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
