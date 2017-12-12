//
//  ViewController.swift
//  Custom Progress bar
//
//  Created by Ashis Laha on 12/12/17.
//  Copyright © 2017 Ashis Laha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let animatedLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 10
        layer.strokeEnd = 0 // animate this property
        layer.lineCap = kCALineCapRound // to shape the front while stroking
        return layer
    }()
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bezierPath = UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: 3/2*CGFloat.pi, clockwise: true)
        
        createTrack(path: bezierPath)
        addAnimatedLayer(path: bezierPath)
        addTapGesture()
    }

    // create track
    private func createTrack(path : UIBezierPath) {
        let trackLayer = CAShapeLayer()
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10.0
        view.layer.addSublayer(trackLayer)
    }
    
    // add animated layer
    private func addAnimatedLayer(path : UIBezierPath) {
        view.layer.addSublayer(animatedLayer)
        animatedLayer.path = path.cgPath
    }
    
    // add tap gesture
    private func addTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnView)))
    }
    
    @objc private func tappedOnView() {
        print("view tapped : Do animation")
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.duration = 4.0
        
        // to retain the result after animation
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        animatedLayer.add(animation, forKey: "do animation")
    }
}

