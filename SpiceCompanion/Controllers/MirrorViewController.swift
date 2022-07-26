//
//  MirrorViewController.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit
import SwiftyJSON

class MirrorViewController: UIViewController, PacketHandler {
    
    @IBOutlet weak var mirror: UIImageView!
    private var mirrorCC: MirrorConnectionController?
    var activeScreen: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let cc = ConnectionController.get()
        self.mirrorCC = MirrorConnectionController(uiViewController: self, host: cc.host, port: cc.port, password: cc.getPassword())
        self.mirrorCC?.connect()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mirrorTouched(sender:)))
        mirror.isUserInteractionEnabled = true
        mirror.addGestureRecognizer(tapGestureRecognizer)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private var screenAspectSet = false
    private var imageWidth: Int = 0
    private var imageHeight: Int = 0
    
    func projectToMirror(){
        self.mirrorCC?.sendPacket(packet: MirrorPacket(screen: self.activeScreen))
        self.mirrorCC?.setPacketHandler(packetHandler: self)
    }
    
    func handlePacket(data: Array<JSON>) {
        DispatchQueue.main.async {
            if(self.view.window == nil){
                return
            }
            if(data.count < 3){
                return
            }
            guard let imageString = data[3].string else {
                return
            }
            if(!self.screenAspectSet){
                self.imageWidth = data[1].int!
                self.imageHeight = data[2].int!
                self.setMirrorSize(width: self.imageWidth, height: self.imageHeight)
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    //Add a rotation event for ipads to recalc the mirror size
                    NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
                }
                self.screenAspectSet = true
            }
            
            let imageData = Data(base64Encoded: imageString)
            let image = UIImage(data: imageData!)
            self.mirror.image = image
            
            self.projectToMirror()
        }
    }
    
    @objc func rotated() {
        DispatchQueue.main.async {
            self.setMirrorSize(width: self.imageWidth, height: self.imageHeight)
        }
    }
    
    var isPortrait = false
    
    func setMirrorSize(width: Int, height: Int){
        self.isPortrait = width <= height
        
        if(self.isPortrait) {
            self.mirror.frame = getMostFittingMirrorSize(imageWidth: CGFloat(height), imageHeight: CGFloat(width))
        } else {
            if(UIDevice.current.userInterfaceIdiom != .pad){
                self.mirror.transform = self.mirror.transform.rotated(by: CGFloat(Double.pi / 2))
            }
            self.mirror.frame = getMostFittingMirrorSize(imageWidth: CGFloat(width), imageHeight: CGFloat(height))
        }
    }
    
    private var mirrorWidth = CGFloat(0)
    private var mirrorHeight = CGFloat(0)
    
    //I do not know why this works. But I do know it's black magic and that touching anything will break it.
    func getMostFittingMirrorSize(imageWidth: CGFloat, imageHeight: CGFloat) -> CGRect{
        
//        rs > ri ? (wi * hs/hi, hs) : (ws, hi * ws/wi)
//        https://stackoverflow.com/questions/6565703/math-algorithm-fit-image-to-screen-retain-aspect-ratio
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height - self.topbarHeight
        if(screenSize.width / screenHeight >  imageWidth / imageHeight || (self.isPortrait && UIDevice.current.userInterfaceIdiom == .pad)){
            self.mirrorWidth = imageHeight * screenHeight / imageWidth
            self.mirrorHeight = screenHeight
            let offset = (screenSize.width - self.mirrorWidth) / 2
            return CGRect(x: offset, y: self.topbarHeight, width: self.mirrorWidth, height: self.mirrorHeight)
        }  else {
            //Screen fits in full screen width
            self.mirrorHeight = imageWidth * screenSize.width / imageHeight
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.mirrorHeight = imageHeight * screenSize.width / imageWidth
            }
            self.mirrorWidth = screenSize.width
            //Offset to center mirror
            let offset = (screenHeight - self.mirrorHeight) / 2
            return CGRect(x: 0, y: self.topbarHeight + offset, width: self.mirrorWidth, height: self.mirrorHeight)
        }
    }
    
    @objc func mirrorTouched(sender : UITapGestureRecognizer){
        let touchPoint = sender.location(in: self.mirror)
        var imagePointX = Int(touchPoint.x / self.mirrorHeight * CGFloat(self.imageWidth))
        var imagePointY = Int(touchPoint.y / self.mirrorWidth * CGFloat(self.imageHeight))
        if(UIDevice.current.userInterfaceIdiom == .pad){
            imagePointX = Int(touchPoint.x / self.mirrorWidth * CGFloat(self.imageWidth))
            imagePointY = Int(touchPoint.y / self.mirrorHeight * CGFloat(self.imageHeight))
        }
        sendTouchEvent(x: imagePointX, y: imagePointY)
    }
    
    private var touchCounter = 1
    
    func sendTouchEvent(x: Int, y: Int){
        
        let touchWritePacket = TouchWritePacket(id: self.touchCounter, x: x, y: y)
        ConnectionController.get().sendPacket(packet: touchWritePacket)
        let resetPacket = TouchResetPacket(id: self.touchCounter)
        
        //Yes this is janky but for now it works. I want to replace this with hold gestures in the futture.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ConnectionController.get().sendPacket(packet: resetPacket)
        }
        self.touchCounter += 1
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        self.mirrorCC?.resetPacketHandler()
        self.mirrorCC?.disconnect()
        UIApplication.shared.isIdleTimerDisabled = false
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let image : UIImage = self.mirror.image!
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [image], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityViewController.popoverPresentationController?.barButtonItem = sender
            }
        }
//           activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//           activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
           activityViewController.activityItemsConfiguration = [
           UIActivity.ActivityType.message
           ] as? UIActivityItemsConfigurationReading
           
           activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToVimeo,
           ]
           
           activityViewController.isModalInPresentation = true
           self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
