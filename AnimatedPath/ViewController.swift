//
//  ViewController.swift
//  AnimatedPath
//
//  Created by Wizard Li on 12/28/15.
//  Copyright © 2015 morgenworks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let animationLayer = CALayer()
    let penLayer = CALayer()
    var pathLayer : CAShapeLayer? = nil
    
    func setupPenLayer() {
        let penImage = UIImage(named: "pen")
        penLayer.frame = CGRect(x: 0, y: 0, width: penImage!.size.width, height: penImage!.size.height)
        penLayer.contents = penImage?.CGImage
        penLayer.anchorPoint = CGPointZero
        penLayer.hidden = true
    }
    
    func setupTextLayer() {
        
        penLayer.removeFromSuperlayer()
        self.pathLayer?.removeFromSuperlayer()
        
        let letters = CGPathCreateMutable()
        
        let font = CTFontCreateWithName("Helvetica-Bold" as NSString, 72, nil)
        
        let attrs = [NSFontAttributeName : font]
        
        let attrString = NSAttributedString(string: "Hello!", attributes: attrs)
        
        let line = CTLineCreateWithAttributedString(attrString)
        
        let runArray = ((CTLineGetGlyphRuns(line) as [AnyObject]) as! [CTRunRef])
    
        for index in 0..<CFArrayGetCount(runArray)
        {
            let run = runArray[index]
            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run)
            {
                let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                var glyph = CGGlyph()
                var position = CGPoint()
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                let letter = CTFontCreatePathForGlyph(font, glyph, nil)
                var t = CGAffineTransformMakeTranslation(position.x, position.y);
                
                CGPathAddPath(letters, &t, letter)
            }
        }
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointZero)
        path.appendPath(UIBezierPath(CGPath: letters))
        
        let pathLayer = CAShapeLayer()
        pathLayer.frame = animationLayer.bounds
        pathLayer.bounds = CGPathGetBoundingBox(path.CGPath)
        pathLayer.geometryFlipped = true
        pathLayer.path = path.CGPath
        pathLayer.strokeColor = UIColor.blackColor().CGColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 2
        pathLayer.lineJoin = kCALineJoinBevel
        
        self.pathLayer = pathLayer
        animationLayer.addSublayer(pathLayer)
        
        pathLayer.addSublayer(penLayer)
    }
    
    func setupDrawingLayer() {

        penLayer.removeFromSuperlayer()
        self.pathLayer?.removeFromSuperlayer()
        
        let pathRect = CGRectInset(animationLayer.bounds, 100, 100)
        let bottomLeft = CGPoint(x: CGRectGetMinX(pathRect), y: CGRectGetMinY(pathRect))
        let topLeft = CGPoint(x: CGRectGetMinX(pathRect), y: CGRectGetMinY(pathRect) + CGRectGetHeight(pathRect) * 2.0/3.0)
        let bottomRight = CGPoint(x: CGRectGetMaxX(pathRect), y: CGRectGetMinY(pathRect))
        let topRight = CGPoint(x: CGRectGetMaxX(pathRect), y: CGRectGetMinY(pathRect) + CGRectGetHeight(pathRect) * 2.0/3.0)
        let rootTip = CGPoint(x: CGRectGetMidX(pathRect), y: CGRectGetMaxY(pathRect))
        
        let path = UIBezierPath()
        path.moveToPoint(bottomLeft)
        path.addLineToPoint(topLeft)
        path.addLineToPoint(rootTip)
        path.addLineToPoint(topRight)
        path.addLineToPoint(topLeft)
        path.addLineToPoint(bottomRight)
        path.addLineToPoint(topRight)
        path.addLineToPoint(bottomLeft)
        path.addLineToPoint(bottomRight)
        
        let pathLayer = CAShapeLayer()
        pathLayer.frame = animationLayer.bounds
        pathLayer.bounds = pathRect
        pathLayer.geometryFlipped = true
        pathLayer.path = path.CGPath
        pathLayer.strokeColor = UIColor.blackColor().CGColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 10
        pathLayer.lineJoin = kCALineJoinBevel
        
        self.pathLayer = pathLayer
        animationLayer.addSublayer(pathLayer)
        
        pathLayer.addSublayer(penLayer)
    }
    
    func startAnimation() {
        
        penLayer.removeAllAnimations()
        pathLayer?.removeAllAnimations()
        
        penLayer.hidden = false
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd");
        pathAnimation.duration = 10
        pathAnimation.fromValue = NSNumber(float: 0)
        pathAnimation.toValue = NSNumber(float: 1)
        pathLayer?.addAnimation(pathAnimation, forKey: "strokeEnd")
        
        let penAnimation = CAKeyframeAnimation(keyPath: "position")
        penAnimation.duration = 10
        penAnimation.path = pathLayer?.path
        penAnimation.calculationMode = kCAAnimationPaced
        penAnimation.delegate = self
        penAnimation.fillMode = kCAFillModeForwards
        penLayer.addAnimation(penAnimation, forKey: "position")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            penLayer.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationLayer.frame = CGRect(x: 20, y: 64, width: CGRectGetWidth(view.bounds)-40, height: CGRectGetHeight(view.bounds)-84)
        view.layer.addSublayer(animationLayer)
        
        setupPenLayer()
        setupTextLayer()
        
        startAnimation()
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setupDrawingLayer()
            startAnimation()
        case 1:
            setupTextLayer()
            startAnimation()
        default:
            break
        }
    }
}

