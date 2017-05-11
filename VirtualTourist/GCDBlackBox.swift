//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Jake Flaten on 5/10/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
