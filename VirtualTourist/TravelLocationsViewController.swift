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
    
    var pins: [Pin] = []
    
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // USER INTERACTION
        travelLocationsMapView.isUserInteractionEnabled = true
        let addPinGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.addPin))
        addPinGestureRecognizer.minimumPressDuration = 2.5
        self.travelLocationsMapView.addGestureRecognizer(addPinGestureRecognizer)
        
        //Populate the map
        fetchPins()
        putFetchedPinsOnMap(pins: pins)
        
        
    }
    
    //fetch request for pins from core data
    func fetchPins() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let pinFetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        do {
            pins =  try managedContext.fetch(pinFetchRequest)
        } catch let error as NSError {
                print("could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func putFetchedPinsOnMap(pins: [Pin]) {
        var mapAnnotations = [MKPointAnnotation]()
        
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            mapAnnotations.append(annotation)
        }
        performUIUpdatesOnMain {
            self.travelLocationsMapView.addAnnotations(mapAnnotations)
        }
    }
    
    //this func with the addPin Geture recognizer
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchedPoint = gestureRecognizer.location(in: travelLocationsMapView)
            let coordinatesFromTouchPoint = travelLocationsMapView.convert(touchedPoint, toCoordinateFrom: travelLocationsMapView)
            let newAnnotationFromLongTouch = MKPointAnnotation()
            newAnnotationFromLongTouch.coordinate = coordinatesFromTouchPoint
            travelLocationsMapView.addAnnotation(newAnnotationFromLongTouch)
            savePin(lat: newAnnotationFromLongTouch.coordinate.latitude, long: newAnnotationFromLongTouch.coordinate.longitude)
            print("Lat: \(newAnnotationFromLongTouch.coordinate.latitude), Long: \(newAnnotationFromLongTouch.coordinate.longitude)")
     
           
        }
        
    }
    
    func savePin(lat: CLLocationDegrees, long: CLLocationDegrees) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        let pin = Pin(entity: entity, insertInto: managedContext) //NSManagedObject(entity: entity, insertInto: managedContext)
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
