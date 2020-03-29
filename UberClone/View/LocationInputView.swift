//
//  LocationInputView.swift
//  UberClone
//
//  Created by Juan Souza on 24/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismissLocationInputView()
    func excuteSearch(query: String)
}

class LocationInputView: UIView {

    //MARK: - Properties
    
    weak var delegate: LocationInputViewDelegate?
    
    var user: User? {
        didSet { titleLabel.text = user?.fullname}
    }
    
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let LinkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextfield: UITextField = {
        UITextField().locationTextField(withPlaceHolder: "Current Location", isEnabled: false, color: .groupTableViewBackground)
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField().locationTextField(withPlaceHolder: "Enter a destination", isEnabled: true, color: .lightGray)
        tf.delegate = self
        return tf
        
    }()
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLocationInputUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - HelpFunctions
    
    func configureLocationInputUI(){
        backgroundColor = .white
        
        addShadow()
        addSubview(backButton)
        
        backButton.anchor(top: topAnchor, left: leftAnchor,paddingTop: 44, paddingLeft: 12, width: 24, height: 25)
        
        addSubview(titleLabel)
        
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextfield)
        
        startingLocationTextfield.anchor(top:backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top:startingLocationTextfield.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextfield, leftAncor: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationLocationTextField, leftAncor: leftAnchor, paddingLeft: 20)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        destinationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(LinkingView)
        LinkingView.centerX(inView: startLocationIndicatorView)
        LinkingView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor,paddingTop: 4,paddingBottom: 4, width: 0.5)
        
    }
    
    //MARK: - Selectors
    
    @objc func handleBackTapped(){
        delegate?.dismissLocationInputView()
    }
    
}

//MARK: - UITextFieldDelegate

extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else {return false}
        delegate?.excuteSearch(query: query)
        return true
    }
}
