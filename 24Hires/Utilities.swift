//
//  Utilities.swift
//  JobIn24
//
//  Created by Jeekson Choong on 25/03/2018.
//  Copyright © 2018 Jobin24 Official Team. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class Utilities: NSObject {
    
    
    static func text(forKey: String) -> String {
        
        if let languagePlistPath = Bundle.main.path(forResource: "LanguageStringList", ofType: "plist") {
            
            var language = AppConstant.appLanguage
            if language.isEmpty {
                language = "English"
                print("[Language Settings: Set Default As English]")
            }
            
            if let languageDictionary = NSDictionary.init(contentsOfFile: languagePlistPath) {
                if let languageDictionary = languageDictionary.object(forKey: language) as? Dictionary<String, String> {
                    if let languageText = languageDictionary[forKey] {
                        return languageText
                    }
                }
            }
        }
        
        return ""
    }
    
    static func changeDateFormat(dateStr: String) -> String?{
        //Str to Date
        var finalDateStr = String()
        do {
            let formatterStr = DateFormatter()
            formatterStr.locale = Locale(identifier: "en_US_POSIX")
            formatterStr.dateFormat = "yyMMdd"
            let date = formatterStr.date(from: dateStr)
            
            //Date to Str
            let formatterDate = DateFormatter()
            formatterDate.locale = Locale(identifier: "en_US_POSIX")
            formatterDate.dateFormat = "dd MMM yy"
            finalDateStr = formatterDate.string(from: date!)
            print("convert Date:",finalDateStr)
        }catch {
            print("[Convert Date Error]\n")
        }
        
        return finalDateStr
    }
    
    static func convertServerTimestamp(timestamp: TimeInterval) -> Date{
        
        print("\n===== Start TimeStamp Converter =====")
        let timeFormat = DateFormatter()
        timeFormat.timeZone = NSTimeZone.local
        
        let time = Date(timeIntervalSince1970: timestamp/1000)
        let timeString = timeFormat.string(from: time)
        let formattedDate = timeFormat.date(from: timeString)
        print("[Timestamp Before Convert]: \(timestamp)")
        print("[TimeStamp Convert Complete]: \(formattedDate)\n==============================")
        
        return time
    }
    
    static func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
}


extension UIViewController{
    internal func showAlertBox(title: String, msg: String, buttonString: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    internal func showAlertBoxWithAction(title: String, msg: String, buttonString: String, buttonAction: UIAlertAction){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: buttonString, style: .cancel , handler: nil)
        
        alert.addAction(buttonAction)
        alert.addAction(cancel)

        
        self.present(alert, animated: true)
    }
    
    /*internal func showAnonymousAlert() {
        // create the alert
        let alert = UIAlertController(title: "Are you sure you want to update \(applicantName)'s hiring details?", message: "", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { action in
            
            if ReachabilityTest.isConnectedToNetwork(){
                self.hireFunction()
            }else{
                self.noInternetAlert()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }*/
    
    internal func showAlertBoxWithOneAction(title: String, msg: String, buttonAction: UIAlertAction){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(buttonAction)
        
        
        self.present(alert, animated: true)
    }
    
    internal func noInternetAlert(){
        
        let noInternetAlert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Retry", style: .cancel, handler: nil)
        noInternetAlert.addAction(ok)
        
        self.present(noInternetAlert, animated: true)

    }
    
    internal func noInternetAlertForceRetry(buttonAction: UIAlertAction){
        let noInternetAlert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
        let retryAct = buttonAction
        noInternetAlert.addAction(retryAct)
        
        self.present(noInternetAlert, animated: true)
    }


    
}




import Foundation
import SystemConfiguration

public class ReachabilityTest {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
}
