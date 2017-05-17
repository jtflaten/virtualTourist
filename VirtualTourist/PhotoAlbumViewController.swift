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

class PhotoAlbumViewController: UIViewController {
    var pinPhotos: [Photo] = []
    var pin = Pin()
    var coordinate = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let maxCellCount = 30
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        collectionView.dataSource = self
        collectionView.delegate = self
        layoutCells()
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
        deletePhotos(pin: self.pin)
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
                    while self.pinPhotos.count < self.maxCellCount {
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
    
    func deletePhotos(pin: Pin) {
        let managedContext = appDelegate.persistentContainer.viewContext
        for photo in pinPhotos {
            managedContext.delete(photo)
        }
        pinPhotos.removeAll()
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
        let actualVerticalSpacing: CGFloat = (collectionView!.frame.width - (cellsInRow * cellWidth))/(cellsInRow - 1)
        flowLayout.minimumLineSpacing = actualVerticalSpacing
        
    }

    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(pinPhotos.count)
        
        return pinPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
      
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
       // let activityIndicator = UIActivityIndicatorView
        cell.imageView.image = nil
        
        
        let photo = pinPhotos[(indexPath as NSIndexPath).row]
        loadImage(photo: photo)
        
            performUIUpdatesOnMain {
                if let image = UIImage(data: photo.image! as Data) {
                cell.imageView!.image = image
                collectionView.reloadData()
                }
            }
        return cell
    }
    
    
}


