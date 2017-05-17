//
//  AlertViews.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/17/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func errorAlertView (errorMessage: String?) {
        let alert = UIAlertController(title: "Alert", message: errorMessage ?? "Something Went Wrong", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    

}
