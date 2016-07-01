//
//  ViewController.swift
//  
//
//
//

import UIKit
import Foundation


class photosViewController: UIViewController {
    

    var toDelete: [Int]!
    
    var fDownload: FlickrDownload!
    
    var reuseIdentifier = "reuseidentifier"
    
    var latitude: Double!
    var longitude: Double!
    
    var pin: Pin!
    
    var keyboardOnScreen = false
    
    // delete old photos and initiate download of new photos
    @IBAction func newPictures(sender: AnyObject) {
        if pin.photo != nil{
            let generator = pin.photo?.generate()
            while(true){
                let temp = generator!.next()
                
                if temp == nil{
                    break
                }
                
                let picture = temp as! Photo
                
                stack.context.deleteObject(picture)
                
            }
        }
        
        imageSet = []
        photoSet = []
        
        fDownload.searchByLatLon(self, lat: latitude, long: longitude)
    
    }
    
    func performUIUpdatesOnMain(updates: () -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            updates()
        }
    }
    
    @IBOutlet weak var collection: UICollectionView!
    

    var photoSet: [Photo]!
    
    var numPhotos: Int = 15

    // display saved photos and initiate flickr download by location
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fDownload = FlickrDownload()
        fDownload.pController = self
        
        
        imageSet = []
        photoSet = []
        
        collection.delegate = self
        collection.dataSource = self

        
        
        // get stored photos if any
        let generator = pin.photo!.generate()
        
        if let first = generator.next(){
            
            imageSet.append(UIImage(data: first.data)!)
            photoSet.append(first as! Photo)
            
            var storedPhoto: Photo!
            
            while(true){
                let temp = generator.next()
                
                if temp == nil{
                    break
                }
                
                storedPhoto = temp as! Photo
                
                imageSet.append(UIImage(data: storedPhoto.data!)!)
                photoSet.append(storedPhoto as Photo)
                
            }
            
            numPhotos = photoSet.count
            
            return
        }
        
        // when downloading new photos, ensure 15 cells in the collection
        numPhotos = 15
        
        performUIUpdatesOnMain(){
            self.fDownload.searchByLatLon(self, lat: self.latitude, long: self.longitude)
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    var imageSet:[UIImage]!
    
    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack

    func saveChanges(){
        do{
            try stack.saveContext()
        }catch{
            print("Error while saving.")
        }
    }
    
    
    func saveImageData(image: UIImage) -> Photo{
        
        let jpeg:NSData! = UIImageJPEGRepresentation(image, 1.0)
        
        let newPhoto = Photo(data: jpeg, context: stack.context)
        
        
        if pin.photo != nil {
            pin.photo = pin.photo!.setByAddingObject(newPhoto)
        }else{
            pin.photo = NSSet(object: newPhoto)
        }
        
        return newPhoto
    }

}



extension photosViewController : UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return numPhotos
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //print("cellForItem")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        
        cell.backgroundColor = UIColor.blueColor()
        
        if(imageSet.count > indexPath.item){
            cell.myImage.image = imageSet[indexPath.item]
        }else{
            cell.myImage.image = nil
        }
        
        cell.myImage.userInteractionEnabled = false
        cell.userInteractionEnabled = true

        return cell
    }

    @IBAction func deletePhotos(sender: AnyObject) {
        if toDelete == nil {
            return
        }
        
        for index in toDelete{
            if(index < photoSet.count){
                stack.context.deleteObject(photoSet[index])
            }
            
        }
        
        toDelete = []
        
        saveChanges()
        
        viewDidLoad()
        
        collection.reloadData()
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        //print("You selected cell !")
        
        if(toDelete == nil){
            toDelete = []
        }
        
        if(!toDelete.contains(indexPath.item)){
            toDelete.append(indexPath.item)
        }
        
        collection.cellForItemAtIndexPath(indexPath)!.alpha = 0.5
        
    }
    
}








