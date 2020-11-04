//
//  BaseViewController.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/7.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation

open class BaseViewController: UIViewController {
 
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
    }
    
    open func setupUi() {
     
        view.backgroundColor = .white
    }
}

