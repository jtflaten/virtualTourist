//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/11/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit

struct FlickrConstants{
    
   
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
  
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Radius = "radius"
        static let Longitude = "lon"
        static let Latitude = "lat"
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos" // may not be needed
        static let APIKey = "56bd90336cc752a9db224fae1d408588"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let MaxPerPage = "30"
        static let Radius = "5"
    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}
