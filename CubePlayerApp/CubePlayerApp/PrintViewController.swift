//
//  PrintViewController.swift
//  CubePlayerApp
//
//  Created by Kenta Akimoto on 2015/01/09.
//  Copyright (c) 2015年 Kenta Akimoto. All rights reserved.
//

import UIKit
import CoreText
import QuickLook

class PrintViewController: UIViewController, QLPreviewControllerDataSource {

    var pdfFilePath:String?
    var quickLookViewController:QLPreviewController?
    var images:Array<UIImage> = []
    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func resizeImage(image:UIImage, size:CGSize) -> UIImage {
        var resultImage = image
        // UIImageを最近傍法を適用しつつリサイズする
        UIGraphicsBeginImageContext(size)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, kCGInterpolationNone) //補間方法の指定
        resultImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    private func createQR(inputMessage:String, size:CGSize) -> UIImage {
        // QRコード作成用のフィルターを作成・パラメータの初期化
        var ciFilter:CIFilter = CIFilter(name:"CIQRCodeGenerator")
        ciFilter.setDefaults()
        
        // 格納する文字列をNSData形式（UTF-8でエンコード）で用意して設定
        var qrString = inputMessage
        var data:NSData = qrString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        ciFilter.setValue(data, forKey:"inputMessage")
        
        // 誤り訂正レベルを「L（低い）」に設定
        ciFilter.setValue("L", forKey:"inputCorrectionLevel")
        
        // Core Imageコンテキストを取得したらCGImage→UIImageと変換して描画
        var ciContext:CIContext = CIContext(options: nil)
        var cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage, fromRect: ciFilter.outputImage.extent())
        var image:UIImage = UIImage(CGImage:cgimg, scale: 1.0, orientation: UIImageOrientation.Up)!

        // UIImageを最近傍法を適用しつつリサイズする
        UIGraphicsBeginImageContext(size)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, kCGInterpolationNone) //補間方法の指定
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image;
    }
    
    private func preview() {
        self.quickLookViewController = QLPreviewController()
        self.quickLookViewController!.dataSource = self
        self.quickLookViewController!.refreshCurrentPreviewItem()
        self.presentViewController(self.quickLookViewController!, animated: true) { () -> Void in
        }
    }
    
    private func makePdf() {
        self.pdfFilePath = String(format: "%@/result.pdf", NSHomeDirectory().stringByAppendingPathComponent("Documents"))
        
        // PDFコンテキストを作成する
        UIGraphicsBeginPDFContextToFile(pdfFilePath, CGRectZero, nil)
        
        // 新しいページを開始する
        var size:CGSize = CGSizeMake(1240, 1754) //self.view.bounds.size;
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, size.width, size.height), nil)
        
        // 文字列を描画する
        var title = "pdfですよ"
        var rect:CGRect = CGRectMake(0, 0, size.width, size.height)
        
        // 画像を描画する
        var point:CGPoint = CGPointMake(0, 200)
        var image:UIImage = UIImage(named: "test.png", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)!
        image.drawAtPoint(point)
        
        //四角形を描画
        var context:CGContextRef = UIGraphicsGetCurrentContext()  // コンテキストを取得

        self.drawOneRect(context, rect:CGRectMake(50, 50, 100, 100))
        
        self.drawOneRect(context, rect:CGRectMake(50, 152, 100, 100))
        self.drawOneRect(context, rect:CGRectMake(152, 152, 100, 100))
        self.drawOneRect(context, rect:CGRectMake(254, 152, 100, 100))
        
        self.drawOneRect(context, rect:CGRectMake(50, 254, 100, 100))
        self.drawOneRect(context, rect:CGRectMake(50, 356, 100, 100))
        
        // imageを貼る
        var resizedImage:UIImage? = nil
        for image in self.images {
            resizedImage = resizeImage(image, size: CGSizeMake(100, 100))
            resizedImage!.drawAtPoint(CGPointMake(50, 152))
            resizedImage!.drawAtPoint(CGPointMake(152, 152))
            resizedImage!.drawAtPoint(CGPointMake(254, 152))
            resizedImage!.drawAtPoint(CGPointMake(50, 254))
            resizedImage!.drawAtPoint(CGPointMake(50, 356))
        }
        
        // QRコード
        var qr:UIImage = self.createQR("hello world", size:CGSizeMake(100, 100))
        qr.drawAtPoint(CGPointMake(50, 50))
        
        // PDFコンテキストを閉じる
        UIGraphicsEndPDFContext();
    }

    private func drawOneRect(context:CGContextRef, rect:CGRect) {

        // 線の太さを指定
        CGContextSetLineWidth(context, 2.0)  // 12ptに設定
        // 線の色を指定
        CGContextSetRGBStrokeColor(context, 1, 0, 1, 1)  // 青色に設定

        CGContextStrokeRect(context, rect)  // 四角形の描画
        
        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0)  // 塗りつぶしの色を指定
        
        CGContextFillRect(context, rect)  // 四角形を塗りつぶす
        
    }

    // MARK: - QuickLook
    /*!
    * @abstract Returns the number of items that the preview controller should preview.
    * @param controller The Preview Controller.
    * @result The number of items.
    */
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController!) -> Int {
        return 1
    }
    
    /*!
    * @abstract Returns the item that the preview controller should preview.
    * @param panel The Preview Controller.
    * @param index The index of the item to preview.
    * @result An item conforming to the QLPreviewItem protocol.
    */
    func previewController(controller: QLPreviewController!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        return NSURL(fileURLWithPath:self.pdfFilePath!)
    }
    
    @IBAction func tapPrintButton(sender: AnyObject) {
        
        self.images = [UIImage(named: "test.png", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)!];
        
        makePdf()
        preview()
    }
}
