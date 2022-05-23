//
//  ViewController.swift
//  AirpodsProAcc
//
//  Created by Ahmed Abaza on 02/04/2022.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    //MARK: - Properties
    let headphoneManager = HeadPhoneManager.shared
    
    let cameraController = CameraController.init()
    
    private var connectionFlag: UIColor {
        self.headphoneManager.connectionStatus ? .green : .red
    }
    
    
    //MARK: - IB Outlets
    @IBOutlet private weak var displayView: UIView! {
        didSet {
            displayView.clipsToBounds = true
            displayView.layer.cornerRadius = displayView.bounds.width / 2.0
            displayView.layer.borderWidth = 2.0
            displayView.layer.borderColor = UIColor.label.cgColor
        }
    }
    
    
    @IBOutlet weak var pointerViewZ: UIImageView!
    
    @IBOutlet weak var pointerViewX: UIImageView! {didSet {pointerViewX.transform = CGAffineTransform.init(rotationAngle: .pi/2)}}
    
    @IBOutlet weak var xRuler: RulerView! {
        didSet {
            xRuler.transform = .init(rotationAngle: .pi)
        }
    }
    
    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureCameraController()
    }
}


//MARK: - Functions
extension ViewController {
    private func configure() -> Void {
        
        
        self.headphoneManager.delegate = self
        self.headphoneManager.read()
    }
    
    private func configureCameraController() -> Void {
        self.cameraController.prepare { [weak self] error in
            
            guard error == nil, let self = self else { return }
            
            self.cameraController.displayPreview(in: self.displayView)
        }
    }
}



extension ViewController: HeadphoneManagerDelegate {
    func headphoneManager(_ manager: CMHeadphoneMotionManager, didRead userInfo: [MotionInfo : Double]) {
        guard let rotationZ = userInfo[.rotationZ], let rotationX = userInfo[.rotationX] else { return }

        let offsetZ = Double(rotationZ * self.view.bounds.size.width) / 100
        let offsetX = Double(rotationX * self.xRuler.bounds.size.height) / 100
        
        if (self.pointerViewZ.center.x + offsetZ >= .zero && self.pointerViewZ.center.x + offsetZ <= self.view.bounds.width) {
            self.pointerViewZ.center.x += offsetZ
        }
        
        if (self.pointerViewX.center.y + offsetX >= .zero && self.pointerViewX.center.y + offsetX <= xRuler.frame.maxY) {
            self.pointerViewX.center.y += offsetX
        }
        
    }
    
    func headphoneManager(_ manager: CMHeadphoneMotionManager, didUpdate connectionStatus: Bool) {
        self.connectionStatusLabel.text = connectionStatus ? "Connectected" : "Disconnected"
        self.connectionStatusLabel.textColor = connectionStatus ? UIColor.systemGreen : UIColor.systemRed
    }
}
