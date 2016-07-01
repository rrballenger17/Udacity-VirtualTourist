//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ryan Ballenger on 6/24/16.
//  Copyright © 2016 ios. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    convenience init(text: String = "New Pin", latitude: Double, longitude: Double, context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Pin",
            inManagedObjectContext: context){
                self.init(entity: ent, insertIntoManagedObjectContext: context)
                
                self.latitude = latitude
                
                self.longitude = longitude
                
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }


}
