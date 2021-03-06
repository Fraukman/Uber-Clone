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

//MARK: - DatabaseRefs

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("drivers")
let REF_TRIPS = DB_REF.child("trips")

//MARK: - DriverServices

struct DriverService{
    static let shared = DriverService()
    
    func observeTrips(completion: @escaping(Trip)->Void){
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            let uid = snapshot.key
            let trip = Trip(passangerUid: uid, dictionary: dictionary)
            
            completion(trip)
        }
    }
    
    func observeTripCancelled(trip: Trip, completion: @escaping ()->Void){
        REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
            completion()
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping(Error?,DatabaseReference)->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["driverUid": uid, "state": TripState.accepted.rawValue] as [String : Any]
        
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func updateTripState(trip: Trip, state: TripState, completion: @escaping(Error?,DatabaseReference)->Void){
        REF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        if state == .completed {
            REF_TRIPS.child(trip.passengerUid).removeAllObservers()
        }
    }
    
    func updateDriverLocation(location: CLLocation){
           guard let uid = Auth.auth().currentUser?.uid else {return}
           let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
           geofire.setLocation(location, forKey: uid)
       }
    
}

//MARK: - PassengerServices

struct PassengerServices{
    static let shared = PassengerServices()
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void){
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geoFire.query(at: location, withRadius: 100).observe(.keyEntered, with: { (uid, location) in
                Services.shared.fetchUserData(uid: uid) { user in
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
    
    func observeCurrentTrip(completion: @escaping (Trip) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let trip = Trip(passangerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
 
    func saveLocation(locationString: String, type: LocationType, completion: @escaping(Error?, DatabaseReference) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let key: String = type == .home ? "homeLocation" : "workLocation"
        REF_USERS.child(uid).child(key).setValue(locationString, withCompletionBlock: completion)
    }
    
}

//MARK: - SharedServices

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
    

    
    
}
