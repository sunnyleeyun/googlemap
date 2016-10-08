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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    //
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    

    @IBAction func showSearchBar(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    var locationManager : CLLocationManager!
    
    @IBOutlet weak var myMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
   //     let latitude:CLLocationDegrees = 48.858532
   //     let longitude:CLLocationDegrees = 2.294481
   //     let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        //sample1()
        //sample2()
        
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
        locationManager.activityType = .fitness
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        myMap.userTrackingMode = .followWithHeading
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.title = "Taiwan"
        myMap.addAnnotation(annotation)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations[0].coordinate
        
        print("緯度：\(coordinate.latitude)")
        print("經度：\(coordinate.longitude)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let identifier = "MyPin"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
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
        } as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler
    }
    func sample2(){
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Toilet"
        request.region = myMap.region
        let search = MKLocalSearch(request: request)
        search.start{
            (response:MKLocalSearchResponse?, error:NSError?) -> Void in
            if error == nil && response != nil{
                for item in response!.mapItems{
                    self.myMap.addAnnotation(item.placemark )
                }
            }
        } as! MKLocalSearchCompletionHandler as! MKLocalSearchCompletionHandler as! MKLocalSearchCompletionHandler as! MKLocalSearchCompletionHandler as! MKLocalSearchCompletionHandler as! MKLocalSearchCompletionHandler as! MKLocalSearchCompletionHandler
    }
    
    
    @IBAction func longPressAction(_ sender: AnyObject) {
        let touchPoint = sender.location(in: self.myMap)
        let coordinate = myMap.convert(touchPoint, toCoordinateFrom: self.myMap)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        myMap.addAnnotation(annotation)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.myMap.annotations.count != 0{
            annotation = self.myMap.annotations[0]
            self.myMap.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
}

