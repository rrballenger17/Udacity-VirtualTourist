//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ryan Ballenger on 6/24/16.
//  Copyright © 2016 ios. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    convenience init(text: String = "New Photo", data: NSData, context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Photo",
            inManagedObjectContext: context){
                self.init(entity: ent, insertIntoManagedObjectContext: context)
                
                self.data = data
                
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }

}
