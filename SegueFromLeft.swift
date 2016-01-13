//
//  SegueFromLeft.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/11/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform() {
        var src: UIViewController = self.sourceViewController as! UIViewController
        var dst: UIViewController = self.destinationViewController as! UIViewController
        var transition: CATransition = CATransition()
        var timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.5
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}