//
//  SingUpController.swift
//  UberClone
//
//  Created by Juan Souza on 24/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SingUpController: UIViewController{
    
    //MARK: - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var nameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: nameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
        tf.autocapitalizationType = .words
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let segmentController: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider","Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let singUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sing Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSingUp), for: .touchUpInside)
        return button
    }()
    
    private let HaveAcountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTittle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        
        attributedTittle.append(NSMutableAttributedString(string: "Sing In", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowsSingIn), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTittle, for: .normal)
        return button
    }()
    
    
    
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        print("DEBUG: Location is \(location)")
        
    }
    
    //MARK: - HelpFunctions
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(nameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(singUpButton)
        view.addSubview(segmentController)
        
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,nameContainerView,passwordContainerView,segmentController,singUpButton])
        
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        view.addSubview(stack)
        
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40,paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(HaveAcountButton)
        
        HaveAcountButton.centerX(inView: view)
        HaveAcountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]){
        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else {return}
            controller.configure()
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    //MARK: - Selectors
    
    @objc func handleShowsSingIn(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSingUp(){
        view.endEditing(true)
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullName = nameTextField.text else {return}
        let accountTypeIndex = segmentController.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let e = error {
                print("Fail to register user with error: \(e.localizedDescription)")
                return
            }else {
                let values = ["email" : email, "fullname": fullName, "password" : password, "accountType": accountTypeIndex] as [String : Any]
                
                guard let uid = authResult?.user.uid else {return}
                
                if accountTypeIndex == 1 {
                    let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                    
                    if let location = self.location{
                        geofire.setLocation(location, forKey: uid) { error in
                            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                        }
                    }
                    
                    
                }

                self.uploadUserDataAndShowHomeController(uid: uid, values: values)
     
            }
        }
    }
}
