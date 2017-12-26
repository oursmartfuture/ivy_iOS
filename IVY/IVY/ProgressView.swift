//
//  ProgressView.swift
//  IVY
//
//  Created by SS068 on 15/11/16.
//  Copyright © 2016 Singsys Pte Ltd. All rights reserved.
//

import Foundation
import UIKit;

@available(iOS 9.0, *)
class ProgressView: UIView {
    
    enum Theme {
        case Light
        case Dark
    }
    
    var theme:Theme;
    var container:UIStackView;
    var activityIndicator: UIActivityIndicatorView;
    var label: UILabel;
    var glass:UIView;
    
    
    private var Message:String;
    private var isModal:Bool;
    
    init(Message: String,Theme:Theme, IsModal:Bool) {
        //init
        self.Message = Message;
        self.theme=Theme;
        self.isModal=IsModal;
        
       
        self.container=UIStackView()
      
        self.activityIndicator=UIActivityIndicatorView();
        self.label = UILabel();
        self.glass = UIView();
        //get proper width by text message
        let fontName=self.label.font.fontName;
        let fontSize=self.label.font.pointSize;
        if let font = UIFont(name: fontName, size: fontSize)
        {
            let fontAttributes = [NSFontAttributeName: font];
            let size = (Message as NSString).size(attributes: fontAttributes)
            super.init(frame: CGRect(x: 0, y: 0, width: size.width + 50, height: 50));
        }else{
            super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 50));
        }
        
        //detect rotation
        NotificationCenter.default.addObserver(self, selector: #selector(onRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil);
        
        //style
        self.layer.cornerRadius = 3;
        if (self.theme == .Dark){
            self.backgroundColor=UIColor.darkGray;
        }else{
            self.backgroundColor=UIColor.lightGray;
        }
        
        //label
        if self.theme == .Dark{
            self.label.textColor=UIColor.white;
        }else{
            self.label.textColor=UIColor.black;
        }
        self.label.text=self.Message;
        //container
        self.container.frame=self.frame;
        self.container.spacing=5;
        self.container.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        self.container.isLayoutMarginsRelativeArrangement = true
        //Activity indicator
        if (self.theme == .Dark){
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.whiteLarge);
            self.activityIndicator.color = UIColor.white;
        }else{
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.whiteLarge);
            self.activityIndicator.color = UIColor.black;
        }
        self.activityIndicator.startAnimating();
        //Add them to container
        
        //First glass
        if let superview = UIApplication.shared.keyWindow {
            if (self.isModal){
                //glass
                self.glass.frame=superview.frame;
                if (self.theme == .Dark){
                    self.glass.backgroundColor  = UIColor.black.withAlphaComponent(0.5);
                }else{
                    self.glass.backgroundColor  = UIColor.white.withAlphaComponent(0.5);
                }
                superview.addSubview(glass);
            }
        }
        //Then activity indicator and label
        container.addArrangedSubview(self.activityIndicator);
        container.addArrangedSubview(self.label);
        //Last attach it to container (StackView)
        self.addSubview(container);
        if let superview = UIApplication.shared.keyWindow {
            self.center=superview.center;
            superview.addSubview(self);
        }
        //Do not show until show() is called;
        self.hide();
    }
    
    required init(coder: NSCoder) {
        self.theme = .Dark;
        self.Message = "Not set!";
        self.isModal=true;
        self.container=UIStackView();
        self.activityIndicator=UIActivityIndicatorView();
        self.label = UILabel();
        self.glass = UIView();
        super.init(coder: coder)!
    }
    
    func onRotate(){
        if let superview = self.superview {
            self.glass.frame=superview.frame;
            self.center=superview.center;
            //            superview.addSubview(self);
        }
    }
    
    public func show() {
        self.glass.isHidden=false;
        self.isHidden = false
    }
    
    public func hide() {
        self.glass.isHidden=true;
        self.isHidden=true;
    }
}
