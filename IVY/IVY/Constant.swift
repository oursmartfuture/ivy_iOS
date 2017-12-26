//
//  Constant.swift
//  Fun
//
//  Created by singsys on 8/10/15.
//  Copyright (c) 2015 singsys. All rights reserved.
//

import Foundation

import UIKit

let appdelegate = UIApplication.shared.delegate as! AppDelegate


class commonValidations: NSObject
{
    
    class func isValidEmail(_ testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidBNumber(_ testStr:String) -> Bool
    {
        let start = testStr.startIndex // Start at the string's start index
        let end = testStr.endIndex // Take start index and advance 2 characters forward
        let range = Range<String.Index>(uncheckedBounds: (lower: start, upper: end))
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        if let range = testStr.rangeOfCharacter(from: invalidCharacters, options: .literal, range: range)
        {
            return false
        }
        return true
        
    }
    
//    class func isValidBNumber(_ testStr:String) -> Bool
//    {
//        
//        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
//
////           let range1 = (invalidCharacters as NSString).range(of: invalidCharacters)
//        
////        let range1 = invalidCharacters.startIndex..<invalidCharacters.index(invalidCharacters.startIndex, offsetBy: 1)
//        // range is now type Range<Index>
//        
//        if let range = testStr.rangeOfCharacter(from: invalidCharacters, options: NSString.CompareOptions.literal, range: range1)
////        if let range = testStr.rangeOfCharacter(from: invalidCharacters, options: NSString.CompareOptions.literal, range:(testStr.characters.indices))
//            //if let range = testStr.rangeOfCharacter(from: <#T##CharacterSet#>, options: <#T##String.CompareOptions#>, range: testStr.endIndex?)
//            {
//            return false
//        }
//        return true
//    }
    
    class func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}
