//
//  ImageViewController.swift
//  swift-multithreading-lab
//
//  Created by Flatiron School on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class ImageViewController : UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "FlatironFam"))
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.contentOffset = CGPoint(x: 800, y: 200)
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.cyanColor()
        
        view.addSubview(activityIndicator)
        
        setZoomScale()
        
        setupGestureRecognizer()
    }
    
    @IBAction func antiqueButton(sender: AnyObject) {
        print("Starting activity indicator")
        activityIndicator.startAnimating()
//        self.filterImage { (result) in
//            if result {
//                self.activityIndicator.stopAnimating()
//            }
//        }
                let userQueue = NSOperationQueue()
                userQueue.qualityOfService = .UserInitiated
                userQueue.addOperationWithBlock {
                    self.filterImage { (result) in
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            if result {
                                self.activityIndicator.stopAnimating()
                                print("Stopping activity indicator")
                            }
                        }
                    }
                }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func filterImage(completion: (Bool) -> ()) {
        
        print("Creating image")
        
        guard let image = imageView?.image, cgimg = image.CGImage else {
            print("imageView doesn't have an image!")
            completion(false)
            return
        }
        
        let openGLContext = EAGLContext(API: .OpenGLES2)
        let context = CIContext(EAGLContext: openGLContext!)
        let coreImage = CIImage(CGImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(1, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = sepiaFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let exposureFilter = CIFilter(name: "CIExposureAdjust")
            exposureFilter?.setValue(sepiaOutput, forKey: kCIInputImageKey)
            exposureFilter?.setValue(1, forKey: kCIInputEVKey)
            print("CISepiaTone applied")
            
            if let exposureOutput = exposureFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
                let output = context.createCGImage(exposureOutput, fromRect: exposureOutput.extent)
                let result = UIImage(CGImage: output)
                print("CIExposureAdjust applied")

                
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    print("Setting the new image")
                    self.imageView?.image = result

                })
                
                print("Returning completion from createImage")
                completion(true)
            }
        }
    }
}