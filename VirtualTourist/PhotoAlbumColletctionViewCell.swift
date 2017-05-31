//
//  PhotoAlbumColletctionViewCell.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/11/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    func showPhoto(_ photo: Photo) {
        self.activityIndicator.hidesWhenStopped = true
        if photo.image != nil {
            performUIUpdatesOnMain {
                self.imageView.image = UIImage(data: photo.image! as Data)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    

    
}
