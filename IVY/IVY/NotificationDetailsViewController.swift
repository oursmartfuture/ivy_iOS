//
//  NotificationDetailsViewController.swift
//  FindMe
//
//  Created by Singsys on 23/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class NotificationDetailsViewController: UIViewController
{
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
}
