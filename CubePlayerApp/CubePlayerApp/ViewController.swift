//
//  ViewController.swift
//  CubePlayerApp
//
//  Created by Kenta Akimoto on 2014/12/28.
//  Copyright (c) 2014年 Kenta Akimoto. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AVFoundation
import Photos
import CubePlayerCore

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cubeAreaView: UIView!
    @IBOutlet weak var controlPanelView: UIView!
    
    var cubeViewController:CPCCubeViewController?
    var url:NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog(CubePlayerCoreSample.hello())
        
        var obj = CubePlayerCoreSampleSwift()
        obj.hoge()
        
/*
        var assetCollection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumVideos, options: nil)
        
        assetCollection.enumerateObjectsUsingBlock { (obj, index, stop ) -> Void in
            var collection:PHAssetCollection = obj as PHAssetCollection
            NSLog("log:%@",collection.localizedTitle)
            
            var assetsFetchResult:PHFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options:nil)

        }
*/
    }
    
    func load() {
        // フォトライブラリから読み込み
        let ipc:UIImagePickerController = UIImagePickerController();
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        ipc.mediaTypes = [kUTTypeMovie!]
        // UIImagePickerControllerSourceType.PhotoLibraryでアルバムへのアクセス
        self.presentViewController(ipc, animated:true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:Dictionary<String,AnyObject>) {
//        if info[UIImagePickerControllerOriginalImage] != nil {
//            let image:UIImage = info[UIImagePickerControllerOriginalImage]  as UIImage
//        }
//        //allowsEditingがtrueの場合 UIImagePickerControllerEditedImage
//        //閉じる処理
        picker.dismissViewControllerAnimated(true, completion:{ () -> Void in
            var mediaType:String = info[UIImagePickerControllerMediaType]! as String
            if (mediaType == kUTTypeMovie)
            {
                //動画のURLを取得
                self.url = info[UIImagePickerControllerMediaURL]! as NSURL

                self.cubeViewController = CPCCubeViewController(url: self.url)
                
                self.cubeViewController?.view.frame = self.cubeAreaView.bounds
                self.cubeAreaView.addSubview(self.cubeViewController!.view)
                
            }
        });

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "printView" {
            var printViewController:PrintViewController = segue.destinationViewController as PrintViewController
            let images:[AnyObject] = self.cubeViewController!.getCurrentUIImages()
            if let downCastImages = images as? [UIImage] {
                printViewController.images = downCastImages
            }
        }
        
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
        self.cubeViewController?.toggleCaptureCurrentImage()
    }
    
    @IBAction func loadButton(sender: AnyObject) {
        self.load()
    }
}

