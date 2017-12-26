//
//  contactsViewController.swift
//  IVY
//
//  Created by Singsys on 19/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class contactsViewController: UIViewController {
    class Pet: CustomStringConvertible {
        var firstName: String!
        var lastName: String!
        var phoneNumber: String!
        var imageData: NSData!
        
        var description : String {
            return firstName + " " + lastName
        }
        
        init(firstName: String, lastName: String, phoneNumber: String, imageName: String) {
            self.firstName = firstName
            self.lastName = lastName
            self.phoneNumber = phoneNumber
            self.imageData = UIImageJPEGRepresentation(UIImage(named: imageName)!, 0.7)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    }
