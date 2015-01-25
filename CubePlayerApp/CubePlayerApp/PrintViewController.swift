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
    
    @IBOutlet weak var textView: UITextView!
    
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
        
        var context:CGContextRef = UIGraphicsGetCurrentContext()  // コンテキストを取得

        let boxWidth:CGFloat = 200.0
        let boxHeight:CGFloat = 200.0
        let lineMargin:CGFloat = 1.0 // 外枠線幅分のマージン
        
        var basePoint:CGPoint = CGPointMake(150, 150) // 展開図書き出しの基準点
        self.drawCubeNet(context, boxWidth: boxWidth, boxHeight: boxHeight, lineMargin: lineMargin, basePoint: basePoint)
        
        basePoint = CGPointMake(150, 900)
        self.drawCubeNet(context, boxWidth: boxWidth, boxHeight: boxHeight, lineMargin: lineMargin, basePoint: basePoint)
        
        // PDFコンテキストを閉じる
        UIGraphicsEndPDFContext()
    }

    private func drawCubeNet(context:CGContextRef, boxWidth:CGFloat, boxHeight:CGFloat, lineMargin:CGFloat, basePoint:CGPoint) {
        
        let boxSideWidth:CGFloat = boxWidth+(lineMargin*2) // 1辺のwidth(マージン含む)
        let boxSideHeight:CGFloat = boxHeight+(lineMargin*2) // 1辺のheight（マージン含む）
        
        let boxRect:Array<CGRect> = [
            CGRectMake(basePoint.x+boxSideWidth,     basePoint.y,                   boxWidth, boxHeight),
            CGRectMake(basePoint.x,                  basePoint.y+boxSideHeight,     boxWidth, boxHeight),
            CGRectMake(basePoint.x+boxSideWidth,     basePoint.y+boxSideHeight,     boxWidth, boxHeight),
            CGRectMake(basePoint.x+(boxSideWidth*2), basePoint.y+boxSideHeight,     boxWidth, boxHeight),
            CGRectMake(basePoint.x+(boxSideWidth*3), basePoint.y+boxSideHeight,     boxWidth, boxHeight),
            CGRectMake(basePoint.x+boxSideWidth,     basePoint.y+(boxSideHeight*2), boxWidth, boxHeight),
            //CGRectMake(basePoint.x+boxSideWidth,     basePoint.y+(boxSideHeight*3), boxWidth, boxHeight)
        ]
        
        //四角形
        // box1
        self.drawOneRect(context, rect:boxRect[0])
        // box2
        self.drawOneRect(context, rect:boxRect[1])
        // box3
        self.drawOneRect(context, rect:boxRect[2])
        // box4
        self.drawOneRect(context, rect:boxRect[3])
        // box5
        self.drawOneRect(context, rect:boxRect[4])
        // box6
        self.drawOneRect(context, rect:boxRect[5])
        
        // imageを貼る
        var resizedImage:UIImage? = nil
        
        for i in 0...4 {
            var image:UIImage = self.images[i]
            resizedImage = resizeImage(image, size: CGSizeMake(boxWidth, boxHeight))
            resizedImage!.drawAtPoint(boxRect[i+1].origin)
            
        }
        
//        for image in self.images {
//            resizedImage = resizeImage(image, size: CGSizeMake(boxWidth, boxHeight))
//            resizedImage!.drawAtPoint(boxRect[1].origin)
//            resizedImage!.drawAtPoint(boxRect[2].origin)
//            resizedImage!.drawAtPoint(boxRect[3].origin)
//            resizedImage!.drawAtPoint(boxRect[4].origin)
//            resizedImage!.drawAtPoint(boxRect[5].origin)
//        }
        
        // QRコード
        var qr:UIImage = self.createQR(textView.text, size:CGSizeMake(boxWidth, boxHeight))
        qr.drawAtPoint(boxRect[0].origin)
        
        // のりしろ box1
        self.drawOneNorishiroTop(boxRect[0])
        self.drawOneNorishiroLeft(boxRect[0])
        self.drawOneNorishiroRight(boxRect[0])
        // のりしろ box2
        self.drawOneNorishiroTop(boxRect[1])
        self.drawOneNorishiroLeft(boxRect[1])
        self.drawOneNorishiroBottom(boxRect[1])
        // のりしろ box3
        // のりしろ box4
        self.drawOneNorishiroTop(boxRect[3])
        self.drawOneNorishiroBottom(boxRect[3])
        // のりしろ box5
        self.drawOneNorishiroTop(boxRect[4])
        self.drawOneNorishiroRight(boxRect[4])
        self.drawOneNorishiroBottom(boxRect[4])
        // のりしろ box6
        self.drawOneNorishiroLeft(boxRect[5])
        self.drawOneNorishiroRight(boxRect[5])
        self.drawOneNorishiroBottom(boxRect[5])

    }
    
    private func drawOneRect(context:CGContextRef, rect:CGRect) {

        CGContextSetLineWidth(context, 2.0)  // 線の太さ pt
        CGContextSetRGBStrokeColor(context, 1, 0, 1, 1)  // 線の色
        CGContextStrokeRect(context, rect)  // 四角形の描画
        CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0)  // 塗りつぶしの色を指定
        CGContextFillRect(context, rect)  // 四角形を塗りつぶす
    }

    private func drawOneNorishiroTop(rect:CGRect) {
        let margin = rect.height / 4
        
        var line = UIBezierPath()
        line.lineWidth = 1
        line.lineCapStyle = kCGLineCapRound
        // 「/」
        line.moveToPoint(CGPointMake(rect.origin.x, rect.origin.y-1))
        line.addLineToPoint(CGPointMake(rect.origin.x+margin,rect.origin.y-margin))
        // 「-」
        line.moveToPoint(CGPointMake(rect.origin.x+margin,rect.origin.y-margin))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x-margin,rect.origin.y-margin))
        // 「\」
        line.moveToPoint(CGPointMake(rect.width+rect.origin.x-margin,rect.origin.y-margin))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x,rect.origin.y-1))
        
        line.stroke()

    }

    private func drawOneNorishiroBottom(rect:CGRect) {
        let margin = rect.height / 4

        var line = UIBezierPath()
        line.lineWidth = 1
        line.lineCapStyle = kCGLineCapRound
        // 「\」
        line.moveToPoint(CGPointMake(rect.origin.x, rect.height+rect.origin.y+1))
        line.addLineToPoint(CGPointMake(rect.origin.x+margin,rect.height+rect.origin.y+margin))
        // 「-」
        line.moveToPoint(CGPointMake(rect.origin.x+margin,rect.height+rect.origin.y+margin))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x-margin,rect.height+rect.origin.y+margin))
        // 「/」
        line.moveToPoint(CGPointMake(rect.width+rect.origin.x-margin,rect.height+rect.origin.y+margin))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x,rect.height+rect.origin.y+1))
        
        line.stroke()
        
    }

    private func drawOneNorishiroLeft(rect:CGRect) {
        let margin = rect.width / 4

        var line = UIBezierPath()
        line.lineWidth = 1
        line.lineCapStyle = kCGLineCapRound
        // 「/」
        line.moveToPoint(CGPointMake(rect.origin.x-1, rect.origin.y))
        line.addLineToPoint(CGPointMake(rect.origin.x-margin,rect.origin.y+margin))
        // 「|」
        line.moveToPoint(CGPointMake(rect.origin.x-margin,rect.origin.y+margin))
        line.addLineToPoint(CGPointMake(rect.origin.x-margin,rect.height+rect.origin.y-margin))
        // 「\」
        line.moveToPoint(CGPointMake(rect.origin.x-margin,rect.height+rect.origin.y-margin))
        line.addLineToPoint(CGPointMake(rect.origin.x-1,rect.height+rect.origin.y))
        
        line.stroke()
        
    }

    private func drawOneNorishiroRight(rect:CGRect) {
        let margin = rect.width / 4

        var line = UIBezierPath()
        line.lineWidth = 1
        line.lineCapStyle = kCGLineCapRound
        
        // 「\」
        line.moveToPoint(CGPointMake(rect.width+rect.origin.x+1,rect.origin.y))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x+margin,rect.origin.y+margin))
        // 「|」
        line.moveToPoint(CGPointMake(rect.width+rect.origin.x+margin,rect.origin.y+margin))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x+margin,rect.height+rect.origin.y-margin))
        // 「/」
        line.moveToPoint(CGPointMake(rect.width+rect.origin.x+margin, rect.height+rect.origin.y-margin))
        line.addLineToPoint(CGPointMake(rect.width+rect.origin.x+1,rect.height+rect.origin.y))
        
        line.stroke()
        
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
