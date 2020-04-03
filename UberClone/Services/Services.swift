//
//  Services.swift
//  UberClone
//
//  Created by Juan Souza on 25/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("drivers")
let REF_TRIPS = DB_REF.child("trips")

struct Services {
    
    static let shared = Services()
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void){
        
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            let uid = snapshot.key            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let user = User.init(uid: uid, dictionary: dictionary)
            completion(user)
        }
        
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void){
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geoFire.query(at: location, withRadius: 100).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func uploadTrip(_ pickupCoordinate: CLLocationCoordinate2D, _ destinationCoordinate: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference)->Void){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let pickupArray = [pickupCoordinate.latitude, pickupCoordinate.longitude]
        let destitnationArray = [destinationCoordinate.latitude, destinationCoordinate.longitude]
        
        let values = ["pickupCoordinates": pickupArray, "destinationCoordinates": destitnationArray, "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    func observeTrips(completion: @escaping(Trip)->Void){
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
          
            let uid = snapshot.key
            let trip = Trip(passangerUid: uid, dictionary: dictionary)
            
            completion(trip)
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping(Error?,DatabaseReference)->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["driverUid": uid, "state": TripState.accepted.rawValue] as [String : Any]
        
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeCurrentTrip(completion: @escaping (Trip) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let trip = Trip(passangerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
}
