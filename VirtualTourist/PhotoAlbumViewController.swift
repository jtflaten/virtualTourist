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
    var pin = Pin()
    var coordinate = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let maxCellCount = 30
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        collectionView.dataSource = self
        collectionView.delegate = self
        layoutCells()
        showPinOnMap(pin)
        fetchPhotos(pin: pin)
        if pinPhotos == [] {
            downloadNewestPhotos()
        }
      
       
    }
    
   
    
    func loadImage(photo: Photo) {
        
        
            let imageURL = URL(string: photo.link!)
        
            if let imageData = try? Data(contentsOf: imageURL!) {
                let image = UIImage(data: imageData)
                guard let imageNSData = UIImageJPEGRepresentation(image!, 1) else {
                    print("error converting Jpeg")
                    return
                }
                photo.setValue(imageNSData, forKeyPath: "image")
           
            }
        
    }
   
    func downloadNewestPhotos() {
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
                
                for link in links {
                   
                        self.makePhoto(link: link, pin: self.pin)
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
        downloadNewestPhotos()
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
        //let activityIndicator = UIActivityIndicatorView
        cell.imageView.image = nil
        
        
        let photo = pinPhotos[indexPath.row]
        loadImage(photo: photo)
        cell.showPhoto(photo)
        return cell
        
        
    }
    
    
 
    
}


