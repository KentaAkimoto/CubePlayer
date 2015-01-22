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

    @IBOutlet weak var cubeAreaView: UIView!
    @IBOutlet weak var controlPanelView: UIView!
    
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
//        self.cubeViewController = CPCCubeViewController(url: NSBundle.mainBundle().URLForResource("sample_iPod", withExtension: "m4v"))
//        self.cubeViewController = CPCCubeViewController(url: NSBundle.mainBundle().URLForResource("iori", withExtension: "mp4"))
        self.cubeViewController = CPCCubeViewController(url: NSBundle.mainBundle().URLForResource("mp4_h264_aac", withExtension: "mp4"))

        self.cubeViewController?.view.frame = self.cubeAreaView.bounds
        /*
        self.presentViewController(self.cubeViewController!, animated: true) { () -> Void in
            
        }
        */
        self.cubeAreaView.addSubview(self.cubeViewController!.view)
    }
    
    @IBAction func playPauseButton(sender: AnyObject) {
        
    }
    @IBAction func printButton(sender: AnyObject) {
        
    }
}

