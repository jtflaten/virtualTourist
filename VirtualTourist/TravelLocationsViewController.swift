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
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var pinToPass = Pin()
    
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travelLocationsMapView.delegate = self
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
     
        let managedContext = delegate.persistentContainer.viewContext
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
    
    func getPinFromAnnotationTap(lat: Double, long: Double) -> Pin {
        var pin: Pin?
        let managedContext = delegate.persistentContainer.viewContext
       //configure a FetchRequst for all the pins in core data
        let pinFetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
       //set descriptors and a predicate so that the returned array as only one object: the pin who's lat and long are the same as the annotation
        pinFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "latitude", ascending: true),
            NSSortDescriptor(key: "longitude", ascending: false)
        ]
        
        let predicate = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [lat,long])
        pinFetchRequest.predicate = predicate
        
        do
        {
            pin = try managedContext.fetch(pinFetchRequest)[0]
        } catch let error as NSError {
            print("could not get the pin\(error), \(error.userInfo)")
        }
        return pin!
    }
    
    func getPinSelect(latitude: Double, longitude: Double) -> Pin{
        var pin: Pin?
        let pins = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        pins.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                                NSSortDescriptor(key: "longitude", ascending: false)]
        
        let pred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitude, longitude])
        pins.predicate = pred
        
        
        // Create FetchedResultsController
        let fc = NSFetchedResultsController(fetchRequest: pins, managedObjectContext:self.delegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fc.performFetch()
            if((fc.fetchedObjects?.count)! > 0 ){
                pin = fc.fetchedObjects?[0] as? Pin
            }
            
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n")
        }
        
        return pin!
        
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

extension TravelLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    pinToPass = getPinFromAnnotationTap(lat: (view.annotation?.coordinate.latitude)!, long: (view.annotation?.coordinate.longitude)!)
    self.performSegue(withIdentifier: "showPhotoAlbum", sender: self)
    mapView.deselectAnnotation(view.annotation, animated: false)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoAlbumVC = segue.destination as! PhotoAlbumViewController
        photoAlbumVC.pin = pinToPass
    }

}
