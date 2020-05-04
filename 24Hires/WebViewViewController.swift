//
//  WebViewViewController.swift
//  JobIn24
//
//  Created by Jeekson on 25/03/2018.
//  Copyright © 2018 Jonin24 Official Team. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController {

    
    var url = String()
    
    @IBOutlet weak var backBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareWebView()
        // Do any additional setup after loading the view.
    }

    func prepareWebView(){
        let destination = URL(string: url)
        
        if let unwrappedURL = destination{
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request){(data,response, error) in
                
                if error == nil{
                    DispatchQueue.main.async {
                        self.webView.loadRequest(request)
                    }
                }else{
                    print("WEBVIEW ERROR:\(String(describing: error))")
            }
                
            }
            task.resume()
        }
    }
    
}
