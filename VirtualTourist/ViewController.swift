//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Ryan Ballenger on 6/24/16.
//  Copyright © 2016 ios. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate{

    var editMode:Bool = false
    
    
    @IBOutlet weak var eButton: UIButton!
    
    // toggle the edit button
    @IBAction func editButton(sender: AnyObject) {
        if(editMode == false){
            editMode = true
            dispatch_async(dispatch_get_main_queue(), {
                self.eButton.backgroundColor = UIColor.redColor()
                self.eButton.setTitle("Cancel", forState: .Normal)
            });

        }else{
            editMode = false
            dispatch_async(dispatch_get_main_queue(), {
                self.eButton.backgroundColor = UIColor.whiteColor()
                self.eButton.setTitle("Edit", forState: .Normal)
            });
        }
    
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
 
        // set up gesture recognizer to add pin to map
        var addPin = UILongPressGestureRecognizer(target: self, action: "handlePress:")
        addPin.minimumPressDuration = 1.0
        map.addGestureRecognizer(addPin)
        
        getSavedPins()
    }
    
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            fetchedResultsController?.delegate = self
            doSearch()
        }
    }
    
    // fetch the saved pins, add them to the map, and store them in newPins
    func getSavedPins(){

        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
            managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        var pins = fetchedResultsController?.fetchedObjects as! [Pin]
        
        newPins = []
        for p in pins{
            newPins.append(p)
            
            let ann = MKPointAnnotation()
            ann.coordinate = CLLocationCoordinate2D(latitude: (p.latitude as! Double), longitude: (p.longitude as! Double))
        
            map.addAnnotation(ann)
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func saveContext(){
        
        do{
            try stack.saveContext()
        }catch{
            print("Error while saving.")
        }
    }
    
    // delete the pin in edit mode and otherwise show the associated photos
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    
        if(editMode){
            
            for newPin in newPins{
                if(newPin.latitude == view.annotation?.coordinate.latitude){
                    
                    stack.context.deleteObject(newPin)
                    
                    saveContext()
                   
                    map.removeAnnotation(view.annotation!)

                    return
                }
            }
            
            
        }
        
        //print("selected!!!")
        //print(view.annotation?.coordinate.latitude)
        
        let newView = self.storyboard?.instantiateViewControllerWithIdentifier("FlickR") as? photosViewController

        newView?.latitude = view.annotation?.coordinate.latitude
        newView?.longitude = view.annotation?.coordinate.longitude
        
        
        for newPin in newPins{
            if(newPin.latitude == view.annotation?.coordinate.latitude){
                newView?.pin = newPin
            }
            
        }
        
        mapView.deselectAnnotation(view.annotation, animated: false)

        self.navigationController?.pushViewController(newView!, animated: true)

    }
    
    
    @IBOutlet weak var map: MKMapView!
    
    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack

    
    var newPins: [Pin]!
    
    // add a new pin to the map when a press occurs
    func handlePress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began {
            return
        }
        
        let point = getstureRecognizer.locationInView(self.map)
        let mapSpot = map.convertPoint(point, toCoordinateFromView: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapSpot
        map.addAnnotation(annotation)
        
        if(newPins == nil){
            newPins = []
        }
        
        newPins.append(Pin(latitude: mapSpot.latitude, longitude: mapSpot.longitude, context: stack.context))

        saveContext()
        
        //print(mapSpot.latitude)
        //print(mapSpot.longitude)
    }

}

extension ViewController{
    
    func doSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

