//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Simon Ng on 23/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let barcodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode]
    
    @IBOutlet weak var messageLabel:UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get an instance of the AVCaptureDevice class to intialize a device object and provide the video as the media type parameter
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            // get an instance of the AVCaptureDeviceInput class using the previous device object
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // initialize the captureSession object
            
            captureSession = AVCaptureSession()
            
            // set the input device on the capture session
            
            captureSession?.addInput(input)
            
            // initialize an AVCaptureMetadataOutput object and set it as the output device to the capture session
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // set the delegate and use the default dispatch queue to execute the call back
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            // support all barcode types from the barcodeTypes array
            
            captureMetadataOutput.metadataObjectTypes = barcodeTypes
            
            // initialize the video preview layer and add it as a sublayer to the viewPreview's view layer
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // start video capture
            
            captureSession?.startRunning()
            
            // move the message label to the top view
            
            view.bringSubviewToFront(messageLabel)
            
            // initialize QR code frame to highlight the QR code
            
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            // if any error occurs, print it out and stop
            
            print(error)
            
            return
        }

    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // check if the metadataObjects array is not nil and that it contains at least one object
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No barcode is detected"
            
            return
        }
        
        // get the metadata object
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // use filter method to check if the type of metadataObj is supported
        // instead of hardcoding the AVMetadataObjectTypeQRCode, check to see if barcode is in barcodeTypes array
        
        if barcodeTypes.contains(metadataObj.type) {
            // if the found metadata is equal to the barcode metadata then update the status label's text and set the bounds
            
            let barcodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barcodeObject!.bounds
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}

