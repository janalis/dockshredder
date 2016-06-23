//
//  Icon.swift
//  DockShredder
//
//  Created by Pierre Hennequart on 14/10/2015.
//  Copyright © 2015 Janalis. All rights reserved.
//

import Cocoa

class Icon: NSObject
{    
    var current: Int = 0
    let frameset: [String] = ["frame0", "frame1", "frame2", "frame3", "frame4", "frame5", "frame6", "frame7", "frame8", "frame9"]
    var timer: NSTimer = NSTimer()
    
    /**
     * Start animation
     */
    func startAnimation()
    {
        stopAnimation()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
    }
    
    /**
     * Stop animation
     */
    func stopAnimation()
    {
        current = 0
        timer.invalidate()
        setIcon(nil)
    }
    
    /**
     * Animate
     */
    func animate()
    {
        setIcon(frameset[current])
        current = current + 1
        if current >= frameset.count {
            current = 0
        }
    }
    
    /**
     * Set icon
     *
     * @param String image
     */
    func setIcon(image: String?)
    {
        NSApp.applicationIconImage = image == nil ? nil : NSImage(named: image!)!
    }
    
    /**
     * Bounce icon
     */
    func bounce()
    {
        NSApp.requestUserAttention(NSRequestUserAttentionType.InformationalRequest);
    }
}