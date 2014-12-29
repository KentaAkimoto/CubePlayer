//
//  ViewController.swift
//  CubePlayerApp
//
//  Created by Kenta Akimoto on 2014/12/28.
//  Copyright (c) 2014年 Kenta Akimoto. All rights reserved.
//

import UIKit
import CubePlayerCore

class ViewController: UIViewController {

    var cubeViewController:CPCCubeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog(CubePlayerCoreSample.hello())
        
        var obj = CubePlayerCoreSampleSwift()
        obj.hoge()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func tapButton(sender: UIButton) {
        self.cubeViewController = CPCCubeViewController(nibName: "CPCCubeView", bundle: NSBundle(forClass: CPCCubeViewController.classForCoder()))
        self.cubeViewController?.view.frame = self.view.bounds
        self.presentViewController(self.cubeViewController!, animated: true) { () -> Void in
            
        }
        
    }
    
}

