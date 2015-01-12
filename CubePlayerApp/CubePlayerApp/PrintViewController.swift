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
        makePdf()
        preview()
    }
}
