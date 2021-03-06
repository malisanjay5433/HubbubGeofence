//
//  ViewController.swift
//  HUB
//
//  Created by Sanjay Mali on 27/01/17.
//  Copyright © 2017 Sanjay. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import KRProgressHUD
import UserNotifications
import GoogleMaps
struct json_Type {
    static let hub = "hub"
    static let hub2 = "hub2"
    static let hub3 = "hub3"
}
class ViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate,GMSMapViewDelegate{
    //    @IBOutlet var map : MKMapView!
    @IBOutlet var map : GMSMapView!
    @IBOutlet var notificationLabel : UILabel!
    var locationManager  = CLLocationManager()
    let ENTERED_REGION_MESSAGE = "Welcome Hubbub!!!, Stay connected to the people and places around you on Hubbub"
    let ENTERED_REGION_NOTIFICATION_ID = "EnteredRegionNotification"
    let EXITED_REGION_MESSAGE = "Bye!!! Hope you had good time with us"
    let EXITED_REGION_NOTIFICATION_ID = "ExitedRegionNotification"
    var pathOfPolygon =  GMSMutablePath()
    @IBOutlet var lat: UITextField?
    @IBOutlet var lon: UITextField?
    @IBOutlet var accuracy: UITextField?
    @IBOutlet var check: UIButton?
    let places = HubbubModel.hubbubPlaces(file_path:json_Type.hub3)
    var p:HubbubModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigation_title()
        makeDesign()
        self.lat?.delegate = self
        self.lon?.delegate = self
        self.map.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
        }
        addAnnotaton()
        addingPolyline()
        addPloygone()
        
    }
    /// titleView for hubbub
    func navigation_title() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "logo-with-icon-small")
        imageView.image = image
        navigationItem.titleView = imageView
    }
    /// isAvailable func to check latitude and longitude inside or outside
    ///
    /// - Parameter sender: UIButton
    @IBAction func isAvalibleinsidePolygone(_ sender: UIButton){
        let latitude = lat?.text
        let longitude = lon?.text
        if latitude != "" && longitude != "" {
            // pathOfPolygon.removeAllCoordinates()
            for p in places {
                pathOfPolygon.add(p.coordinate)
            }
            if GMSGeometryIsLocationOnPathTolerance(CLLocationCoordinate2DMake(Double(latitude!)!, Double(longitude!)!), pathOfPolygon, true,60) {
                alert(title: "YEAH!!!", msg: "You are inside the polygon")
                self.createLocalNotification(message: "YEAH!!!...You are inside the polygon", identifier: ENTERED_REGION_NOTIFICATION_ID)
                locationManager.stopUpdatingLocation()
            } else {
                self.createLocalNotification(message: "OOPS...You are outside the polygon.", identifier: ENTERED_REGION_NOTIFICATION_ID)
                alert(title: "OPPS!!!", msg: "You are outside the polygon")
            }
        }else {
            alert(title: "Please enter", msg: "Latitude and longitude")
        }
        //        lat?.text = ""
        //        lon?.text = ""
        
    }
    /// Generic alert Controller
    ///
    /// - Parameters:
    ///   - title: Accepts title
    ///   - msg: Accepts msg
    func alert(title:String,msg:String){
        let alertController = UIAlertController(title:title, message:msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    /// textfield should return from textfield
    /// - Parameter textField:
    /// - Returns: returns bool value
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true
    }
    //MARK - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            setupMap()
        }
    }
    func setupMap(){
        for i in places {
        map.settings.myLocationButton = true
        map.camera = GMSCameraPosition.camera(withLatitude:(i.boundsMaxLongitude!), longitude:(i.boundsMinLatitude!), zoom: 15.0)
        map.settings.myLocationButton = true
        let geofenceRegionCenter = CLLocationCoordinate2DMake(i.boundsMaxLongitude!,i.boundsMinLatitude!);
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 500, identifier: "Its me bro..");
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        map.animate(toBearing: 0)
        self.locationManager.startMonitoring(for: geofenceRegion)
        }
    }
    ///A circle on the Earth's surface (spherical cap).
    ///
    /// - Parameter position: position CLLocationCoordinate2D which represents latitude and longitude
    func drawCircle(_ position: CLLocationCoordinate2D) {
        let circle = GMSCircle(position: position, radius: 1000)
        circle.strokeColor = UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1)
        circle.fillColor = UIColor(red: 0, green: 0, blue: 0.35, alpha: 0.05)
        circle.map = map
    }
    /// Set Marker on Google Map
    ///
    /// - Parameters:
    ///   - lat: latitude
    ///   - lng: longitude
    ///   - snipet: Any String character
    func setMarkersOnMap(_ lat: Double, lng: Double,snipet: String) {
        let marker = GMSMarker()
        //        var markerView:UIImageView!
        marker.position = CLLocationCoordinate2DMake(lat,lng)
        marker.title = title
        // marker.snippet = snipet
        marker.isFlat = true
        marker.icon = UIImage(named: "locationHubbub")
        marker.map = map
        self.map.animate(toLocation: marker.position)
    }
    
    /// Add Annotations to GMSMapView
    func addAnnotaton(){
        for i in places{
            setMarkersOnMap(i.lon!, lng: i.lat!, snipet:"")
        }
    }
    
    /// Drawing polylines on GMSMapView
    func addingPolyline(){
        let path = GMSMutablePath()
        path.removeAllCoordinates()
        for i in places{
            path.add(CLLocationCoordinate2D(latitude:i.lon!, longitude:i.lat!))
            let polyline = GMSPolyline(path: path)
            polyline.geodesic = true
            polyline.map = map
            polyline.strokeColor = UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1)
            polyline.strokeWidth = 3
            
        }
    }
    /// Drawing polygon on GMSMapView
    func addPloygone(){
        let path = GMSMutablePath()
        path.removeAllCoordinates()
        for i in places{
            path.add(CLLocationCoordinate2D(latitude:i.lon!, longitude:i.lat!))
            let polyline = GMSPolygon(path: path)
            polyline.geodesic = true
            polyline.map = map
            polyline.strokeColor = UIColor.black
            polyline.fillColor = UIColor.init(colorLiteralRed:176/255, green: 143/255, blue:52/255, alpha: 0.6)
        }
    }
    /// didStartmonitoring region
    /// - Parameters:
    ///   - manager: The CLLocationManager object is your entry point to the location service
    ///   - region:A logical area
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.notificationLabel.text = "We Started Region Monitoring,"
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(ENTERED_REGION_MESSAGE)
        self.notificationLabel.text = ENTERED_REGION_MESSAGE
        self.createLocalNotification(message: ENTERED_REGION_MESSAGE, identifier: ENTERED_REGION_NOTIFICATION_ID)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print(EXITED_REGION_MESSAGE)
        self.notificationLabel.text = EXITED_REGION_MESSAGE
        self.createLocalNotification(message: EXITED_REGION_MESSAGE, identifier: EXITED_REGION_NOTIFICATION_ID)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
    }
    /// Creating local notifications when user inside or outside polygone
    ///
    /// - Parameters:
    ///   - message: @param message
    ///   - identifier:@param for didEntry or didExist
    func createLocalNotification(message: String, identifier: String) {
        //Create a local notification
        let content = UNMutableNotificationContent()
        content.body = message
        content.sound = UNNotificationSound.default()
        
        // Deliver the notification
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: nil)
        
        // Schedule the notification
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
        }
    }
}
// MARK: - Extensions add new functionality to an existing class.
extension ViewController{
    /// Latitude textfield,Longitude textfield,checkButton adding color property,borderColor,borderWidth
    func makeDesign(){
        self.lat?.layer.borderWidth = 2.0
        self.lat?.layer.borderColor = UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1).cgColor
        self.lat?.layer.backgroundColor = UIColor.white.cgColor
        
        self.lon?.layer.borderWidth = 2.0
        self.lon?.layer.borderColor = UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1).cgColor
        self.lon?.layer.backgroundColor = UIColor.white.cgColor
        
        self.check?.layer.borderWidth = 2.0
        self.check?.layer.borderColor = UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1).cgColor
        self.check?.layer.backgroundColor = UIColor.white.cgColor
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "locationHubbub")
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    /**
     * @discussion Calculate the distance between two passed in locations in terms of kilometers.
     * @param source CLLocation represents the source location.
     * @param destination CLLocation represents the destination location.
     * @return Double represents the distance in terms of kilometers between two.
     */
    func calculateDisatnceBetweenTwoLocations(_ source:CLLocation,destination:CLLocation) -> Double{
        let distanceMeters = source.distance(from: destination)
        let distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM.roundedTwoDigit
        return roundedTwoDigit * 10000
    }
//    func accuracyCheck(latitude:Double,longitude:Double,accuracy:Double)->Bool{
//        let slatitude = lat?.text
//        let slongitude = lon?.text
//        let dest = CLLocation(latitude:latitude,longitude:longitude)
//        let source = CLLocation(latitude:Double(slatitude!)!, longitude:Double(slongitude!)!)
//        let distance = self.calculateDisatnceBetweenTwoLocations(source, destination: dest)
//        print("distance:\(distance)")
//        if accuracy == distance {
//            print("Distance between source and dest:\(distance)")
//            print("True")
//            return true
//        }
//        print("False")
//        return false
//    }
//    
}
extension Double {
    /**
     * @discussion round last two digits of the passed Double.
     */
    var roundedTwoDigit:Double {
        return Double(Darwin.round((100*self)/100))
    }
}

