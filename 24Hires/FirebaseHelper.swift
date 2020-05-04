//
//  FirebaseHelper.swift
//  JobIn24
//
//  Created by Jeekson Choong on 29/03/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseHelper: NSObject {
    
    
    static var userAccountRef = Database.database().reference().child("UserAccount")
    
    
    
    static func getUserName(UID: String) -> String{
        var name = String()
        
        userAccountRef.child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
               
                if snapshot.hasChild("name"){
                    name = (snapshot.childSnapshot(forPath: "name").value as? String)!
                    
                }else{
                  
                    name = ""
                }
            }else{
             
                name = ""
            }
        }) { (error) in
            if error.localizedDescription != ""{
                print("[GET NAME] Error: \(error.localizedDescription)")
            }
        }
        
        
        return name
        
        
    }
   
    
    
}
