//
//  DummyViewController.swift
//  IVY
//
//  Created by Singsys on 29/10/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit

class DummyViewController: UIViewController {
    
    @IBOutlet var splash:UIImageView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        splash.contentMode = UIViewContentMode.scaleAspectFit
//        if UIScreen.mainScreen().bounds.size.height == 480
//        {
//            splash.image = UIImage(named: "iphone4BackGround")
//        }
//        else
//        {
//            splash.image = UIImage(named: "iphone5BackGround")
//            
//        }
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DummyViewController.calling_app_delegate), userInfo: nil, repeats: false)
        
        
        UIView.animate(withDuration: 2.0, animations: {
            self.splash.alpha = 0.0
            
        })
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func calling_app_delegate()
    {
        
        
        dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "dummy")
        appdelegate.next()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden=true
    }
    
    
    
}






