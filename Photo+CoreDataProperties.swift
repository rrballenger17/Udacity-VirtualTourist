//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ryan Ballenger on 6/24/16.
//  Copyright © 2016 ios. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var data: NSData?
    @NSManaged var pin: Pin?

}
