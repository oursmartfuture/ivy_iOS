//
//  DeviceLocationViewController.swift
//  FindMe
//
//  Created by Singsys on 25/11/15.
//  Copyright © 2015 Singsys Pte Ltd. All rights reserved.
//

import UIKit
import MapKit
class DeviceLocationViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet var locationMap:MKMapView!
    var Deviceinfo:NSMutableArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceName = view.viewWithTag(1) as! UILabel!
        
        deviceName?.text = (self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "name") as? String
        
        _ = view.viewWithTag(2) as! UILabel!
        
        _ = view.viewWithTag(3) as! UILabel!
        
        let lastTime=(self.Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_seen_time") as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _ = dateFormatter.date(from: lastTime)
        
        dateFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
        
        
        //deviceTime.text = dateFormatter.stringFromDate(lastDate!)
        
        
        self.forAnnotation()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    
    func forAnnotation()
    {
        var arrText = ""
        
        
        let loc = CLLocation(latitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_lat") as! NSString).doubleValue, longitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_long") as! NSString).doubleValue)
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                let deviceLocation = self.view.viewWithTag(2) as! UILabel!
                
                
               // let arrCount = ((pm.addressDictionary!["FormattedAddressLines"])! as AnyObject).count
                
                let arrCount = (((pm.addressDictionary! as AnyObject).object(forKey: "FormattedAddressLines")! as AnyObject).count) as Int
                for i in stride(from: 0, to: Int(arrCount-1), by: 1)
                //for i in 0..<arrCount
                {
                    if arrText.isEmpty == true
                    {
                        
                        arrText = arrText + ((pm.addressDictionary!["FormattedAddressLines"] as! NSArray)[i] as! String)
                    }
                    else
                    {
                        arrText = arrText + ", " + ((pm.addressDictionary!["FormattedAddressLines"] as! NSArray)[i] as! String)
                    }
                }
                
                deviceLocation?.text = arrText
                self.next(arrText)
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
        })
        
        
        
        //        let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        //        longPress.minimumPressDuration = 1.0
        //        myMap.addGestureRecognizer(longPress)
        
        
    }
    
    func next(_ arrText:String)
    {
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_lat") as! NSString).doubleValue, longitude: ((Deviceinfo.object(at: 0) as AnyObject).object(forKey: "last_known_long") as! NSString).doubleValue)
        
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
        
        locationMap.setRegion(theRegion, animated: true)
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = arrText
        //    anotation.subtitle = arrText
        
        locationMap.addAnnotation(anotation)
        
    }
    
}
