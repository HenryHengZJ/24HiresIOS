//
//  VerificationAlert2.swift
//  JobIn24
//
//  Created by MacUser on 30/04/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class VerificationAlert2: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var code6: UITextField!
    @IBOutlet weak var code5: UITextField!
    @IBOutlet weak var code4: UITextField!
    @IBOutlet weak var code3: UITextField!
    @IBOutlet weak var code2: UITextField!
    @IBOutlet weak var code1: UITextField!
    @IBOutlet weak var alertView: UIView!
    
    var delegate: VerificationAlert2Delegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        code6.delegate = self
        code5.delegate = self
        code4.delegate = self
        code3.delegate = self
        code2.delegate = self
        code1.delegate = self
        
        code1.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        code2.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        code3.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        code4.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        code5.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        code6.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deanimateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    @objc func textFieldDidChange(textfield: UITextField) {
        
        let text = textfield.text
        
        if text?.count == 1 {
            switch textfield{
            case code1:
                code2.becomeFirstResponder()
            case code2:
                code3.becomeFirstResponder()
            case code3:
                code4.becomeFirstResponder()
            case code4:
                code5.becomeFirstResponder()
            case code5:
                code6.becomeFirstResponder()
            default:
                break
            }
            
        }
        
    }
    
    func deanimateView() {
        alertView.alpha = 1.0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        })
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return (textField.text?.count ?? 0) < 1 || string == ""
        
    }
    
    @IBAction func editphoneTap(_ sender: Any) {
        delegate?.editPhoneTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resendTap(_ sender: Any) {
        delegate?.resendButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func verifyTap(_ sender: Any) {
        
        let code1txt = code1.text!
        let code2txt = code2.text!
        let code3txt = code3.text!
        let code4txt = code4.text!
        let code5txt = code5.text!
        let code6txt = code6.text!
        
        if code1txt == "" || code2txt == "" || code3txt == "" || code4txt == "" || code5txt == "" || code6txt == "" {
            self.view.makeToast("Verification Code cannot be left empty", duration: 2.0, position: .center)
        }
        else {
            let verificode = code1txt + code2txt + code3txt + code4txt + code5txt + code6txt
            delegate?.verifyButtonTapped(textFieldValue: verificode)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
