//
//  VerificationAlertDelegate.swift
//  JobIn24
//
//  Created by MacUser on 03/05/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

protocol VerificationAlertDelegate: class {
    func okButtonTapped(textFieldValue: String)
    func cancelButtonTapped()
}
