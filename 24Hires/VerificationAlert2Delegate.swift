//
//  VerificationAlert2Delegate.swift
//  JobIn24
//
//  Created by MacUser on 03/05/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

protocol VerificationAlert2Delegate: class {
    func verifyButtonTapped(textFieldValue: String)
    func resendButtonTapped()
    func editPhoneTapped()
}
