//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/11/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrClient: NSObject {
    var session = URLSession.shared
    var photoLinkArray = [String] ()
    var numOfPages: Int32 = 1
    
    // Network call to flickr API, getting a set of photos for a collection view
    func taskForGETMethod(_ parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        var methodParameters = parameters
        
        let request = NSMutableURLRequest(url: buildURLFromParameters(methodParameters as [String:AnyObject]))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            /* Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        print(request)
        task.resume()
        return task
    }
    
    func getPhotosForLocation(latitude: Double, longitude: Double, completionHandllerForGetPhotos: @escaping (_ result: [String]?, _ error: NSError?) -> Void) {
        self.photoLinkArray.removeAll()
        let methodParameters = [
            FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BoundingBox: bboxStringFromMap(lat: latitude, long: longitude),
            FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
            FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
            FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.MaxPerPage,
            FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback
        ] as [String : Any]
        
        let _ = taskForGETMethod(methodParameters as [String: AnyObject]) { (results, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandllerForGetPhotos(nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            guard (error == nil) else {
                sendError("there was a error in the request")
                return
            }
            guard (results != nil) else {
                sendError( "no response")
                return
            }
            
            guard let photosDict = results?[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject]? else {
                sendError("no photos found")
                return
            }
            
            guard let numberOfPages = photosDict?[FlickrConstants.ResponseKeys.Pages] as? Int32 else {
                sendError("couldn't get number of pages")
                return
            }
            self.numOfPages = numberOfPages
            guard let photoArray = photosDict?[FlickrConstants.ResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError("couldn't get photo array")
                return
            }
           
            for eachPhotoDict in photoArray {
                let photoLink = eachPhotoDict[FlickrConstants.ResponseKeys.MediumURL] as! String
                self.photoLinkArray.append(photoLink)
                
                
            }
            performUIUpdatesOnMain {
                let links = self.photoLinkArray
               print(results)
                completionHandllerForGetPhotos(links, nil)

               
            }
        
          
        }
    }
    
    func randomPageString (_ numOfPages: Int32) -> String {
        var randomNum = ""
        if numOfPages < 100 {
            randomNum = "\(arc4random_uniform(UInt32(numOfPages)))"
        } else {
            randomNum = "\(arc4random_uniform(UInt32(100)))"
        }
            return randomNum
        
    }
    
    func getPagesForLocation(latitude: Double, longitude: Double, completionHandllerForGetPages: @escaping (_ result: Int32?, _ error: NSError?) -> Void) {
        self.photoLinkArray.removeAll()
        let methodParameters = [
            FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BoundingBox: bboxStringFromMap(lat: latitude, long: longitude),
            FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
            FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
            FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.MaxPerPage,
            FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback
        ] as [String : Any]
        
        let _ = taskForGETMethod(methodParameters as [String: AnyObject]) { (results, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandllerForGetPages(nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            guard (error == nil) else {
                sendError("there was a error in the request")
                return
            }
            guard (results != nil) else {
                sendError( "no response")
                return
            }
            
            guard let photosDict = results?[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject]? else {
                sendError("no photos found")
                return
            }
            
            guard let numberOfPages = photosDict?[FlickrConstants.ResponseKeys.Pages] as? Int32 else {
                sendError("couldn't get number of pages")
                return
            }
            self.numOfPages = numberOfPages
            performUIUpdatesOnMain {
                let pages = self.numOfPages
                completionHandllerForGetPages(pages, nil)
            }
        }
    }
    
    func getNewPhotosForLocation(latitude: Double, longitude: Double, numOfPages: Int32, completionHandllerForGetPhotos: @escaping (_ result: [String]?, _ error: NSError?) -> Void) {
        self.photoLinkArray.removeAll()
        let randomNum = randomPageString(numOfPages)
        let methodParameters = [
            FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BoundingBox: bboxStringFromMap(lat: latitude, long: longitude),
            FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
            FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
            FlickrConstants.ParameterKeys.Page: randomNum,
            FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.MaxPerPage,
            FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback
        ] as [String : Any]
        print(randomPageString(420))
        print(randomPageString(69))
        
        let _ = taskForGETMethod(methodParameters as [String: AnyObject]) { (results, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandllerForGetPhotos(nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("there was a error in the request")
                return
            }
            guard (results != nil) else {
                sendError( "no response")
                return
            }
            
            guard let photosDict = results?[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject]? else {
                sendError("no photos found")
                return
            }
            
          //  guard let numberOfPages = photosDict?[FlickrConstants.ResponseKeys.Pages] as? Int else {
//                sendError("couldn't get number of pages")
//                return
//            }
//            self.numOfPages = numberOfPages
            guard let photoArray = photosDict?[FlickrConstants.ResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError("couldn't get photo array")
                return
            }
            
            for eachPhotoDict in photoArray {
                let photoLink = eachPhotoDict[FlickrConstants.ResponseKeys.MediumURL] as! String
                self.photoLinkArray.append(photoLink)
                
                
            }
            performUIUpdatesOnMain {
                let links = self.photoLinkArray
            //    print(results)
                completionHandllerForGetPhotos(links, nil)
                
                
            }
            
            
        }
    }
    func downloadImage(imagePath: String, comletionHandler: @escaping(_ imageData: Data?,_ errorString: String? ) -> Void) {
        let session = URLSession.shared
        let imageURL = NSURL(string: imagePath)
        let request = NSURLRequest(url: imageURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                comletionHandler(nil, "could not download image \(imagePath)")
            } else {
                performUIUpdatesOnMain {
                    comletionHandler(data, nil)
                }
            }
        }
        task.resume()
    }
    
    // MARK: Utilities
    func buildURLFromParameters(_ parameters:[String:AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = FlickrConstants.APIScheme
        components.host = FlickrConstants.APIHost
        components.path = FlickrConstants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    func bboxStringFromMap(lat: Double, long: Double) -> String {
        let minimumLon = max(long - FlickrConstants.SearchBBoxHalfWidth, FlickrConstants.SearchLonRange.0)
        let minimumLat = max(lat - FlickrConstants.SearchBBoxHalfHeight, FlickrConstants.SearchLatRange.0)
        let maximumLon = min(long + FlickrConstants.SearchBBoxHalfWidth, FlickrConstants.SearchLonRange.1)
        let maximumLat = min(lat + FlickrConstants.SearchBBoxHalfHeight, FlickrConstants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
   
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    class func sharedInstance() -> FlickrClient{
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    

    
}
