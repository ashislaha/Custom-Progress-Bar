//
//  ViewController.swift
//  Custom Progress bar
//
//  Created by Ashis Laha on 12/12/17.
//  Copyright © 2017 Ashis Laha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var pulsatingLayer : CAShapeLayer!
    var trackPathLayer : CAShapeLayer!
    var fillPathLayer  : CAShapeLayer!
    
    var downloadTask : URLSessionDownloadTask!
    
    // visible the status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: downloadText
    private let downloadText : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false // enable auto layout
        label.text = "Start"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private func addDownloadLabel() {
        view.addSubview(downloadText)
        
        NSLayoutConstraint.activate([
            downloadText.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            downloadText.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    //MARK: ShapeLayer Setups
    private func createShapeLayer(fillColor : UIColor, strokeColor : UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let bezierPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: -CGFloat.pi/2, endAngle: 3/2*CGFloat.pi, clockwise: true)
        layer.path = bezierPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = 20
        layer.strokeEnd = 0 // animate this property
        layer.lineCap = kCALineCapRound // to shape the front while stroking
        layer.position = view.center
        return layer
    }
    
    private func setupCirleLayers() {
        pulsatingLayer = createShapeLayer(fillColor: .pulsatingFillColor, strokeColor: .clear)
        trackPathLayer = createShapeLayer(fillColor: .backGroundColor, strokeColor: .trackStrokeColor)
        fillPathLayer = createShapeLayer(fillColor: .clear, strokeColor: .animatedStrokeColor)
     
        // add to the hierarchy
        view.layer.addSublayer(pulsatingLayer)
        view.layer.addSublayer(trackPathLayer)
        view.layer.addSublayer(fillPathLayer)
        
        trackPathLayer.strokeEnd = 1
        animatePulsatingLayer()
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 0.5
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        // add timing func
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulsatingLayer.add(animation, forKey: "Pulse it")
    }
    
    private func animateFillPathLayer() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.duration = 4.0
        
        // to retain the result after animation
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        fillPathLayer.add(animation, forKey: "do animation")
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backGroundColor
        setupCirleLayers()
        addDownloadLabel()
        addTapGesture()
        registerNotification()
    }
    
    //MARK: Register Notification
    private func registerNotification() {
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) { (notification) in
            self.animatePulsatingLayer()
            if self.downloadTask != nil {
                self.downloadTask.cancel()
            }
        }
    }
    
    //MARK: add tap gesture
    private func addTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnView)))
    }
    
    @objc private func tappedOnView() {
        //animateLayer()
        download()
    }
    
    // download using urlSession
    private func download() {
        fillPathLayer.strokeEnd = 0
        let urlString = "https://s3.ap-south-1.amazonaws.com/car-detection-images/Archive.zip"
        let configuration = URLSessionConfiguration.default
        let queue = OperationQueue() // non-main queue
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        
        guard let url = URL(string: urlString) else { return }
        downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
}

// URLSessionDownloadDelegate <- URLSessionTaskDelegate <- URLSessionDelegate
extension ViewController : URLSessionDownloadDelegate  {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download completed")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        print(totalBytesWritten,totalBytesExpectedToWrite)
        let fraction = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.fillPathLayer.strokeEnd = fraction
            self.downloadText.text = "\(Int(fraction*100))%"
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("ERROR:",error.localizedDescription)
        }
    }
}


