//
//  Trip.swift
//  UberClone
//
//  Created by Juan Souza on 29/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import CoreLocation

struct Trip {
    var pickcupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passangerUid: String!
    var driverUid: String?
    var state: TripState!
    
    init(passangerUid: String, dictionary: [String: Any]) {
        self.passangerUid = passangerUid
        
        if let pickcupCoordinates = dictionary["pickupCoordinates"] as? NSArray{
            guard let lat = pickcupCoordinates[0] as? CLLocationDegrees else {return}
            guard let long = pickcupCoordinates[1] as? CLLocationDegrees else {return}
            self.pickcupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray{
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else {return}
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else {return}
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}

enum TripState: Int{
    case requested
    case accepted
    case inProgress
    case completed
}
