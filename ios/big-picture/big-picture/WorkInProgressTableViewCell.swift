//
//  WorkInProgressTableViewCell.swift
//  big-picture
//
//  Created by Ethan Hardy on 2016-01-23.
//  Copyright © 2016 ethanhardy. All rights reserved.
//

import UIKit

class WorkInProgressTableViewCell: UITableViewCell {
    
    var imageID : String!
    private var _progress : CGFloat!
    var progress : CGFloat! {
        get {
            return _progress
        }
        set(newProgress) {
            if (progress >= 0.0 && progress <= 1.0) {
                _progress = newProgress
                //self.setNeedsDisplay()
            }
        }
    }
    var colors : [CGColor]!
    var gestureTarget : MainMenuViewController!
    @IBOutlet var titleLabel : UILabel!
    
    func setupCell(colorsP: [UIColor], gestureTargetP: MainMenuViewController, imageIDP: String, title: String) {
        colors = [CGColor]()
        for color in colorsP {
            colors.append(CGColorCreateCopyWithAlpha(color.CGColor, 0.4)!)
        }
        gestureTarget = gestureTargetP
        imageID = imageIDP
        _progress = 0
        let swipe = UISwipeGestureRecognizer(target: self, action: "viewWorkInProgress")
        swipe.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipe)
        let tap = UITapGestureRecognizer(target: self, action: "contributeToWorkInProgress")
        self.addGestureRecognizer(tap)
        self.titleLabel.text = title
    }
    
    func viewWorkInProgress() {
        gestureTarget.goToViewWorkInProgressWithImageID(imageID)
    }
    
    func contributeToWorkInProgress() {
        gestureTarget.goToContributeToWorkInProgressWithImageID(imageID)
    }
    
    
    override func drawRect(rect: CGRect) {
        let cont = UIGraphicsGetCurrentContext()
        CGContextAddRect(cont, self.bounds)
        CGContextSetFillColorWithColor(cont, colors[0])
        CGContextFillPath(cont)
        for var i = 1; i < colors.count; i++ {
            let stripeWidth = self.bounds.width / CGFloat(colors.count)
            CGContextMoveToPoint(cont, stripeWidth * CGFloat(i-1), self.bounds.height)
            CGContextAddLineToPoint(cont, stripeWidth * CGFloat(i), 0)
            CGContextAddLineToPoint(cont, stripeWidth * CGFloat(i+1), 0)
            CGContextAddLineToPoint(cont, stripeWidth * CGFloat(i), self.bounds.height)
            CGContextClosePath(cont)
            CGContextSetFillColorWithColor(cont, colors[i])
            CGContextFillPath(cont)
           // break;
        }
        CGContextAddRect(cont, CGRectMake(self.bounds.width * (1 - self.progress), 0, self.bounds.width * self.progress, self.bounds.height))
        CGContextSetRGBFillColor(cont, 0.9, 0.9, 0.9, 0.4)
        CGContextFillPath(cont)
    }
    
}
