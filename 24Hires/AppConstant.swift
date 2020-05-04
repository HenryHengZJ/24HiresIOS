//
//  AppConstant.swift
//  JobIn24
//
//  Created by Jeekson Choong on 13/03/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import Foundation

class AppConstant: NSObject{
    
    //Global Variable
    static var location: String = "Kuala Lumpur"
    static let appLanguage: String = "English"
    
    //Segue
    
    static let segueIdentifier_HomeToSearchMenu             = "homeToSearchMenu"
    static let segueIdentifier_SearchMenuToStateList        = "searchMenuToStateList"
    static let segueIdentifier_SearchMenuToCategoryResult   = "searchMenuToCategoryResult"
    static let segueIdentifier_ShowWebView                  = "showWebView"
    static let segueIdentifier_SignInToResetPsw             = "toResetPsw"
    static let segueIdentifier_nearbyJobToJobDetails        = "showJobDetails"
    static let segueIdentifier_homeToStateList              = "homeToStateList"
    static let segueIdentifier_homeToSearchCategory         = "homeToSeachCategory"
    static let segueIdentifier_searchCategoryToFilter       = "searchCategoryToFilter"
    static let segueIdentifier_profileMainToMyProfile       = "toMyProfile"
    static let segueIdentifier_profileMainToPointsAndRewars = "toPointsAndRewards"
    static let segueIdentifier_profileMainToTalents         = "toTalents"
    static let segueIdentifier_profileMainToPostJob         = "profileToPostJob"
    static let segueIdentifier_profileMainToHowItWorks      = "toHowItWorks"
    static let segueIdentifier_profileMainToSettings        = "profileToSetting"
    static let segueIdentifier_myProfileToEditAboutMe       = "toEditAboutMe"
    static let segueIdentifier_myProfileToEditEducation     = "toEditEducation"
    static let segueIdentifier_myProfileToEditLanguages     = "toEditLanguages"
    static let segueIdentifier_myProfileToEditEmail         = "toEditEmail"
    static let segueIdentifier_appliedToViewMoreDetails     = "toViewMoreDetails"
    static let segueIdentifier_appliedToViewMoreWithStatus  = "toAppliedReview"
    static let segueIdentifier_appliedToFeedback            = "toFeedback"
    static let segueIdentifier_hireFormToCalender           = "hireFormToCalender"
    static let segueIdentifier_hiredToHirerViewDetails      = "toHirerViewDetails"
    static let segueIdentifier_hirerToReviewForm            = "hirerToReviewForm"
    static let segueIdentifier_hirerViewDetailsToHireForm   = "hirerViewDetailsToHireForm"
    
    //Notification Name
    static let notification_selectLocationToSearchMenu = "selectlocationtosearchmenu"
    
    //URL Link
    static let URL_privacyPolicy = "https://24hires.com/privacy-policy/"
    static let URL_termsAndConditions = "https://24hires.com/terms-of-use/"

}
