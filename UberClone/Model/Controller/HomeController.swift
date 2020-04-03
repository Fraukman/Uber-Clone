//
//  HomeController.swift
//  UberClone
//
//  Created by Juan Souza on 24/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit
import Firebase
import MapKit
  
private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let riderActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private final let riderActionViewHeight: CGFloat = 300

    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivateView()
                observeCurrentTrip()
            }else {
                observeTrips()
            }
        }
    }
    
    private var trip: Trip?{
        didSet{
            guard let user = user else {return}
            if user.accountType == .driver{
                guard let trip = trip else {return}
                let controller = PickupController(trip: trip)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }else{
                print("DEBUG: Show ride action view for accepted trip")
            }
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        
        button.addTarget(self, action: #selector(actionPressed), for: .touchUpInside)
        return button
    }()

    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLogged()
        enableLocationServices()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let trip = trip else {return}
        
        print("DEBUG: Trip state is \(trip.state)")
    }
    
    //MARK: - Selectors
    
    @objc func actionPressed(){
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: handle show menu...")
        case .dismissActionView:
           
            removeAnnotationAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)

            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.AnimateRideActionView(shouldShow: false)
            }
            
        }
        
    }
    
    //MARK: - API
    
    func observeCurrentTrip(){
        Services.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            
            if trip.state == .accepted{
                self.shouldPresentLoadingView(false)
                guard let driverUid = trip.driverUid else {return}
                
                Services.shared.fetchUserData(uid: driverUid) { driver in
                    self.AnimateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
                
                
                
            }
        }
    }
    
    func fetchUserData(){
        guard let currentuid = Auth.auth().currentUser?.uid else {return}
        Services.shared.fetchUserData(uid: currentuid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers(){
        guard let location = locationManager?.location else {return}
        Services.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    if driverAnno.uid == driver.uid{
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
                
               
            }
            if !driverIsVisible{
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
    func observeTrips(){
        Services.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func checkIfUserIsLogged(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                
            }
        }else {
            configure()
        }
    }

    func singOut(){
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                
            }
        }catch{
            print("DEBUG: Error singing out")
        }
    }
    
    //MARK: - HelpFunctions
    
    func configure(){
        configureUI()
        configureRideActionView()
        fetchUserData()
        
    }
    
    func configureActionButton(config: ActionButtonConfiguration){
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .dismissActionView
        }
    }
    
    func configureUI(){
        configureMapView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 30, height: 30)
        
        
        
        
        configureTableView()
    }
    
    func configureLocationInputActivateView(){
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2){
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView(){
        
        mapView.delegate = self
        
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
    }
    
    func configureLocationinputView(){
        
        locationInputView.delegate = self
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
            
        }
    }
    
    func configureRideActionView(){
        view.addSubview(riderActionView)
        riderActionView.delegate = self
        riderActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: riderActionViewHeight)
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationInputCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool)->Void)? = nil){
        
        UIView.animate(withDuration: 0.4, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
           
        }, completion: completion)
    }
    
    func AnimateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideactionViewConfiguration? = nil, user: User? = nil ){
        
        let yOrigin = shouldShow ? self.view.frame.height - self.riderActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.riderActionView.frame.origin.y = yOrigin
        }
        
        
        if shouldShow {
            guard let config = config else {return}
            
            if let destination = destination {
            riderActionView.destination = destination
            }
            
            if let user = user {
                riderActionView.user = user
            }
            
            riderActionView.configureUI(withconfig: config)

        }
        
        
    }
    
}

//MARK: - Map helper Functions

private extension HomeController{
    func searchBy(naturalLanguageQuery: String,completion: @escaping([MKPlacemark])->Void){
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {return}
            
            response.mapItems.forEach { (item) in
                results.append(item.placemark)
            }
            
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem){
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
        }
        
    }
    
    func removeAnnotationAndOverlays(){
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation{
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}


//MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route{
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
}

//MARK: - LocationServices

extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices(){
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        case .authorizedAlways:
            print("DEBUG: xx")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()

        @unknown default:
            break
        }
    }
 
}

//MARK: - LocationInputViewDelegate

extension HomeController: LocationInputActivationViewDelegate{
    
    func excuteSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
        
    }
    
    func presentLocationInputView(){
        inputActivationView.alpha = 0
        configureLocationinputView()
        
    }
}

extension HomeController: LocationInputViewDelegate{
    func dismissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.4) {
                self.inputActivationView.alpha = 1
                
            }
        }
    }
}

//MARK: - UITableViewDelegate/DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : searchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationInputCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaceMark = searchResults[indexPath.row]
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlaceMark)
        
        generatePolyline(toDestination: destination)
        
        dismissLocationView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlaceMark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            let annotations = self.mapView.annotations.filter({!$0.isKind(of: DriverAnnotation.self)})
            
            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            
            self.AnimateRideActionView(shouldShow: true, destination: selectedPlaceMark, config: .requestRide)
            
        }
        
    }
    
}

//MARK: - RideActionViewDelegate

extension HomeController: RideActionViewdDelegate{
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else {return}
        guard let destinationCoordinates = view.destination?.coordinate else {return}
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        Services.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let error = error {
                print ("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            

            UIView.animate(withDuration: 0.3) {
                self.riderActionView.frame.origin.y = self.view.frame.height
            }
            
        }
    }
    
}

//MARK: - PickupControllerDelegate

extension HomeController: PickupControllerDelegate{
    func didAcceptTrip(_ trip: Trip) {

        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickcupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        let placemark = MKPlacemark(coordinate: trip.pickcupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        
        self.dismiss(animated: true) {
            Services.shared.fetchUserData(uid: trip.passengerUid) { (passenger) in
                self.AnimateRideActionView(shouldShow: true, config: .tripAccepted,user: passenger)

            }
            
        }
    }
    
    
}
