//
//  NearbyJobViewController.swift
//  JobIn24
//
//  Created by Henry Heng on 8/26/17.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import GeoFire
import GoogleMaps
import GooglePlacePicker

class NearbyJobViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var mapView          : GMSMapView!
    @IBOutlet weak var tableView        : UITableView!
    @IBOutlet weak var pinImage         : UIImageView!
    @IBOutlet weak var noJobView        : UIView!
    @IBOutlet weak var dismissButton    : SelectableBackgroundButton!
    @IBOutlet weak var dismissButtonView: UIView!
    
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var ref : DatabaseReference!

    var jobCount            = Int()
    var latitude            = Double()
    var longitude           = Double()
    var currentCity         = ""
    var previousCity        = ""
    var googleMapView       = GMSMapView()
    var locationManager     = CLLocationManager()
    var currentCLLocation   = CLLocation()
    var jobList             = [Job()]
    var oldKey              = ""
    var keyEntered          = Bool()
    var selectedJobPostKey  = String()
    var selectedJobCity     = String()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == AppConstant.segueIdentifier_nearbyJobToJobDetails){
            
            let dest        = segue.destination as! JobDetail
            dest.postid     = selectedJobPostKey
            dest.city       = selectedJobCity
//            dest.isFromNearby   = true
            
            let backButton = UIBarButtonItem()
            backButton.title = "Back"
            navigationItem.backBarButtonItem = backButton
            navigationController?.navigationBar.tintColor = UIColor.init(red: 58, green: 178, blue: 244, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//
        mapView.delegate = self
        
        tableView.tableFooterView       = UIView()
        tableView.estimatedRowHeight    = 125
        tableView.rowHeight             = UITableViewAutomaticDimension
        
        dismissButtonView.layer.cornerRadius    = dismissButtonView.frame.size.width/2
        dismissButtonView.clipsToBounds         = true
        
    }
    
    func checkLocationPermission(){
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
//        case .notDetermined:
//            // Request when-in-use authorization initially
//            locationManager.requestWhenInUseAuthorization()
//            break
            
        case .notDetermined, .restricted, .denied:
            // Disable location features
            print("Prompt Message to enable location service")
            DispatchQueue.main.async {
                self.promptLocationAlert()
            }
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
//            enableMyAlwaysFeatures()
            break
        }
}
    
    func createImage(_ count: Int) -> UIImage {
        let color = UIColor.red
        let string = "\(UInt(count))"
        let attrs = [NSAttributedStringKey.foregroundColor : color]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        let image = UIImage(named: "location2")!
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
        let rect = CGRect(x: CGFloat(13), y: CGFloat(4), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return markerImage
    }
    
    func showMarker(position: CLLocationCoordinate2D,title: String, snippet: String, count: Int){
        print("[NearbyJob]: Add Marker for \(title)\n")
        
        let marker      = GMSMarker()
        marker.icon     = createImage(count)
        marker.position = position
        marker.title    = title
        marker.snippet  = snippet
        marker.map      = mapView
    }
 
    
    func getNearbyJob(location: CLLocation){
        
        oldKey = ""
        jobCount = 0
        keyEntered = false
        jobList.removeAll()
        noJobView.isHidden = false
        print("[GetNearByJob] Current City: \(currentCity)\n")
        ref = Database.database().reference()
        
        if previousCity != currentCity{
            mapView.clear()
            previousCity = currentCity
        }
        
        let geoRef = GeoFire(firebaseRef: ref.child("JobsLocation").child(currentCity))
        
        let query = geoRef.query(at: location, withRadius: 1000)
       
        query.observe(.keyEntered, with: { key, Qlocation in
            print("Key: " + key + " entered the search radius.")
            self.keyEntered = true
            
            if (key != self.oldKey){

                self.ref.child("Job").child(self.currentCity).observeSingleEvent(of: .value , with: { (snapShot) in
                    if(snapShot.exists()){
                        if (snapShot.childSnapshot(forPath: key).exists()){
                            if snapShot.childSnapshot(forPath: key).hasChild("title") &&
                                snapShot.childSnapshot(forPath: key).hasChild("fulladdress") &&
                                snapShot.childSnapshot(forPath: key).hasChild("postimage") &&
                                snapShot.childSnapshot(forPath: key).hasChild("postkey") &&
                                snapShot.childSnapshot(forPath: key).hasChild("city") &&
                                snapShot.childSnapshot(forPath: key).hasChild("closed"){
                                
                                print("[Nearby Job] Snapshot Exist")
                                let jobObj = Job()
                                
                                jobObj.title        = snapShot.childSnapshot(forPath: key).childSnapshot(forPath: "title").value as! String
                                jobObj.fullAddress  = snapShot.childSnapshot(forPath: key).childSnapshot(forPath: "fulladdress").value as! String
                                jobObj.postImage    = snapShot.childSnapshot(forPath: key).childSnapshot(forPath: "postimage").value as! String
                                jobObj.postKey      = snapShot.childSnapshot(forPath: key).childSnapshot(forPath: "postkey").value as! String
                                jobObj.city         = snapShot.childSnapshot(forPath: key).childSnapshot(forPath: "city").value as! String
                                jobObj.closed       = snapShot.childSnapshot(forPath: key).childSnapshot(forPath: "closed").value as! String
                                
                                if (jobObj.closed == "false"){
                                    self.jobCount += 1
                                    jobObj.count = self.jobCount
                                    
                                    print("[JobCount] \(self.jobCount)")
                                    
                                    self.jobList.append(jobObj)
                                    print(Qlocation.coordinate)
                                    self.showMarker(position: Qlocation.coordinate, title: jobObj.title, snippet: jobObj.fullAddress, count: self.jobCount)
                                }
                            }
                        }
                    }
                    self.noJobView.isHidden = true
                    self.tableView.reloadData()
                })
            }
            self.oldKey = key
        })
        
        query.observeReady {
            print("IsKeyEntered: \(self.keyEntered)")
            if (!self.keyEntered){
                self.jobList.removeAll()
                print(self.jobList)
                self.tableView.reloadData()
            }
        }
        
    }
    
    func promptLocationAlert(){
        let alertVC = UIAlertController(title: "Geolocation is not enabled", message: "For using geolocation you need to enable it in Settings", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) { value in
            let path = "App-Prefs:root=Privacy&path=LOCATION_SERVICES"
//            UIApplicationOpenSettingsURLString
            if let settingsURL = URL(string: path), UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.openURL(settingsURL)
            }
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
//    func getCurrentCity(coordinate: CLLocationCoordinate2D){
//        let geocoder = GMSGeocoder()
//        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
//            guard let address = response?.firstResult(), let lines = address.lines else {
//                return
//            }
//        }
//    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if (CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
            reverseGeocodeCoordinate(position.target)
            latitude    = position.target.latitude
            longitude   = position.target.longitude
        }else{
            promptLocationAlert()
        }
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            print("Full Address: \(lines)\n")
            print("Admin Area: \(String(describing: address.administrativeArea))")
            let adminArea = address.administrativeArea
            
            if adminArea != nil{
                if (adminArea?.contains("Kuala Lumpur"))! {
                    self.currentCity = "Kuala Lumpur"
                }else if (adminArea?.contains("Johor"))!{
                    self.currentCity = "Johor"
                }else if (adminArea?.contains("Kelantan"))!{
                    self.currentCity = "Kelantan"
                }else if (adminArea?.contains("Labuan"))!{
                    self.currentCity = "Labuan"
                }else if (adminArea?.contains("Negeri Sembilan"))!{
                    self.currentCity = "Negeri Sembilan"
                }else if (adminArea?.contains("Kedah"))!{
                    self.currentCity = "Kedah"
                }else if (adminArea?.contains("Pahang"))!{
                    self.currentCity = "Pahang"
                }else if (adminArea?.contains("Perak"))!{
                    self.currentCity = "Perak"
                }else if (adminArea?.contains("Perlis"))!{
                    self.currentCity = "Perlis"
                }else if (adminArea?.contains("Putrajaya"))!{
                    self.currentCity = "Putrajaya"
                }else if (adminArea?.contains("Sabah"))!{
                    self.currentCity = "Sabah"
                }else if (adminArea?.contains("Sarawak"))!{
                    self.currentCity = "Sawarak"
                }else if (adminArea?.contains("Selangor"))!{
                    self.currentCity = "Selangor"
                }else if (adminArea?.contains("Terengganu"))!{
                    self.currentCity = "Terengganu"
                }else if (adminArea?.contains("Melaka"))! || (adminArea?.contains("Melacca"))!{
                    self.currentCity = "Melacca"
                }else if (adminArea?.contains("Penang"))! || (adminArea?.contains("Pulau Pinang"))!{
                    self.currentCity = "Penang"
                }else{
                    self.currentCity = adminArea!
                }
            }else{
                if address.locality != nil{
                    self.currentCity = address.locality!
                }else{
                    self.currentCity = address.country!
                }
            }

            print("[Converted City]: \(self.currentCity)\n")
            print("[Longitude]: \(self.longitude) [Latitude]: \(self.latitude)\n")
            
            self.getNearbyJob(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude) )
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if(status == .authorizedAlways || status == .authorizedWhenInUse ){
            locationManager.startUpdatingLocation()
            print("[Permission Granted]: Start Location detect")
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }else{
            promptLocationAlert()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Update Location")
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
        currentCLLocation = location
        
        locationManager.stopUpdatingLocation()
    }
    
    

    //MARK:- TABLE VIEW DELEGATE
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(jobList.count)
        return jobList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "nearbyJobTableViewCell", for: indexPath) as? NearbyJobTableViewCell else{
            fatalError("[NEARBY JOB] Table View Cell error.")
        }
        
        let jobDetails = jobList[indexPath.row]
        let imageURL: String = jobDetails.postImage
        
        if imageURL != "" {
            cell.jobImage.sd_setImage(with: URL(string: imageURL))
        }
        
        cell.titleLabel.text    = jobDetails.title
        cell.addressLabel.text  = jobDetails.fullAddress
        cell.markerNumber.image = createImage(indexPath.row+1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedJobPostKey  = jobList[indexPath.row].postKey
        selectedJobCity     = currentCity
        
        print("[Selected Job Key]: \(selectedJobPostKey)")
        
        if selectedJobPostKey != "" && selectedJobCity != ""{
            print("Start Navigation to Job Details\n")
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
//            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
//
//            nextViewController.city     = selectedJobCity
//            nextViewController.postid
//                = selectedJobPostKey
            //self.performSegue(withIdentifier: AppConstant.segueIdentifier_nearbyJobToJobDetails, sender: self)
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "JobDetail") as! JobDetail
            
            destinationVC.postid = selectedJobPostKey
            destinationVC.city = selectedJobCity
            
            self.navigationController?.pushViewController(destinationVC, animated: true)
         

//            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    

    
}

