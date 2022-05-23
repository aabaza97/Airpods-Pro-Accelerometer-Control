//
//  RulerView.swift
//  AirpodsProAcc
//
//  Created by Ahmed Abaza on 23/05/2022.
//

import Foundation
import UIKit

@IBDesignable
class RulerView: UIView {
    
    @IBInspectable var isVertical: Bool = false

    
    override func draw(_ rect: CGRect) {
        let containerRect = UIBezierPath.init(
            roundedRect: rect,
            byRoundingCorners: [.allCorners],
            cornerRadii: .init(width: 10.0, height: 10.0)
        )
        
        containerRect.addClip()
        
        // each 5 steps -> draw half line
        // each 10 steps -> draw line
        // each step -> draw small line
        
        let rulerGrades = isVertical ? drawRulerVertical(in: rect) : drawRuler(in: rect)
        
        UIColor.label.setStroke()
        
        rulerGrades.lineWidth = 0.8
        containerRect.lineWidth = 1.5
        
        rulerGrades.stroke()
        containerRect.stroke()
    }
    
    
    private func drawRuler(in rect: CGRect) -> UIBezierPath {
        let rulerGrades = UIBezierPath.init()
        let sectionStep = 10.0
        let halfSectionStep = sectionStep / 2
        let step = halfSectionStep - 1
        for sectionStepper in stride(from: .zero, to: rect.width, by: sectionStep) {
            let drawPoint = CGPoint.init(x: sectionStepper, y: rect.minY)
            let endPoint = CGPoint.init(x: sectionStepper, y: rect.height * 0.7)
            rulerGrades.move(to: drawPoint)
            rulerGrades.addLine(to: endPoint)
            for halfStepper in stride(from: sectionStepper, to: sectionStepper + sectionStep, by: halfSectionStep) {
                for stpper in stride(from: halfStepper, to: halfStepper + halfSectionStep, by: step) {
                    let drawPoint = CGPoint.init(x: stpper, y: rect.minY)
                    let endPoint = CGPoint.init(x: stpper, y: rect.height * 0.2)
                    rulerGrades.move(to: drawPoint)
                    rulerGrades.addLine(to: endPoint)
                }
                let drawPoint = CGPoint.init(x: halfStepper, y: rect.minY)
                let endPoint = CGPoint.init(x: halfStepper, y: rect.height * 0.5)
                rulerGrades.move(to: drawPoint)
                rulerGrades.addLine(to: endPoint)
            }
        }
        
        return rulerGrades
    }
    
    private func drawRulerVertical(in rect: CGRect) -> UIBezierPath {
        let rulerGrades = UIBezierPath.init()
        let sectionStep = 10.0
        let halfSectionStep = sectionStep / 2
        let step = halfSectionStep - 1
        for sectionStepper in stride(from: .zero, to: rect.height, by: sectionStep) {
            let drawPoint = CGPoint.init(x: rect.minX, y: sectionStepper)
            let endPoint = CGPoint.init(x: rect.width * 0.7, y: sectionStepper)
            rulerGrades.move(to: drawPoint)
            rulerGrades.addLine(to: endPoint)
            for halfStepper in stride(from: sectionStepper, to: sectionStepper + sectionStep, by: halfSectionStep) {
                for stpper in stride(from: halfStepper, to: halfStepper + halfSectionStep, by: step) {
                    let drawPoint = CGPoint.init(x: rect.minX, y: stpper)
                    let endPoint = CGPoint.init(x: rect.width * 0.2, y: stpper)
                    rulerGrades.move(to: drawPoint)
                    rulerGrades.addLine(to: endPoint)
                }
                let drawPoint = CGPoint.init(x: rect.minX, y: halfStepper)
                let endPoint = CGPoint.init(x: rect.width * 0.5, y: halfStepper)
                rulerGrades.move(to: drawPoint)
                rulerGrades.addLine(to: endPoint)
            }
        }
        
        return rulerGrades
    }
}


extension CGRect {
    var largestOfDimentions: CGFloat {
        self.width >= self.height ? self.width : self.height
    }
}
