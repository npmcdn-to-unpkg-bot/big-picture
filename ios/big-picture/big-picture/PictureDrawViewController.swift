//
//  ViewController.swift
//  big-picture
//
//  Created by Ethan Hardy on 2016-01-22.
//  Copyright © 2016 ethanhardy. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class PictureDrawViewController: UIViewController {

    @IBOutlet var backDropImageView : UIImageView!
    @IBOutlet var pictureDrawView : PictureDrawView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var colorButtons : [ColorButton]!
    var availableColours : [UIColor]! = [UIColor](arrayLiteral: UIColor(red: 1, green: 0, blue: 0, alpha: 1), UIColor(red: 0.0, green: 0.0, blue: 1, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1))
    var backDropImage : UIImage? {
        didSet {
            if let imgView = backDropImageView {
                dispatch_async(dispatch_get_main_queue(),{
                    imgView.image = self.backDropImage!
                    self.view.setNeedsDisplay()
                })
            }
        }
    }
    var imageID : String!, imageFriendlyName : String!
    var picSize : Int!
    var socketDelegate : SocketDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let numColors = availableColours.count
        for index in 0...7 {
            if (index >= numColors) {
                colorButtons[index].hidden = true
            }
            else {
                self.view.addConstraint(NSLayoutConstraint(item: colorButtons[index], attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: self.view.frame.size.width / CGFloat(numColors + 1) * CGFloat(index+1)))
                colorButtons[index].color = availableColours[index]
            }
            self.view.addConstraint(NSLayoutConstraint(item: colorButtons[index], attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 0.09, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: colorButtons[index], attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: colorButtons[index], attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        }
        if let img = backDropImage {
            backDropImageView.image = img
        }
        pictureDrawView.initializeValues(availableColours)
        pictureDrawView.pictureSideLength = picSize
        titleLabel.text = imageFriendlyName
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func changeSelectedColor(sender: ColorButton) {
        let t = sender.tag
        for button in colorButtons {
            if (button.shouldAppearDarkened != nil && button.shouldAppearDarkened! == true) {
                button.shouldAppearDarkened = false
                button.setNeedsDisplay()
            }
            if (button.tag == t) {
                button.shouldAppearDarkened = true
                button.setNeedsDisplay()
            }
        }
        pictureDrawView.currentColorInt = sender.tag
    }
    
    @IBAction func undo() {
        pictureDrawView.popStack()
    }
    
    @IBAction func toggleGrid() {
        pictureDrawView.toggleGrid()
    }
    
    @IBAction func submitImage() {
        if (pictureDrawView.pixelArrayHasEmptySpots()) {
            let alertVC = UIAlertController(title: "Alert", message: "You can't submit a drawing with empty spots!", preferredStyle: UIAlertControllerStyle.Alert)
            alertVC.addAction(UIAlertAction(title: "Keep Drawing", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                alertVC.dismissViewControllerAnimated(true, completion: nil)
            }))
            alertVC.addAction(UIAlertAction(title: "Fill Pixels and Submit", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                alertVC.dismissViewControllerAnimated(true, completion: nil)
                self.pictureDrawView.fillEmptyPixels()
                self.socketDelegate.submitImage()
                self.unwindToMainMenu() 
            }))
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
        else {
            socketDelegate.submitImage()
            let alertVC = UIAlertController(title: "Alert", message: "Contribution Submitted", preferredStyle: UIAlertControllerStyle.Alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                alertVC.dismissViewControllerAnimated(true, completion: nil)
                self.unwindToMainMenu()
            }))
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeStrokeWidth(sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 3) {
            pictureDrawView.strokeWidth = -1
        }
        else {
            pictureDrawView.strokeWidth = sender.selectedSegmentIndex
        }
    }
    
    func setPicture(pic: Picture, sDelegate: SocketDelegate) {
        availableColours = pic.colors
        pic.imageLoadedCallback = { (img: UIImage) -> Void in
            self.backDropImage = img
        }
        imageID = pic.imageID
        picSize = pic.size
        socketDelegate = sDelegate
        sDelegate.pictureDrawVC = self
        imageFriendlyName = pic.friendlyName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func unwindToMainMenu() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        socketDelegate.updateTimer?.invalidate()
    }

}

