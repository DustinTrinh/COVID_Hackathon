//
//  ScanCodeViewController.swift
//  payatease
//
//  Created by Andy Lin on 2020-06-30.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import UIKit
import AVFoundation

class ScanCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

//    var video = AVCaptureVideoPreviewLayer()
//    let session = AVCaptureSession()
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var payAmount : ((Float, Bill) -> ())?
    
    var payment : Payment?

    var billInfo = [String]()
    var balance : Float = 0
    
    var username  = ""
    var password = ""
    
    @IBOutlet weak var QRImage: UIImageView!
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        //creating session
//        let session = AVCaptureSession()
//
//
//        //define capture device
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
//
//
//
//        do {
//            let input = try AVCaptureDeviceInput(device: captureDevice)
//            session.addInput(input)
//
//        } catch {
//            print("error")
//        }
//
//        let output = AVCaptureMetadataOutput()
//        session.addOutput(output)
//
//        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//        output.metadataObjectTypes = [.qr]
//
//        video = AVCaptureVideoPreviewLayer(session: session)
//        video.frame = view.layer.bounds
//        view.layer.addSublayer(video)
//        self.view.bringSubviewToFront(QRImage)
//        startScan()
//
//
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    
    
//
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        if metadataObjects != nil && metadataObjects.count != 0 {
//            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
//                if object.type == .qr {
//                    let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
//                    alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: nil))
//                    present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//    }

    
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        //dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
        
        //if string fits in to array ( have correct number of values) process payment
        
        billInfo = code.components(separatedBy: " ")
        if billInfo.count == 3 {
            confirmPayment()
        } else {
            
            //else display an alert saying invalid QR code, resume the camera
            let message = "QR code is not a valid bill."
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
                    self?.captureSession.startRunning()
                }))
            self.present(alert, animated: true, completion: nil)
        }
        
        

        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //function gets called when QR is valid
    func confirmPayment() {
        
        //check for payment amount, if amount is greater than balance, return alert telling user insufficient balance
        
        if let amount = Float(billInfo[2]), let _ = Int(billInfo[0]){
            if amount > balance {
                let message = "Insufficient Balance."
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
                    self?.captureSession.startRunning()
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                processRequest()
            }
            
        } else {
            let message = "QR code error."
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
                self?.captureSession.startRunning()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func processRequest() {
        
        // if user has enough balance, ask for confirmation in alert
        let alert = UIAlertController(title: "Payment Confirmation", message: "Are you sure you want to make the payment?", preferredStyle: .alert)
        
        // user confirms the payment by clicking "OK"
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak self] action in
            
            //preparing payment function is called, to make request to server
            self?.preparePayment()
            
        }))
        
        
        // User cancels the payment by clicking "cancel", resume the camera
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            self.captureSession.startRunning()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Making http request to server to pay bill
    func preparePayment() {
        let id = Int(billInfo[0])!
        let receiver = billInfo[1]
        let amount = Float(billInfo[2])!
        
        payment = Payment(billID: id, balance: amount, payee: receiver)
        
        let request = HttpRequest(username: username, password: password)
        request.payBill(payment: payment!, completion: { [weak self] result in
            switch result{
            case .success(let bill):
                DispatchQueue.main.async {
                    self?.payAmount?(amount,bill)
                    
                    let message = "Payment Success! Your new bill is saved."
                    let innerAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    innerAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
                        _ = self?.navigationController?.popViewController(animated: true)
                    }))
                    self?.present(innerAlert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                let message = "Payment Request Failed."
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
                    self?.captureSession.startRunning()
                }))
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        })
        
        
        
    }
    
}
