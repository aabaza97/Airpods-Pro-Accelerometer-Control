//
//  AccelerometerManager.swift
//  AirpodsProAcc
//
//  Created by Ahmed Abaza on 02/04/2022.
//

import Foundation
import CoreMotion

class HeadPhoneManager: NSObject, CMHeadphoneMotionManagerDelegate {
    
    static private(set) var shared: HeadPhoneManager = .init()
    
    private let motionManager: CMHeadphoneMotionManager = .init()
    
    private(set) var roll: Double = .zero
    
    private(set) var pitch: Double = .zero
    
    private(set) var yaw: Double = .zero
    
    private(set) var rotationRate: CMRotationRate = .init()
    
    private(set) var acceleration: CMAcceleration = .init()
    
    private(set) var gravity: CMAcceleration = .init()
    
    private(set) var connectionStatus: Bool = false {
        didSet {
            self.delegate?.headphoneManager(self.motionManager, didUpdate: self.connectionStatus)
        }
    }
    
    weak var delegate: HeadphoneManagerDelegate? = nil
    
    private override init() {}
    
    
    private func degrees(_ rad: Double) -> Double { 180 / .pi * rad }
    
}


extension HeadPhoneManager {
    func read() -> Void {
        guard let operationQueue = OperationQueue.current else { return }
        
        self.motionManager.startDeviceMotionUpdates(to: operationQueue) { [weak self ] deviceMotion, error in
            guard let deviceMotion = deviceMotion, error == nil else { return }
            
            let attitude = deviceMotion.attitude
            self?.roll = self?.degrees(attitude.roll) ?? .zero
            self?.pitch = self?.degrees(attitude.pitch) ?? .zero
            self?.yaw = self?.degrees(attitude.yaw) ?? .zero
            
            self?.rotationRate = deviceMotion.rotationRate
            self?.acceleration = deviceMotion.userAcceleration
            self?.gravity = deviceMotion.gravity
            
            guard let self = self else { return }
            
            self.connectionStatus = self.motionManager.isDeviceMotionAvailable
            
            let userInfo: [MotionInfo: Double] = [
                .roll: self.roll,
                .pitch: self.pitch,
                .yaw: self.yaw,
                .rotationX: deviceMotion.rotationRate.x,
                .rotationY: deviceMotion.rotationRate.y,
                .rotationZ: deviceMotion.rotationRate.z
            ]
            self.delegate?.headphoneManager(self.motionManager, didRead: userInfo)
        }
    }
    
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        self.connectionStatus = true
    }
    
    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        self.connectionStatus = false
    }
    
    
}


//MARK: - Associated Protocols

protocol HeadphoneManagerDelegate: AnyObject {
    func headphoneManager(_ manager: CMHeadphoneMotionManager, didRead userInfo: [MotionInfo: Double])
    func headphoneManager(_ manager: CMHeadphoneMotionManager, didUpdate connectionStatus: Bool)
}



enum MotionInfo: Int {
    case roll
    case pitch
    case yaw
    case rotationX
    case rotationY
    case rotationZ
//    case acceleration
//    case gravity
}
