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
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        collectionView.dataSource = self
        collectionView.delegate = self
        layoutCells()
      
       
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
    
    func makePhoto(link: String, pin: Pin) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedContext)!
        let photo = Photo(entity: entity, insertInto: managedContext)
        photo.setValue(link, forKeyPath: "link")
        photo.setValue(pin, forKeyPath: "pin")
        pinPhotos.append(photo)
        
    }

}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(pinPhotos.count)
        
        return pinPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
      
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView = nil
        let photo = pinPhotos[(indexPath as NSIndexPath).row]
        loadImage(photo: photo)
        
            performUIUpdatesOnMain {
                let image = UIImage(data: photo.image! as Data)
                cell.imageView?.image = image
                collectionView.reloadData()
            }
        
        return cell
    }
    
    
}


