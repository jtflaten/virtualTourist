//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/3/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    var pinPhotos: [Photo] = []
    var photoLink: [String] = []
    var pin = Pin()
    var coordinate = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let maxCellCount = 30
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        fetchPhotos(pin: pin)
        if pinPhotos == [] {
            downloadFirstPhotos()
            
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        layoutCells()
        showPinOnMap(pin)
        

      
       
    }
    
   
    

   
    func downloadFirstPhotos() {
        photoLink.removeAll()
        deleteAllPhotos(pin: self.pin)
        FlickrClient.sharedInstance().getPhotosForLocation(latitude: pin.latitude, longitude: pin.longitude) { (links, error) in
            guard (error == nil) else {
                print("there was an error downloading the photos")
                return
            }
            if let links = links {
                if links.count == 0 {
                    self.errorAlertView(errorMessage: "No images found at this location")
                }
                
               
                for link in links  {
                    if self.photoLink.count < self.maxCellCount {
                        self.photoLink.append(link)
                        self.makePhoto(link: link, pin: self.pin)
                    }
                    
                }
                
                
            }
            self.savePhotos()
            self.collectionView.reloadData()
        }
    }
    
    func downloadNewPhotos() {
        photoLink.removeAll()
        deleteAllPhotos(pin: self.pin)
        FlickrClient.sharedInstance().getNewPhotosForLocation(latitude: pin.latitude, longitude: pin.longitude, numOfPages: pin.numOfPages) { (links, error) in
            guard (error == nil) else {
                print("there was an error downloading the photos")
                return
            }
            if let links = links {
                if links.count == 0 {
                    self.errorAlertView(errorMessage: "No images found at this location")
                }
                
                
                for link in links  {
                    if self.photoLink.count < self.maxCellCount {
                        self.photoLink.append(link)
                        self.makePhoto(link: link, pin: self.pin)
                    }
                    
                }
                
                
            }
            self.savePhotos()
            self.collectionView.reloadData()
        }
    }

    
    func makePhoto(link: String, pin: Pin) {
      
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedContext)!
        let photo = Photo(entity: entity, insertInto: managedContext)
        photo.setValue(link, forKeyPath: "link")
        photo.setValue(pin, forKeyPath: "pin")
     
        pinPhotos.append(photo)
        pin.addToPhotos(photo)
    }
    
    func deleteAllPhotos(pin: Pin) {
        let managedContext = appDelegate.persistentContainer.viewContext
        for photo in pinPhotos {
            managedContext.delete(photo)
        }
      
        pinPhotos.removeAll()
        collectionView.reloadData()
        savePhotos()
    }
    
    func deleteThisOnePhoto(index: Int){
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(pinPhotos[index])
        savePhotos()
    }
    
    func savePhotos(){
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchPhotos(pin: Pin) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let photosFetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let predicate = NSPredicate(format: "pin = %@", self.pin)
        photosFetchRequest.predicate = predicate
        do {
            pinPhotos = try managedContext.fetch(photosFetchRequest)
        } catch let error as NSError {
            print("no Photos found: \(error), \(error.userInfo)")
            pinPhotos = []
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        downloadNewPhotos()
    }
    
    struct Constants {
        static let cellVerticalSpaicng: CGFloat = 2
    }
    
    func layoutCells() {
        var cellWidth: CGFloat
        var cellsInRow: CGFloat
        flowLayout.invalidateLayout()
        
        switch UIDevice.current.orientation {
        case .portrait:
            cellsInRow = 3
        case .portraitUpsideDown:
            cellsInRow = 3
        case .landscapeLeft:
            cellsInRow = 5
        case.landscapeRight:
            cellsInRow = 5
        default:
            cellsInRow = 5
        }
        cellWidth = collectionView!.frame.width / cellsInRow
        cellWidth -= Constants.cellVerticalSpaicng
        flowLayout.itemSize.width = cellWidth
        flowLayout.itemSize.height = cellWidth
        flowLayout.minimumInteritemSpacing = Constants.cellVerticalSpaicng
        //let actualVerticalSpacing: CGFloat = (collectionView!.frame.width - (cellsInRow * cellWidth))/(cellsInRow - 1)
        flowLayout.minimumLineSpacing = Constants.cellVerticalSpaicng //actualVerticalSpacing
        
    }

    func showPinOnMap(_ pin: Pin) {
        let lat = CLLocationDegrees(pin.latitude)
        let long = CLLocationDegrees(pin.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.mapView.centerCoordinate = coordinate
        let coordinateSpan = MKCoordinateSpanMake(0.65,0.65)
        let coordinateRegion = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
        self.mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(pinPhotos.count)
        
        return pinPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        cell.activityIndicator.startAnimating()
        cell.imageView.image = nil
        let photo = pinPhotos[indexPath.row]
        if photo.image != nil {
            cell.showPhoto(photo)
            
        } else {
            loadImage(photo: photo, cell: cell, indexPath: indexPath)
            
        }
        return cell
        
    }
    func loadImage(photo: Photo, cell: PhotoAlbumCollectionViewCell, indexPath: IndexPath) {
        
        
        FlickrClient.sharedInstance().downloadImage(imagePath: photo.link!) { imageData, error in
            guard (error == nil) else {
                print(error!)
                return
            }
            photo.setValue(imageData, forKeyPath: "image")
            performUIUpdatesOnMain {
                cell.showPhoto(self.pinPhotos[indexPath.row])
            }
            self.savePhotos()
        }
        
    }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            var itemsToDelete: [IndexPath] = []
            itemsToDelete.append(indexPath)
            
            
            self.deleteThisOnePhoto(index: (indexPath.row))
            pinPhotos.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: itemsToDelete)
            self.savePhotos()
            
        }
        
}
    
    
 
    



