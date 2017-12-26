//
//  AddContactsViewController.swift
//  IVY
//
//  Created by Singsys on 06/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

protocol edited
{
    func contactEdited(_ edited:Bool)
}

//extension UITableView {
//    func reloadData(_ completion: @escaping ()->()) {
//        UIView.animate(withDuration: 0, animations: { self.reloadData() }, completion: { _ in completion() })
//        
//    }
//}

class AddContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate {
    
     var window: UIWindow?
    var delegate: edited?
    var edit = false
    var temp:NSArray!
    var temp2: NSMutableArray = []
    var refreshControl:UIRefreshControl!
    var searching = false
    var tempArray:NSMutableArray! = []
    var page = 1
    var searchKey = ""
    var granted = false
    var listFromPhone : NSMutableArray = []
    @IBOutlet var search:UITextField!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var navTitle:UILabel!
    var dataArray : NSMutableArray = []
    var localArray : NSMutableArray = []
    var contactList : NSMutableArray = NSMutableArray()
    var newDictionary:NSMutableDictionary = ["":""]
    var localDictionary:NSMutableDictionary = ["":""]
    var idCntct:String!
    var viewType:String!
    var FieldIndex:IndexPath!
    var filtered:NSMutableArray! = []
    var alreadyAddedContact:NSMutableArray = NSMutableArray()
   
     var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var navigationController1:UINavigationController!
    
    @IBOutlet var addBtn:UIButton!
    
    override func viewDidLoad() {
        
       
        
      

        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if(viewType=="appUser")
        {
            navTitle.text = "Add App Users"
            
        }
        else if(viewType=="PhoneBook")
            
        {
            navTitle.text = "Add Contacts From Phonebook"
            
        }
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus
        {
        case .denied, .restricted:
            //1
            print("Denied")
        case .authorized:
            //2
            print("Authorized")
            
        case .notDetermined:
            //3
            print("Not Determined")
        }
        
        
        
        if(viewType=="appUser")
        {
            self.appUsers()
            addBtn.isHidden = true
            
        }
        else if(viewType=="PhoneBook")
            
        {    addBtn.isHidden = false
            
            if appdelegate.hasConnectivity()
            {
                
                dataArray.removeAllObjects()
                localArray.removeAllObjects()
                appdelegate.hideProgressHudInView(self.view)
                self.checkForInitial()
            }
            else
            {
                let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
                appdelegate.showMessageHudWithMessage(msg as! NSString, delay:2.0)
                addBtn.isUserInteractionEnabled = false                                                                                                                                                                                                                                                                                                                                                                                                                                           
            }
            
            
        }
        
        /******Add to pull to refersh***********/
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(AddContactsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        search.text = ""
        searching = false
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
        
        
        let noRecord = view.viewWithTag(777) as! UILabel!
        
        noRecord?.isHidden = true
        
//        if(viewType=="appUser")
//        {
//            self.appUsers()
//            addBtn.isHidden = true
//            
//        }
//        else if(viewType=="PhoneBook")
//            
//        {
//            addBtn.isHidden = false
//            if appdelegate.hasConnectivity()
//            {
//                dataArray.removeAllObjects()
//                localArray.removeAllObjects()
//                self.checkForInitial()
//            }
//            else
//            {
//                let msg:AnyObject = "No internet connection available. Please check your internet connection." as AnyObject
//                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 4.0)
//            }
//            
//            
//        }
        
        
    }
    
    
    
    //    override func didReceiveMemoryWarning() {
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }
    
    //MARK:- tableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searching == false
        {
            return contactList.count
        }
        else
        {
            return filtered.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String
        var cell:UITableViewCell!
        
        
        if viewType == "appUser"
        {
           cellIdentifier = "contactsCell"
        }
        else
        {
            cellIdentifier = "phoneContactsCell"
        }
        
        
        cell=tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        
        if(cell==nil)
        {
            cell=UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        let name = cell.viewWithTag(1) as! UILabel
        let profileImg = cell.viewWithTag(55) as! UIImageView
        
        if contactList.count>0
            
        {
            if(viewType=="appUser")
            {
                profileImg.layer.cornerRadius = profileImg.frame.size.width/2
                profileImg.clipsToBounds = true
                let photoUrl=((self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "user_image") as! String)
                
                profileImg.setImageWith(URL(string: photoUrl)!, placeholderImage: UIImage(named: "myPic"))
                
//                profileImg.setImageWith(URL(string: photoUrl)!)
             }
            else
            {
                var phone = ""
                
                if searching == false
                {
                     phone = ((self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as? String)!
                }
                else
                {
                    phone = ((self.filtered.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as? String)!
                }
                
                    
                
                    
                    let phoneCell = cell.viewWithTag(2) as! UILabel
                    
                    phoneCell.text = phone
                
                    let phn = phone.replacingOccurrences(of: "+", with: "")
                    
                    if localArray.count > 0
                    {
                        
                        for i in 0..<localArray.count
                        {
                            if (localArray.object(at: i) as AnyObject).object(forKey: "phone_number") as? String == phn && (localArray.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "thumbImage") != nil
                            {
                                profileImg.layer.cornerRadius = profileImg.frame.size.width/2
                                profileImg.clipsToBounds = true
                                
                                let img = (localArray.object(at: i) as AnyObject).object(forKey: "thumbImage") as! UIImage
                                
                                profileImg.image = img
                            }
                            else
                            {
                                profileImg.image = UIImage(named: "myPic")
                            }
                        }
                    }
                    
                    
                    if self.alreadyAddedContact.count > 0
                    {
                        if let tempArray = (self.alreadyAddedContact.object(at: 0) as AnyObject) as? NSMutableArray
                        {
                            var phone = ""
                            
                            if searching == false
                            {
                                phone = ((self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as? String)!
                            }
                            else
                            {
                                phone = ((self.filtered.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as? String)!
                            }
                            
                            let phn = phone.replacingOccurrences(of: "+", with: "")
                            
//                            let phn = (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as! String
                            
                            for i in 0..<tempArray.count
                            {
                                let TempDic =  tempArray.object(at: i) as! NSDictionary
                                let phoneNumber = TempDic.object(forKey: "phone_number") as! String
                                let already_phone = phoneNumber.replacingOccurrences(of: "+", with: "")
                                
                                
                                if already_phone == phn
                                {
                                    
                                    let tempData = self.contactList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
                                    
                                    let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                    
                                    
                                    dataToEdit.setObject("\(TempDic.object(forKey: "id_contact") as! String)", forKey: "id_contact" as NSCopying)
                                    
                                    
                                    
                                    dataToEdit.setObject("yes", forKey: "is_already_added" as NSCopying)
                                    
                                    self.contactList.replaceObject(at: (indexPath as NSIndexPath).row, with: dataToEdit)
                                    
                                    break;
                                    
                                }
                                else
                                {
                                    let tempData = self.contactList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
                                    
                                    let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                    
                                    
                                    dataToEdit.setObject("\(TempDic.object(forKey: "id_contact") as! String)", forKey: "id_contact" as NSCopying)
                                    
                                    dataToEdit.setObject("no", forKey: "is_already_added" as NSCopying)
                                    
                                    self.contactList.replaceObject(at: (indexPath as NSIndexPath).row, with: dataToEdit)
                                }
                                
                                
                            }
                        }
                    }
                
                
                
                
                
            }
            
            if searching == false
            {
                name.text=(self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "user_name") as? String
                
                if name.text?.isEmpty == true
                {
                    name.text = "No name"
                }
            }
            else
            {
                name.text=(self.filtered.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "user_name") as? String
            }
            
            let addBtn = cell.viewWithTag(45) as! UIButton!
            
            var is_already_added:String!
            
            if searching == false
            {
                
                is_already_added = (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "is_already_added") as? String
            }
            else
            {
                is_already_added = (self.filtered.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "is_already_added") as? String
                
            }
            
            if is_already_added?.lowercased() == "yes"
            {
                addBtn?.setImage(UIImage(named: "added"), for: UIControlState())
                
            }
            else
            {
                addBtn?.setImage(UIImage(named: "toadd"), for: UIControlState())
            }
            if(viewType=="appUser")
            {
                if (indexPath as NSIndexPath).row == contactList.count - 1
                {
                    self.loadMore(indexPath)
                }
            }
            
            if searching == true
            {
                if (indexPath as NSIndexPath).row == filtered.count - 1
                {
                    searching = false
                }
            }
            
            cell.selectionStyle=UITableViewCellSelectionStyle.none
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(viewType=="PhoneBook")
            
        {
            var flag = 0
            if search.text?.isEmpty == true || filtered.count == 0
            {
                //for var record:ABRecord in stride(from: 0, to: temp, by: 1)
                  //  str
                    
                //for record:ABRecord in 0..<(temp.count)
//            var record:ABRecord
                        //for (record = 0,)
            
            //for record in temp[0..<temp.count]
               // for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(phones); numberIndex++)
                
                 for ( _ , record) in temp.enumerated()
 
                {
//                    let record = temp[indexPath.row]
            
                    let phones : ABMultiValue! = ABRecordCopyValue(record as ABRecord!,kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValue!
                    
                    for numberIndex in 0 ..< ABMultiValueGetCount(phones)
                    {
                        
                        let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
                        
                        let phoneNumber : NSString = phoneUnmaganed!.takeUnretainedValue() as! NSString
                        let charactersToRemove = CharacterSet.alphanumerics.inverted
                        
                        
                        
                        let strippedReplacement = ((phoneNumber as String).components(separatedBy: charactersToRemove)).joined(separator: "")
                        
                        if (self.contactList.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "phone_number") as? String == strippedReplacement
                        {
                             var personViewController = ABPersonViewController()
                            
                             personViewController.displayedPerson = record as ABRecord
                            
                             personViewController.personViewDelegate = self
//                            self.personViewController.navigationItem.backBarButtonItem
                            
                            
                             personViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.personviewBackButtonPressed))
                            
                        self.navigationController?.pushViewController(personViewController, animated: true)
                            
                            flag = 1
                            
                            break
                            
                        }
                        
                        if flag == 1
                        {
                            break
                        }
                        
                    }
                    
//                       personViewController.displayedPerson = temp[indexPath.row]
                }
            }
            else
            {
                 for ( _ , record) in temp.enumerated()
                {
                    let phones : ABMultiValue = ABRecordCopyValue(record as ABRecord!,kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValue
                    
                    for numberIndex in 0 ..< ABMultiValueGetCount(phones)
                    {
                        
                        let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
                        
                        let phoneNumber : NSString = phoneUnmaganed!.takeUnretainedValue() as! NSString
                        let charactersToRemove = NSCharacterSet.alphanumerics.inverted
                        
                        
                        
                        let strippedReplacement = ((phoneNumber as String).components(separatedBy: charactersToRemove)).joined(separator: "")
                        
                        if (self.filtered.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey:"phone_number") as? String == strippedReplacement
                        {
                            let personViewController = ABPersonViewController()
                            
                            personViewController.displayedPerson = record as ABRecord
                            
                            personViewController.personViewDelegate = self
                            //                            self.personViewController.navigationItem.backBarButtonItem
                            
                            
                            personViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.personviewBackButtonPressed))
                            
                            self.navigationController?.pushViewController(personViewController, animated: true)
//                            self.navigationController?.present(personViewController, animated: true
//                                , completion: nil)
                            
                            flag = 1
                            
                            break
                            
                        }
                        
                        if flag == 1
                        {
                            break
                        }

                        
                    }
                }
            }
        }
        
    }
    
    func personviewBackButtonPressed()
    {
//        self.navigationController?.popoverPresentationController
        
        
        self.navigationController?.popViewController(animated: true)
        
        if filtered != nil
        {
            filtered.removeAllObjects()
        }
        tableView.reloadData()
    }
    
    
    
    //MARK:- @IBAction func
    @IBAction func searchBtnClicked(_ sender:UIButton)
    {
        self.view.endEditing(true)
        
        
        
        if search.text! != ""
        {
            if(viewType=="appUser")
            {
                tempArray.addObjects(from: contactList as [AnyObject])
                
                contactList.removeAllObjects()
                tableView.reloadData()
                page = 1
                searchKey=search.text!
                
                self.appUsers()
            }
            else
            {
                searching = true
                
                let resultPredicate = NSPredicate(format: "user_name CONTAINS[c] %@",search.text!)
                
                if filtered != nil
                {
                    filtered.removeAllObjects()
                }
                
                let filter = self.contactList.filtered(using: resultPredicate)
                
                filtered.addObjects(from: filter)
                //contactList.removeAllObjects()
                // contactList.addObjectsFromArray(filtered)
                
                tableView.reloadData()
                
                if filtered.count<=0
                {
                    let noRecord = self.view.viewWithTag(777) as! UILabel!
                    noRecord?.isHidden = false
                }
                
                // searching = false
            }

        }
        
}
    
    @IBAction func addContact(_ sender:UIButton)
    {
        let newPerson:ABNewPersonViewController! = ABNewPersonViewController()
        newPerson.newPersonViewDelegate = self
        self.navigationController?.pushViewController(newPerson, animated: true)
    }
    
    @IBAction func switchClicked(_ sender:UIButton)
    {
        
        
        let hitPoint: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        FieldIndex = self.tableView.indexPathForRow(at: hitPoint)
        
        let cellToUpdate = self.tableView.cellForRow(at: FieldIndex!)
        
        let addBtn = cellToUpdate?.viewWithTag(45) as! UIButton
        
        let tempDic:NSDictionary!
        
        if filtered.count > 0
        {
              tempDic = self.filtered.object(at: (FieldIndex! as NSIndexPath).row) as! NSDictionary
        }
        else{
            
              tempDic = self.contactList.object(at: (FieldIndex! as NSIndexPath).row) as! NSDictionary
        }
        
       
        let userName:String!
        
        if (tempDic.object(forKey: "id_contact") as? String) != nil
        {
            let tempNum2 = tempDic.object(forKey: "id_contact") as! String

            idCntct = "\(tempNum2)"
        }
        else
        {
//            idCntct = tempDic.object(forKey: "id_contact") as! String
            idCntct = ""
        }
        
        if  tempDic.object(forKey: "user_name") != nil
        {
            userName = tempDic.object(forKey: "user_name") as! String
        }
        else
        {
            userName = "No Name"
        }
        
        var is_already_added = ""
        
        if let isalreadyadded = tempDic.object(forKey: "is_already_added") as? String
        {
            is_already_added = isalreadyadded
        }
        else
        {
            is_already_added = "no"
        }
        
        let phone_num = tempDic.object(forKey: "phone_number") as! String
        
//        if phone_num.hasPrefix("+91") { // true
//            print("Prefix exists")
//        }
//        else if phone_num.hasPrefix("0") && phone_num.characters.count == 11
//        {
//            var str = "\(phone_num)"
//            let strnigToReplace = "+91"
//            let stringToReplaceTO = "0"
//            
//            if let range = str.range(of: strnigToReplace) {
//                
////                str = str.stringByReplacingOccurrencesOfString(strnigToReplace, withString: stringToReplaceTO, options: NSString.CompareOptions.LiteralSearch, range: range)
//                
//                str = str.replacingOccurrences(of: strnigToReplace, with: stringToReplaceTO, options: .literal, range: range)
//                print(str)
//                phone_num = str
//            }
//        }else
//        {
//            phone_num = "+91\(phone_num)"
//            print(phone_num)
//        }
            
        
        if(viewType=="PhoneBook")
            
        {
            if is_already_added.lowercased() == "no"
            {
                if appdelegate.hasConnectivity()
                {
                    appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
                    
                   let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
                    let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
                    manager.responseSerializer = serializer
                    let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"id_contact":idCntct,"mode":"","action":"add","phone_number":phone_num,"user_name":userName] as NSDictionary
                    print(param)
                    let url="\(base_URL)\(addUser_URL)"
                    
                    
                    manager.post("\(url)",
                                 parameters: param,
                                 success: {
                                    (operation,responseObject)in
                                    
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
                                        let msg = result.object(forKey: "message")! as! String
                                        
                                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                        
                                        addBtn.setImage(UIImage(named: "added"), for: UIControlState())
                                        
                                        
                                        let tempData2 = result.object(forKey: "data")! as! NSDictionary
                                        
                                        
                                        
                                        if self.filtered.count > 0
                                        {
                                            let tempData = self.filtered.object(at: (self.FieldIndex! as NSIndexPath).row) as! NSDictionary
                                            
                                            let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                            
                                            
                                            dataToEdit.setObject("\(tempData2.object(forKey: "id_contact") as! Int)", forKey: "id_contact" as NSCopying)
                                            
                                            dataToEdit.setObject("yes", forKey: "is_already_added" as NSCopying)
                                            
                                            self.filtered.replaceObject(at: (self.FieldIndex as NSIndexPath).row, with: dataToEdit)
                                           
                                            
                                        }
                                        else
                                        {
                                            let tempData = self.contactList.object(at: (self.FieldIndex! as NSIndexPath).row) as! NSDictionary
                                            
                                            let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                            
                                            
                                            dataToEdit.setObject("\(tempData2.object(forKey: "id_contact") as! Int)", forKey: "id_contact" as NSCopying)
                                            
                                            dataToEdit.setObject("yes", forKey: "is_already_added" as NSCopying)
                                            
                                            self.contactList.replaceObject(at: (self.FieldIndex as NSIndexPath).row, with: dataToEdit)
                                        }
                                        
                                        let dict = NSMutableDictionary()
                                        
                                        dict.setObject("Phonebook Contact", forKey: "contact_type" as NSCopying)
                                        
                                        dict.setObject("\(tempData2.object(forKey: "email") as! String)", forKey: "email" as NSCopying)
                                        
                                        dict.setObject("\(tempData2.object(forKey: "id_contact") as! Int)", forKey: "id_contact" as NSCopying)
                                        dict.setObject("yes", forKey: "is_already_added" as NSCopying)
                                        dict.setObject("\(tempData2.object(forKey: "phone_number") as! String)", forKey: "phone_number" as NSCopying)
                                        dict.setObject("\(tempData2.object(forKey: "user_id") as! String)", forKey: "user_id" as NSCopying)
                                        dict.setObject("\(tempData2.object(forKey: "user_name") as! String)", forKey: "user_name" as NSCopying)
                                        
                                        let tempalreadyArray = (self.alreadyAddedContact.object(at: 0) as AnyObject) as! NSMutableArray
                                        
                                        tempalreadyArray.add(dict)
                                        
                                        self.alreadyAddedContact.replaceObject(at: 0, with: tempalreadyArray)
//                                        self.alreadyAddedContact.add(dict)
                                        
                                       
//                                        self.updatePlist(FieldIndex: self.FieldIndex!)
                                        
                                        self.edit = true
                                    }
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
            else
            {
                let alert = UIAlertView()
                
                alert.title = "Ivy App"
                alert.message = "Do you want to remove this contact?"
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                alert.delegate=self
                alert.show()
            }
        }
        else
        {
            if is_already_added.lowercased() == "no"
            {
                if appdelegate.hasConnectivity()
                {
                    appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
                    
                   let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
                    let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
                    manager.responseSerializer = serializer
                    let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"id_contact":idCntct,"mode":""] as NSDictionary
                    print(param)
                    let url="\(base_URL)\(addAppUser_URL)"
                    
                    
                    manager.post("\(url)",
                                 parameters: param,
                                 success: {
                                    (operation,responseObject)in
                                 
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
                                        let msg = result.object(forKey: "message")! as! String
                                        
                                        appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                        
                                        addBtn.setImage(UIImage(named: "added"), for: UIControlState.normal)
                                        
                                        let tempData2 = result.object(forKey: "data")! as! NSDictionary
                                        
                                        let tempData = self.contactList.object(at: (self.FieldIndex! as NSIndexPath).row) as! NSDictionary
                                        
                                        let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                        
                                       
                                        dataToEdit.setObject("yes", forKey: "is_already_added" as NSCopying)
                                        
                                        self.contactList.replaceObject(at: (self.FieldIndex as NSIndexPath).row, with: dataToEdit)
                                        
                                        
                                        
//                                        self.contactList.removeAllObjects()
//                                       
//                                        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AddContactsViewController.appUsers), userInfo: nil, repeats: false)
                                        
                                        self.edit = true
                                        
                                        
                                    }
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
            else
            {
                let alert = UIAlertView()
                
                alert.title = "Ivy App"
                alert.message = "Do you want to remove this contact?"
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                alert.delegate=self
                alert.show()
            }
            
        }
        
        
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        delegate?.contactEdited(edit)
        navigationController?.popViewController(animated: true)
        
        
    }


    
    //    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //        if textField.text?.isEmpty == true
    //        {
    //            searching = false
    //            tableView.reloadData()
    //
    //        }
    //        return true
    //    }
    
    //    func textFieldDidEndEditing(textField: UITextField) {
    //        if textField.text?.isEmpty == true
    //                {
    //                    searching = false
    //                    tableView.reloadData()
    //
    //                }
    //    }
    
    
    //MARK:- UITextField Delegate
    //MARK:
    
    
    
    func textFieldShouldReturn(_ name: UITextField) -> Bool {
        name.resignFirstResponder()
     if name.text == ""
      {
        searchKey = ""
        
      }
        return true;
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        searchKey = ""
        self.view.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.utf16.count == 0 && textField.text?.utf16.count == 1
        {
            if(viewType=="appUser")
            {
                contactList.removeAllObjects()
                contactList.addObjects(from: tempArray as [AnyObject])
                let noRecord = self.view.viewWithTag(777) as! UILabel!
                noRecord?.isHidden = true
                tableView.reloadData()
            }
            else
            {
                searching = false
                let noRecord = self.view.viewWithTag(777) as! UILabel!
                noRecord?.isHidden = true
                self.filtered.removeAllObjects()
                tableView.reloadData()
            }
            
        }
        return true
    }
    
    //MARK:- UIAlertView Delegate
    //MARK:
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        switch buttonIndex {
        case 0:
            print("yes")
            if(viewType=="PhoneBook")
            {
                
                self.deleteUser()
            }
            else
            {
                self.deleteAppUser()
            }
            break;
        case 1:
            
            print("no")
            
            break;
        default:
            break
            
        }
        
    }
       
    func updatePlist(FieldIndex:IndexPath)
    {
        
        let tempData = self.contactList.object(at: (FieldIndex as NSIndexPath).row) as! NSDictionary
        
        let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
        
        if (dataToEdit.object(forKey: "is_already_added") as! String).lowercased() == "no"
        {
            dataToEdit.setObject("yes", forKey: "is_already_added" as NSCopying)
        }
        else
        {
            dataToEdit.setObject("no", forKey: "is_already_added" as NSCopying)
        }
        self.contactList.replaceObject(at: (FieldIndex as NSIndexPath).row, with: dataToEdit)
        tableView.reloadData()
        
        saveContacToPlist(contactList)
        
    }
    
    
    
    // MARK: - check for initially plist data
    
    //  Function to check for plist data initially
    
    func checkForInitial()
    {
        let fileManager = (FileManager.default)
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true) as? [String]
        
        //  println("value of directorys is \(directorys)")
        
        if (directorys != nil)
        {
            let directories:[String] = directorys!;
            let pathToFile = directories[0]; //documents directory
            
            let plistfile = "Contact.plist"
            _ = String(describing: URL(fileURLWithPath: pathToFile).appendingPathComponent(plistfile))
            //let plistpath = pathToFile.stringByAppendingPathComponent(plistfile);
            let paths2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let path2 = paths2 + "/Contact.plist"
            
            
            if fileManager.fileExists(atPath: path2)
            {  print("\n\nPlist file found at \(path2)")
                
                var myDict:NSMutableDictionary!
                
                myDict = NSMutableDictionary(contentsOfFile: path2)!
                
              
                let temp = myDict.object(forKey: "root") as! NSArray
                
                let myContactArray = temp.mutableCopy() as! NSMutableArray
                
                //var myArray:NSMutableArray = [0]
                
                //myArray = NSMutableArray(contentsOfFile: plistpath)!
                
//                self.contactList.add(myContactArray!)
                
                for record in 0..<myContactArray.count
                {
                    print(record)
                    let temp = myContactArray.object(at: record) as! NSMutableDictionary
                   self.contactList.add(temp)
                  
                }
                
                let ageDescriptor: NSSortDescriptor = NSSortDescriptor(key: "user_name", ascending: true)
                
                let sortDescriptors = [ageDescriptor]
                
                let sortedArray = self.contactList.sortedArray(using: sortDescriptors)
                
                self.contactList.removeAllObjects()
                
                self.contactList.addObjects(from: sortedArray as Array)
                
                
//                self.temp2.addObjects(from: [myContactArray])
//                self.temp = temp
//                self.temp2.addingObjects(from: [myContactArray])

                
//                self.contactList.addObjects(from: myContactArray as! [Any])
                
//                self.contactList.addingObjects(from: myContactArray as! [Any])
                
                
//                self.contactList.addObjects(from: (myContactArray! ) as! [Any])
                
                self.tableView.reloadData()
                
                 _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(AddContactsViewController.refreshTable), userInfo: nil, repeats: false)
                
                // open it
                
                var error: Unmanaged<CFError>?
                
                let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
                
                if addressBook == nil {
                    print(error?.takeRetainedValue())
                    return
                }
                
               
                self.getAllContacts(myContactArray,addressBook: addressBook!)
                
//                        
//                }
             
            }
            else
            {
                
//                appdelegate.hideProgressHudInView(self.view)
                
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
                let myArray = NSMutableArray()
                
                self.getAllContacts(myArray,addressBook: addressBook)
            }
        }
    }
    
 
    
    // MARK: - getAllContacts
    
    
    //  Function to get All the contacts from Phone
    
    func getAllContacts(_ contactArry:NSMutableArray,addressBook:ABAddressBook)
    {
        // make sure user hadn't previously denied access
        
        
//        activityIndicator.startAnimating()
        // request permission to use it
        
//        ABAddressBookRequestAccessWithCompletion(addressBook)
//        {
//            granted, error in
//            
//            
//            if !granted
//            {
//                // warn the user that because they just denied permission, this functionality won't work
//                // also let them know that they have to fix this in settings
////                appdelegate.hideProgressHudInView(self)
//                
//                
//                return
//            }
//            
//            self.granted = true
//            
//
//        
//        }
        
        
//        
//        if self.granted == true
//        {
        self.dataArray.removeAllObjects()
        
            self.fetchContactFromPhone(contactArry, addressBook: addressBook)
            
//            granted = false
//        }
        
       
        
        
//    }
//
//        appdelegate.hideProgressHudInView(self)
       
    
    }
    
    func fetchContactFromPhone(_ contactArry:NSMutableArray,addressBook:ABAddressBook)
    {
        
        appdelegate.hideProgressHudInView(self)
        appdelegate.showProgressHudForViewMy(self, withDetailsLabel: "Please Wait..", labelText: "Requesting")
        
        let people = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray as [ABRecord]
        
        
        print(people)
        
        
        self.temp = people as NSArray!
        
        if people.count>0
        {
            for record in people {
                
                self.newDictionary.removeAllObjects()
                
                self.localDictionary.removeAllObjects()
                
                let contactPerson: ABRecord = record
                
                let phones = ABRecordCopyValue(record,kABPersonPhoneProperty).takeUnretainedValue()
                
                let emailProperty = ABRecordCopyValue(record, kABPersonEmailProperty).takeUnretainedValue()
                
                
                if(ABMultiValueGetCount(phones) == 0)
                {
                    
                    continue
                }
                
                var value: String
                
                if (emailProperty is NSNull)
                {
                    
                    value = ""
                    //println("Name   " )
                }
                let emailsRef: ABMultiValue = ABRecordCopyValue(contactPerson, kABPersonEmailProperty).takeRetainedValue() as ABMultiValue
                
                _ = Array<Dictionary<String, String>>()
                
                if ABMultiValueGetCount(emailProperty) > 0
                {
                    for i:Int in 0 ..< ABMultiValueGetCount(emailProperty) {
                        
                        //var label: String = ((ABMultiValueCopyLabelAtIndex(emailsRef, i).takeRetainedValue() as NSString) as? String)!
                        
                        value = ABMultiValueCopyValueAtIndex(emailProperty, i).takeRetainedValue() as! NSString as String
                        
                        self.newDictionary.setObject(value, forKey: "email" as NSCopying)
                        
                        self.localDictionary.setObject(value, forKey: "email" as NSCopying)
                    }
                }
                else
                {
                    self.newDictionary.setObject("", forKey: "email" as NSCopying)
                    self.localDictionary.setObject("", forKey: "email" as NSCopying)
                }
                
                
                if(ABPersonHasImageData(record))
                {
                    
                    //                        let imageDataRef =  ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatOriginalSize) as! CFData!
                    
                    let data = ABPersonCopyImageData(record).takeRetainedValue() as Data
                    
                    let thumbImage = UIImage(data: data)
                    
                    self.localDictionary.setObject(thumbImage!, forKey: "thumbImage" as NSCopying)
                }
                else
                {
                    self.localDictionary.setObject(UIImage(named: "myPic")!, forKey: "thumbImage" as NSCopying)
                }
                
                
                if(ABRecordCopyCompositeName(contactPerson) == nil) {
                    continue
                }
                
                var names : ABMultiValue!
                
                names = ABRecordCopyCompositeName(record).takeRetainedValue() as ABMultiValue
                
                if (names is NSNull)
                {
                    
                    names="" as ABMultiValue!
                    //println("Name   " )
                }
                else
                {
                    print("Name :-\(names as! String)   " )
                }
                
                self.newDictionary["user_name"] = names as! String
                
                self.localDictionary["user_name"] = names as! String
                
                var tempMobile:String!
                
                
                
                for numberIndex : CFIndex in 0..<ABMultiValueGetCount(phones)
                {
                    
                    let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
                    
                    let phoneNumber : NSString = phoneUnmaganed!.takeUnretainedValue() as! NSString
                    
                    let locLabel : CFString = (ABMultiValueCopyLabelAtIndex(phones, numberIndex) != nil) ? ABMultiValueCopyLabelAtIndex(phones, numberIndex).takeUnretainedValue() as CFString : "" as CFString
                    
                    let cfStr:CFTypeRef = locLabel
                    let nsTypeString = cfStr as! NSString
                    //                        var swiftString:String = nsTypeString as String
                    
                    //                        let customLabel = String (stringInterpolationSegment: ABAddressBookCopyLocalizedLabel(locLabel))
                    
                    
                    // println("Name :-\(swiftString) NO :-\(phoneNumber)" )
                    
                    
                    let charactersToRemove = CharacterSet.alphanumerics.inverted
                    
                    
                    
                    let strippedReplacement = ((phoneNumber as String).components(separatedBy: charactersToRemove)).joined(separator: "")
                    
                    
                    self.newDictionary.setObject(strippedReplacement as String, forKey: "phone_number" as NSCopying)
                    
                    self.localDictionary.setObject(strippedReplacement as String, forKey: "phone_number" as NSCopying)
                    
                    tempMobile=phoneNumber as String
                    
                }
                
                
                
                var userMobile:String! = ""
                
                
                //                    userMobile = (UserDefaults.standard.object(forKey: "ProfileData") as AnyObject).object("mobile") as! String
                //
                //
                //
                ////
                //                    if((self.newDictionary.object(forKey: "mobile") as! String).contains(userMobile))
                //
                //                    {
                //                        continue
                //                    }
                
                
                if(((self.newDictionary.object(forKey: "phone_number") as! String).characters.count)<8)
                {
                    continue
                }
                
                if(((self.localDictionary.object(forKey: "phone_number") as! String).characters.count)<8)
                {
                    continue
                }
                
                
                NSLog("nslog %@",self.newDictionary.object(forKey: "phone_number") as! String)
                
                
                
                let resultPredicate = NSPredicate(format: "phone_number CONTAINS %@ OR %@ CONTAINS phone_number ",(self.newDictionary.object(forKey: "phone_number") as! String),
                                                  (self.newDictionary.object(forKey: "phone_number") as! String))
                
                let filteredarray: Array = self.dataArray.filtered(using: resultPredicate)
                
                NSLog("filteredarray : %@", filteredarray)
                
//                if(filteredarray.count>0)
//                {
//                    continue
//                }
                
                
                //  self.newDictionary.setObject("", forKey: "country_code")
                
                self.newDictionary.setObject(UserDefaults.standard.object(forKey: "user_id") as! String, forKey: "user_id" as NSCopying)
                
                self.localDictionary.setObject(UserDefaults.standard.object(forKey: "user_id") as! String, forKey: "user_id" as NSCopying)
                
                self.dataArray.add(self.newDictionary.mutableCopy())
                self.localArray.add(self.localDictionary.mutableCopy())

            }
            if(self.dataArray.count>0)
            {
                
                //                        if(self.listFromPhone != contactArry)
                //                        {
                
                var error1 : NSError?
                do
                {
                    let jsonData = try JSONSerialization.data(withJSONObject: self.dataArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                    
                    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    if appdelegate.hasConnectivity()
                    {
                        //
                        self.saveContacToPlist(self.dataArray.mutableCopy() as! NSMutableArray)
                        
                        //                           appdelegate.hideProgressHudInView(self.view)
                        
                    }
                    else
                    {
                        //                            appdelegate.hideProgressHudInView(self.view)
                        
                        let msg:AnyObject = "Please check your internet connection" as AnyObject
                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                    }
                    
                    
                }
                    
                catch
                {
                    
                }
                
                
                
                if(self.listFromPhone.count==contactArry.count)
                {
                    
                }
                
                
                
                
            }else{
                appdelegate.hideProgressHudInView(self.view)
                return
            }
        }
    }
    
    
    
    
    // MARK: - sendJSOn
    
    
    //  Function to send contact Json to server
    
    func sendJson(_ str:String)
    {
        
        
       let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
        
        let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
        
        manager.requestSerializer.timeoutInterval = 1000
        
        manager.responseSerializer = serializer
        
        let str1=str.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil) as String
        
        //println(str1)
        
        let param=["json_data":"\(str1)","mode":""]
            as NSDictionary
        
        print(param)
        
        let url="\(base_URL)\(addPhonebook_URL)"
        
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
                        
                         self.refreshControl.endRefreshing()
                        
                                       if(status == 1)
                                        {
                        
                        self.contactList.removeAllObjects()
                        
                        self.contactList.addObjects(from: (result.object(forKey: "data") as! NSArray).mutableCopy() as! [AnyObject])
                        
                        self.contactList=(result.object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray
                        
                        let ageDescriptor: NSSortDescriptor = NSSortDescriptor(key: "user_name", ascending: true)
                                            
                        let sortDescriptors = [ageDescriptor]
                                            
                        let sortedArray = self.contactList.sortedArray(using: sortDescriptors)
                        
                        self.contactList.removeAllObjects()
                        
                        self.contactList.addObjects(from: sortedArray as Array)
                        
                        let temp = result.object(forKey: "data") as! NSArray
                        
                        self.saveContacToPlist(temp.mutableCopy() as! NSMutableArray)
                        
                        self.tableView.reloadData()
                        
                        }
                        }
            },
                     failure: { (operation: URLSessionTask?,
                        error: Error) in
                        print("\(error)")
                        appdelegate.hideProgressHudInView(self.view)
                        
                        //  self.refreshControl.endRefreshing()
                        
                        
                        let msg:Any = "Failed due to an error" as AnyObject
                        appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
        })

    }
    
    // MARK: - fetch and save from/to plist
    
    //  Function to fetch contacts from plist
    
    func fetchContactFromPlist(_ contactArray:NSMutableArray) -> Bool
    {
        let fileManager = (FileManager.default)
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true) as? [String]
        
        //println("value of directorys is \(directorys)")
        
        if (directorys != nil)
        {
            let directories:[String] = directorys!;
            let pathToFile = directories[0]; //documents directory
            
            let plistfile = "PeopleArray.plist"
            
            let plistpath = String(describing: URL(fileURLWithPath: pathToFile).appendingPathComponent(plistfile))
            
            if fileManager.fileExists(atPath: plistpath)
            {  print("\n\nPlist file found at \(plistpath)")
                
                /*if let tempArr: [ContactsStore] = NSKeyedUnarchiver.unarchiveObjectWithFile(plistfile) as? [ContactsStore]
                 {
                 let answer = map(zip(self.dataArray,tempArr)){$0.0 === $0.1}
                 
                 
                 println("list of right indexces \(answer)")
                 
                 let answer2 = filter(enumerate(zip(self.dataArray,tempArr)))
                 {
                 $1.0 === $1.1
                 }.map{$0.0}
                 
                 println("list of right indexces \(answer2)")
                 
                 }*/
                
                
                var myArray:NSMutableArray = [0]
                
                myArray = NSMutableArray(contentsOfFile: plistpath)!
                
                
                // println(myArray)
                
                
                if !contactArray.isEqual(to: myArray as Array)
                {
                    self.saveContacToPlist(self.listFromPhone)
                }
                
            }
            else
            {
                self.saveContacToPlist(self.listFromPhone)
                
            }
        }
        
        return true
    }
    
    
    
    //  Function to save contacts to plist
    
    func saveContacToPlist(_ contactArray:NSMutableArray)
    {
        let fileManager = (FileManager.default)
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true) as? [String]
        
        print("value of directorys is \(directorys!)")
        
        if (directorys != nil)
        {
            let directories:[String] = directorys!;
            let pathToFile = directories[0]; //documents directory
            
            let plistfile = "/Contact.plist"
            
            let plistpath = pathToFile + plistfile
            
            do
            {
                try fileManager.removeItem(atPath: plistpath)
            }
            catch
            {
                
            }
            
            if !fileManager.fileExists(atPath: plistpath)
            {  //writing Plist file
                
                //self.createInitialPeople()
                
                // println("Declaring cocoaArray")
                
                if let bundlePath = Bundle.main.path(forResource: "Contact", ofType: "plist") {
                    
                    let fileManager = FileManager.default
                    
                    do
                    {
                        try fileManager.copyItem(atPath: bundlePath, toPath: plistpath)
                    }
                    catch{
                        
                    }
                }
                
                let paths2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let path2 = paths2 + "/Contact.plist"
                
                _ = contactArray as NSArray
                
                let dict: NSMutableDictionary! = [:]
                //saving values
                dict.setObject(contactArray, forKey: "root" as NSCopying)
                
                dict.write(toFile: path2, atomically: true)
                
            }
                
                
            else
            {
                
            }
        }
       
        self.reloadContactAfterFetch()
//        appdelegate.hideProgressHudInView(self.view)
    }
    
    
    // MARK: - check for initially plist data
    
    //  Function to check for plist data initially
    
    func reloadContactAfterFetch()
    {
//        appdelegate.hideProgressHudInView(self)
        let fileManager = (FileManager.default)
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true) as? [String]
        
        //  println("value of directorys is \(directorys)")
        
        if (directorys != nil)
        {
            let directories:[String] = directorys!;
            let pathToFile = directories[0]; //documents directory
            
            let plistfile = "Contact.plist"
            _ = String(describing: URL(fileURLWithPath: pathToFile).appendingPathComponent(plistfile))
            //let plistpath = pathToFile.stringByAppendingPathComponent(plistfile);
            let paths2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let path2 = paths2 + "/Contact.plist"
            
            
            if fileManager.fileExists(atPath: path2)
            {  print("\n\nPlist file found at \(path2)")
                
                var myDict:NSMutableDictionary!
                
                myDict = NSMutableDictionary(contentsOfFile: path2)!
                
                
                let temp = myDict.object(forKey: "root") as! NSArray
                
                let myContactArray = temp.mutableCopy() as! NSMutableArray
                
                //var myArray:NSMutableArray = [0]
                
                //myArray = NSMutableArray(contentsOfFile: plistpath)!
                
                //                self.contactList.add(myContactArray!)
                
                self.contactList.removeAllObjects()
                
                for record in 0..<myContactArray.count
                {
                    print(record)
                    let temp = myContactArray.object(at: record) as! NSMutableDictionary
                    self.contactList.add(temp)
                    
                }
                
                let ageDescriptor: NSSortDescriptor = NSSortDescriptor(key: "user_name", ascending: true)
                
                let sortDescriptors = [ageDescriptor]
                
                let sortedArray = self.contactList.sortedArray(using: sortDescriptors)
                
                self.contactList.removeAllObjects()
                
                self.contactList.addObjects(from: sortedArray as Array)
                
                self.tableView.reloadData()
                
                 _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(AddContactsViewController.refreshTable), userInfo: nil, repeats: false)
     
//                activityIndicator.s()
                appdelegate.hideProgressHudInView(self.view)
                
            }
            else
            {
//                appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
                
                let status = ABAddressBookGetAuthorizationStatus()
                
                let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                
                if status == .denied || status == .restricted
                {
                    // user previously denied, to tell them to fix that in settings
                    return
                }
                
                // open it
                
                var error: Unmanaged<CFError>?
                //                let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                
                
                
                if addressBook == nil {
                    print(error?.takeRetainedValue())
                    return
                }
                
                
                let myArray = NSMutableArray()
                
                self.getAllContacts(myArray,addressBook: addressBook)
            }
        }
    }
    
    
    //MARK:- webservices
    
    func appUsers()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"search_key":searchKey,"page_number":page,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(viewAppUser_URL)"
            
            
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
                                
//                                appdelegate.hideProgressHudInView(self)
                                
//                                 appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
//                                self.tableView.reloadData()
                                
                            }
                            else
                            {
                                let tempArray = result.object(forKey: "data") as! NSArray
                                
                                if tempArray.count>0
                                {
                                    self.contactList.addObjects(from: (result.object(forKey: "data") as! NSArray).mutableCopy() as! [AnyObject])
                                    
                                    if self.page == 1
                                    {
                                        self.tableView.setContentOffset(CGPoint.zero, animated:true)
                                    }
                                    self.tableView.reloadData()
                                    
                                    _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(AddContactsViewController.refreshTable), userInfo: nil, repeats: false)
                                    if self.page == 1
                                    {
//                                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
                                        
                                    }
                                }
                                
                                
                            }
                            if self.page == 1 && self.contactList.count<=0
                            {
                                let noRecord = self.view.viewWithTag(777) as! UILabel!
                                noRecord?.isHidden = false
                            }
                            else
                            {
                                let noRecord = self.view.viewWithTag(777) as! UILabel!
                                noRecord?.isHidden = true
                            }
                            }
                            appdelegate.hideProgressHudInView(self.view)
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
    
    func deleteUser()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"id_contact":idCntct,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(deleteUser_URL)"
            
            
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
                                
                                appdelegate.showMessageHudWithMessage(msg as! NSString, delay: 2.0)
                                let cellToUpdate = self.tableView.cellForRow(at: self.FieldIndex!)
                                
                                let addBtn = cellToUpdate?.viewWithTag(45) as! UIButton
                                
                                addBtn.setImage(UIImage(named: "toadd"), for: UIControlState())
                                
                               let tempData2 = result.object(forKey: "data")! as! NSDictionary
                                
                                let userID = tempData2.object(forKey: "id_contact") as! String
                                
                                if self.filtered.count > 0
                                {
                                    let tempData = self.filtered.object(at: (self.FieldIndex! as NSIndexPath).row) as! NSDictionary
                                    
                                    let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                    
                                    
                                    dataToEdit.setObject("\(tempData2.object(forKey: "id_contact") as! String)", forKey: "id_contact" as NSCopying)
                                    
                                    dataToEdit.setObject("no", forKey: "is_already_added" as NSCopying)
                                    
                                    self.filtered.replaceObject(at: (self.FieldIndex as NSIndexPath).row, with: dataToEdit)
                        
                                }
                                else
                                {
                                    let tempData = self.contactList.object(at: (self.FieldIndex! as NSIndexPath).row) as! NSDictionary
                                    
                                    let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                    
                                    dataToEdit.setObject("no", forKey: "is_already_added" as NSCopying)
                                    
                                    self.contactList.replaceObject(at: (self.FieldIndex as NSIndexPath).row, with: dataToEdit)
                                }
                                
                                
                                if self.alreadyAddedContact.count > 0
                                {
                                    if let tempArray = (self.alreadyAddedContact.object(at: 0) as AnyObject) as? NSMutableArray
                                    {
                                        let temp = (self.alreadyAddedContact.object(at: 0) as AnyObject) as! NSMutableArray
                                        
                                        for i in 0..<temp.count
                                        {
                                            let TempDic =  temp.object(at: i) as! NSDictionary
                                            
                                            let alreadyAddedUserId = TempDic.object(forKey: "id_contact") as! String
                                            
                                            if alreadyAddedUserId == userID
                                            {
                                                
                                                temp.removeObject(at: i)
                                                break;
                                            }
                                            
                                        }
                                        self.alreadyAddedContact.replaceObject(at: 0, with: temp)
                                    }
                                    
                                }
                                
//                                self.updatePlist(FieldIndex: self.FieldIndex!)
                                
                                self.edit = true
                                
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

    func deleteAppUser()
    {
        if appdelegate.hasConnectivity()
        {
            appdelegate.showProgressHudForViewMy(self.view, withDetailsLabel: "Please wait", labelText: "Requesting...")
            
            let cellToUpdate = self.tableView.cellForRow(at: FieldIndex!)
            
            let addBtn = cellToUpdate?.viewWithTag(45) as! UIButton
            
           let manager: AFHTTPSessionManager = AFHTTPSessionManager ()
            let serializer: AFJSONResponseSerializer = AFJSONResponseSerializer ()
            manager.responseSerializer = serializer
            let param=["user_id":UserDefaults.standard.object(forKey: "user_id") as! String,"id_contact":idCntct,"mode":""] as NSDictionary
            print(param)
            let url="\(base_URL)\(deleteAppUser_URL)"
            
            
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
                                let msg = result.object(forKey: "message")! as! String
                                
                                appdelegate.showMessageHudWithMessage(msg as NSString, delay: 2.0)
                                
                                addBtn.setImage(UIImage(named: "toadd"), for: UIControlState.normal)
                                
                           
                                let tempData = self.contactList.object(at: (self.FieldIndex! as NSIndexPath).row) as! NSDictionary
                                
                                let dataToEdit:NSMutableDictionary = tempData.mutableCopy() as! NSMutableDictionary
                                
                                
                                dataToEdit.setObject("no", forKey: "is_already_added" as NSCopying)
                                
                                self.contactList.replaceObject(at: (self.FieldIndex as NSIndexPath).row, with: dataToEdit)
                                
                                self.edit = true
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

    
    /**
     This function is called when page is changed.
     
     - parameter indexPath: NSIndexPath.
     */
    func loadMore(_ indexPath:IndexPath)
    {
        if (indexPath as NSIndexPath).row == contactList.count - 1
        {
            if ((indexPath as NSIndexPath).row+1)%10 == 0 && contactList.count>0
            {
                page = contactList.count/10
                if page == 0
                {
                    
                }
                page = page + 1
                self.appUsers()
            }
        }
        
        
    }
    
    
    
    func newPersonViewController(_ newPersonView: ABNewPersonViewController, didCompleteWithNewPerson person: ABRecord?) {
        
        newPersonView.dismiss(animated: true, completion: nil)
        
        newPersonView.navigationController?.popViewController(animated: true)
        
         let status = ABAddressBookGetAuthorizationStatus()
        
        if status == .denied || status == .restricted
        {
            // user previously denied, to tell them to fix that in settings
            return
        }
        
        // open it
        
        var error: Unmanaged<CFError>?
        
        let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        if addressBook == nil {
            print(error?.takeRetainedValue())
            return
        }
        
        let myArray = NSMutableArray()
        
        self.getAllContacts(myArray,addressBook: addressBook)

    }
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
       
        peoplePicker.popViewController(animated: true)
        

    }
    //MARK:- ABPersonViewController Delegate MEthod
    
    func personViewController(_ personViewController: ABPersonViewController,
                              shouldPerformDefaultActionForPerson person: ABRecord,
                              property: ABPropertyID,
                              identifier: ABMultiValueIdentifier) -> Bool
    {
       self.navigationController?.popoverPresentationController
        return true
    }
    
    //MARK:- helping func

    /**
     This function is used to referesh list when full to referesh is performed.
     
     - parameter sender: AnyObject
     */
    
    func refresh(_ sender:AnyObject)
    {
        self.refreshControl.endRefreshing()
        
        let noRecord = self.view.viewWithTag(777) as! UILabel!
        noRecord?.isHidden = true
        
        if(viewType=="appUser")
        {
            searching = false
            search.text=""
            searchKey=""
            page = 1
            contactList.removeAllObjects()
            self.appUsers()
        }
        else
        {
            searching = false
            search.text=""
             filtered.removeAllObjects()
            tableView.reloadData()
        }
        
    }
    
    func doneTyping()
    {
        view.endEditing(true)
    }
    
    
    
    
    
}
