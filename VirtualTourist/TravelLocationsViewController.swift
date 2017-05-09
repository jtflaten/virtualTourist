//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/3/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {
    
    var pins: [NSManagedObject] = []
    
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        travelLocationsMapView.isUserInteractionEnabled = true
        let addPinGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.addPin))
        addPinGestureRecognizer.minimumPressDuration = 2.5
        self.travelLocationsMapView.addGestureRecognizer(addPinGestureRecognizer)
        
        
    }
    
    //TODO: build a fetchreequest that populates the mapView with pins from the container
    
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchedPoint = gestureRecognizer.location(in: travelLocationsMapView)
            let coordinatesFromTouchPoint = travelLocationsMapView.convert(touchedPoint, toCoordinateFrom: travelLocationsMapView)
            let newAnnotationFromLongTouch = MKPointAnnotation()
            newAnnotationFromLongTouch.coordinate = coordinatesFromTouchPoint
            travelLocationsMapView.addAnnotation(newAnnotationFromLongTouch)
            savePin(lat: newAnnotationFromLongTouch.coordinate.latitude, long: newAnnotationFromLongTouch.coordinate.longitude)
            print("Lat: \(newAnnotationFromLongTouch.coordinate.latitude), Long: \(newAnnotationFromLongTouch.coordinate.longitude)")
            //TODO: make sure the new pins' coordinates are saved.
            //TODO: add the pin to ann array of pins that will be saved in core data.
        }
        
    }
    
    func savePin(lat: CLLocationDegrees, long: CLLocationDegrees) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        let pin = NSManagedObject(entity: entity, insertInto: managedContext)
        pin.setValue(lat, forKeyPath: "latitude")
        pin.setValue(long, forKeyPath: "longitude")
        
        do {
            try managedContext.save()
            pins.append(pin)
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
  
    
    
}
