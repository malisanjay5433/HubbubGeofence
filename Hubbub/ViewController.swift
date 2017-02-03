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
    let ENTERED_REGION_MESSAGE = "Welcome,Lets connect each other"
    let ENTERED_REGION_NOTIFICATION_ID = "EnteredRegionNotification"
    let EXITED_REGION_MESSAGE = "Bye! We hope you had good time with us"
    let EXITED_REGION_NOTIFICATION_ID = "ExitedRegionNotification"
    var pathOfPolygon =  GMSMutablePath()
    @IBOutlet var lat: UITextField?
    @IBOutlet var lon: UITextField?
    @IBOutlet var accuracy: UITextField?
    @IBOutlet var check: UIButton?
    let places = HubbubModel.hubbubPlaces(file_path:json_Type.hub3)
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
        addPlogone()

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
    /// - Parameter sender:
    @IBAction func isAvalibleinsidePolygone(_ sender: UIButton){
        let latitude = lat?.text
        let longitude = lon?.text
        if latitude != "" && longitude != "" {
            //            pathOfPolygon.removeAllCoordinates()
            for p in places {
                pathOfPolygon.add(p.coordinate)
            }
            if GMSGeometryContainsLocation(CLLocationCoordinate2DMake(Double(latitude!)!, Double(longitude!)!), pathOfPolygon, true) {
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
    /// Setup User location and geofencing area
    //    func setUpGeofence() {
    //        let geofenceRegionCenter = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!,(locationManager.location?.coordinate.longitude)!);
    //        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 100, identifier: "Its me bro..");
    //        geofenceRegion.notifyOnExit = true;
    //        geofenceRegion.notifyOnEntry = true;
    //        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    //        let mapRegion = MKCoordinateRegion(center: geofenceRegionCenter, span: span)
    //        self.map.setRegion(mapRegion, animated: true)
    //        let regionCircle = MKCircle(center: geofenceRegionCenter, radius: 500)
    //        self.map.add(regionCircle)
    //        self.map.showsUserLocation = true;
    //        self.locationManager.startMonitoring(for: geofenceRegion)
    //    }
    //MARK - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            //            self.setUpGeofence()
            setupMap()
        }
    }
    func setupMap(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            let loc_coords = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!,(locationManager.location?.coordinate.longitude)!)
            drawCircle(loc_coords)
            map.settings.myLocationButton = true
            map.camera = GMSCameraPosition.camera(withLatitude:72.81, longitude:18.981, zoom: 15.0)
            map.settings.myLocationButton = true
//            setMarkersOnMap((locationManager.location?.coordinate.latitude)!, lng:(locationManager.location?.coordinate.longitude)!, snipet: "Its me")
            
        }
        
    }
    func drawCircle(_ position: CLLocationCoordinate2D) {
        
        let circle = GMSCircle(position: position, radius: 1000)
        circle.strokeColor = UIColor.blue
        circle.fillColor = UIColor(red: 0, green: 0, blue: 0.35, alpha: 0.05)
        circle.map = map
        
    }
    func setMarkersOnMap(_ lat: Double, lng: Double,snipet: String) {
        let marker = GMSMarker()
        //        var markerView:UIImageView!
        marker.position = CLLocationCoordinate2DMake(lat,lng)
        marker.title = title
        // marker.snippet = snipet
        marker.isFlat = true
        marker.icon = UIImage(named: "Marker")
        marker.map = map
        self.map.animate(toLocation: marker.position)
    }
    
    func addAnnotaton(){
        for i in places{
        setMarkersOnMap(i.lat!, lng: i.lon!, snipet:"")
        }
    }
    func addingPolyline(){
        let path = GMSMutablePath()
        path.removeAllCoordinates()
        for i in places{
            print("CLLocationCoordinate2D:\(i.lat,i.lon)")
            path.add(CLLocationCoordinate2D(latitude:i.lon!, longitude:i.lat!))
            let polyline = GMSPolyline(path: path)
            polyline.geodesic = true
            polyline.map = map
            polyline.strokeColor = .red//UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1)
            polyline.strokeWidth = 3
            
        }
    }
    
    func addPlogone(){
        let path = GMSMutablePath()
        path.removeAllCoordinates()
        for i in places{
            print("i:\(i.lon,i.lat)")
                    path.add(CLLocationCoordinate2D(latitude:i.lon!, longitude:i.lat!))
                    let polyline = GMSPolygon(path: path)
                    polyline.geodesic = true
                    polyline.map = map
                    polyline.strokeColor = .white//UIColor.init(colorLiteralRed:33/255, green: 202/255, blue: 153/255, alpha: 1)
                    polyline.strokeWidth = 3
                    
    }
    }
    
    
    
    /// didStartmonitoring region
    /// - Parameters:
    ///   - manager: The CLLocationManager object is your entry point to the location service
    ///   - region:A logical area
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started Monitoring Region: \(region.identifier)")
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
    /// Addding annoatations to mapView
    //    func addAnnotations() {
    //        print("Count:\(places.count)")
    //        for i in places{
    //            print("Place Coorindates:\(i.coordinate)")
    //        }
    //        map?.delegate = self
    //        map?.addAnnotations(places)
    //        let overlays = places.map { MKCircle(center: $0.coordinate, radius: 1000) }
    //        map?.addOverlays(overlays)
    //    }
    //    /// adding polylines  to array of latitude and longitude
    //    func addPolyline() {
    //        var locations = places.map { $0.coordinate }
    //        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
    //        map?.add(polyline)
    //    }
    //
    //    /// Adding Polygon area to array of latitude and longitude
    //    func addPolygon() {
    //        var locations = places.map { $0.coordinate }
    //        let polygon = MKPolygon(coordinates: &locations, count: locations.count)
    //        map?.add(polygon)
    //
    //    }
    /// Authorised location user info
    /// Determines whether the user has location services enabled.
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "Marker")
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    ///
    ///
    /// - Parameters:
    ///   - mapView: <#mapView description#>
    ///   - overlay: <#overlay description#>
    /// - Returns: <#return value description#>
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKCircle {
//            let renderer = MKCircleRenderer(overlay: overlay)
//            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
//            renderer.strokeColor = UIColor.blue
//            renderer.lineWidth = 2
//            return renderer
//            
//        } else if overlay is MKPolyline {
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = UIColor.red
//            renderer.lineWidth = 3
//            return renderer
//            
//        } else if overlay is MKPolygon {
//            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
//            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
//            renderer.strokeColor = UIColor.orange
//            renderer.lineWidth = 2
//            return renderer
//        }
//        
//        return MKOverlayRenderer()
//    }
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
}

