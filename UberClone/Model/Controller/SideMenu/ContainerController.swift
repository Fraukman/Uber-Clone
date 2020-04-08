//
//  ContainerController.swift
//  UberClone
//
//  Created by Juan Souza on 08/04/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit
import Firebase

class ContainerController: UIViewController{
    //MARK: - Properties
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
    
    private var user : User? {
        didSet{
            guard let user = user else {return}
            homeController.user = user
            configureMenuController(withUser: user)
            
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLogged()

    }
    
    override var prefersStatusBarHidden: Bool{
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }

    //MARK: - API
    
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
    
    func fetchUserData(){
        guard let currentuid = Auth.auth().currentUser?.uid else {return}
        Services.shared.fetchUserData(uid: currentuid) { user in
            self.user = user
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
    
    //MARK: - Helper functions
    
    func configure(){
        view.backgroundColor = .backgroundColor
        configureHomeController()
        fetchUserData()
    }
    
    func configureHomeController(){
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
        homeController.user = user
    }
    
    func configureMenuController(withUser user: User){
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        configureBlacView()
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool)->Void)? = nil){
        let xOrigin = self.view.frame.width - 80
        if shouldExpand{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = xOrigin
                self.blackView.alpha = 1
                self.blackView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
            }, completion: nil)
        }else{
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.blackView.alpha = 0
                self.homeController.view.frame.origin.x = 0
            }, completion: nil)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func configureBlacView(){
        blackView.frame = self.view.bounds
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    //MARK: - Selectors
    
    @objc func dismissMenu(){
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
}

//MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate{
    func handleMenuToggle() {
        isExpanded = !isExpanded
        animateMenu(shouldExpand: isExpanded)
    }
}

//MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate{
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                break
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                    self.singOut()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
