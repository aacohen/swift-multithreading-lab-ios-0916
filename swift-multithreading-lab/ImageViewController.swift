//
//  ImageViewController.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import CoreImage


//MARK: Image View Controller

class ImageViewController : UIViewController {
    
    var scrollView: UIScrollView!
    var imageView = UIImageView()
    let picker = UIImagePickerController()
    var activityIndicator = UIActivityIndicatorView()
    let filtersToApply = ["CIBloom",
                          "CIPhotoEffectProcess",
                          "CIExposureAdjust"]
    var flatigram = Flatigram()
    
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setUpViews()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func filterButtonTapped(_ sender: AnyObject) {
       self.filterImage { (success) in
        
        }
    }
    
}

extension ImageViewController {
    func filterImage(with completion: @escaping (Bool)->() ) {
        var queue = OperationQueue()
        queue.name = "Image Filtration Queue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        for filter in filtersToApply {
            
            let filterer = FilterOperation(flatigram: flatigram, filter: filter)
            
            filterer.completionBlock = {
                
                if queue.operationCount == 0 {
                    DispatchQueue.main.async(execute: {
                        self.flatigram.state = .filtered
                        completion(true)
                    })
                    
                }
                
                if filterer.isCancelled {
                    completion(false)
                    return
                }
            }
            queue.addOperation(filterer)
            print("Added FilterOperation with \(filter) to \(queue.name!)")
        }
        
    }
}







