//
//  JobLocationViewController.swift
//  JobIn24
//
//  Created by MacUser on 14/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlacePicker

class JobLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var googleMapView = GMSMapView()
    var locationManager = CLLocationManager()
    var placePicker: GMSPlacePickerConfig!
    var latitude: Double!
    var longitude: Double!
    var jobtitle: String!

    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var closeView: UIView!
    
    @IBOutlet weak var closeBtn: SelectableBackgroundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Lat: \(latitude)\nLong: \(longitude)")
        
        if CLLocationManager.locationServicesEnabled() {
         print("location enabled")
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
         locationManager.startUpdatingLocation()
         
         locationManager.requestAlwaysAuthorization()
         locationManager.requestWhenInUseAuthorization()
        }
        
        closeView.layer.cornerRadius = closeView.frame.size.width/2
        closeView.clipsToBounds = true
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.googleMapView = GMSMapView(frame: self.view.frame)
        self.googleMapView.animate(toZoom: 13.0)
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 13.0)
        googleMapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        googleMapView.camera = camera
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.zoomGestures = true
        self.mapView.addSubview(googleMapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = jobtitle
        marker.map = self.googleMapView
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
     
        if (status == CLAuthorizationStatus.authorizedWhenInUse){
             print("location enabled2")
            googleMapView.isMyLocationEnabled = true
        }
        
     }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 1
        let location:CLLocation = locations.last!
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        print("self.latitude: \(self.latitude)")
        print("self.longitude: \(self.longitude)")
        
        // 2
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 18.0)
        googleMapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        googleMapView.camera = camera
        self.mapView.addSubview(googleMapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        marker.title = "I am here"
        marker.map = self.googleMapView
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
