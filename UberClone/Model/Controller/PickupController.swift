//
//  PickupController.swift
//  UberClone
//
//  Created by Juan Souza on 30/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: PickupControllerDelegate?
    private let mapView = MKMapView()
    let trip: Trip
    
    private lazy var circularProgressView: CircularProgresView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgresView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
       let label = UILabel()
        label.text = "would you like to pickup this passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("ACCEPT TRIP", for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(trip: Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureUI()
        configureMapView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //MARK: - Selectors
    
    @objc func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip(){
        DriverService.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    @objc func animateProgress(){
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 5, value: 0) {
//            self.dismiss(animated: true, completion: nil)
        }
        
    
    }
    
    //MARK: - API
    
    
    //MARK: - HelperFunctions
    
    func configureMapView(){

        let region = MKCoordinateRegion(center: trip.pickcupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)

        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(forCoordinates: trip.pickcupCoordinates)
    }
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 80)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
}
