//
//  ViewController.swift
//  googlemap
//
//  Created by Sunny on 2016/9/24.
//  Copyright © 2016年 Sunny. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var locationManager : CLLocationManager!
    //
    @IBOutlet weak var myMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
   //     let latitude:CLLocationDegrees = 48.858532
   //     let longitude:CLLocationDegrees = 2.294481
   //     let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        sample1()
        sample2()
        
        let coordinate = locationManager.location?.coordinate
        print("緯度：\(coordinate?.latitude)")
        print("經度：\(coordinate?.longitude)")

        
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
       // let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        //myMap.setRegion(region, animated: true)
        
        if coordinate != nil{
            let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate!, span)
            myMap.setRegion(region, animated: true)
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .Fitness
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        myMap.userTrackingMode = .FollowWithHeading
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.title = "Taiwan"
        myMap.addAnnotation(annotation)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations[0].coordinate
        
        print("緯度：\(coordinate.latitude)")
        print("經度：\(coordinate.longitude)")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let identifier = "MyPin"
        var result = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if result == nil{
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else{
            result?.annotation=annotation
        }
        result?.canShowCallout = true
        
        result?.image = UIImage(named:"myPin")
        
        //(result as! MKPinAnnotationView).pinTintColor = UIColor.blueColor()
        //(result as! MKPinAnnotationView).animatesDrop = true
        return result
    }
    
    func sample1(){
        let tunnel = CLLocation(latitude: 25.008547619473767, longitude: 121.5611477602709)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(tunnel){
            (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            if placemarks != nil{
                let placemark = placemarks![0]
                let infoDict = placemark.addressDictionary
                if infoDict != nil{
                    for (key, value) in infoDict!{
                        if value is NSArray{
                            for info in (value as! NSArray){
                                print("\(key):\(info)")
                            }
                        }else if value is NSString{
                                print("\(key):\(value)")
                            }
                    }
                }
            }
        }
    }
    func sample2(){
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Toilet"
        request.region = myMap.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler{
            (response:MKLocalSearchResponse?, error:NSError?) -> Void in
            if error == nil && response != nil{
                for item in response!.mapItems{
                    self.myMap.addAnnotation(item.placemark )
                }
            }
        }
    }
    
    
    @IBAction func longPressAction(sender: AnyObject) {
        let touchPoint = sender.locationInView(self.myMap)
        let coordinate = myMap.convertPoint(touchPoint, toCoordinateFromView: self.myMap)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        myMap.addAnnotation(annotation)
    }
}

