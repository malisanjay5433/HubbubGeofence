//
//  HubbubModel.swift
//  HUB
//
//  Created by Sanjay Mali on 27/01/17.
//  Copyright © 2017 Sanjay. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit
import GoogleMaps
@objc class HubbubModel: NSObject {
    var lat:Double?
    var lon:Double?
    var coordinate: CLLocationCoordinate2D
    init(coordinate:CLLocationCoordinate2D?,lat:Double,lon:Double) {
        self.lat = lat
        self.lon = lon
        self.coordinate = coordinate!
    }
    static func hubbubPlaces(file_path:String) -> [HubbubModel] {
        var places = [HubbubModel]()
        if let path : String = Bundle.main.path(forResource:file_path, ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json = JSON(data: data as Data)
                let data = json["results"].dictionary
                let geometry = data?["geometry"]?.array
                for item in geometry! {
                    for i in item {
                        let latitude = i.1["lat"].double, longitude = i.1["lon"].double
                        let place = HubbubModel(coordinate: CLLocationCoordinate2DMake(latitude!,longitude!),lat:latitude!,lon:longitude!)
                        places.append(place)
                    }
                }
            }
        }
        return places as [HubbubModel]
    }
}
extension HubbubModel: MKAnnotation {
}
