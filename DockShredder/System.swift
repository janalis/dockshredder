//
//  System.swift
//  DockShredder
//
//  Created by Pierre Hennequart on 13/10/2015.
//  Copyright © 2015 Janalis. All rights reserved.
//

import Cocoa

class System
{    
    /**
     * Confirm
     *
     * @param String message
     * @return Bool
     */
    static func confirm(message: String) -> Bool
    {
        let alert = NSAlert()
        alert.messageText = "DockShredder"
        alert.addButtonWithTitle("button.ok".localized)
        alert.addButtonWithTitle("button.cancel".localized)
        alert.informativeText = message
        if alert.runModal() == NSAlertFirstButtonReturn {
            return true
        }
        
        return false
    }
    
    /**
     * Alert
     *
     * @param String message
     */
    static func alert(message: String)
    {
        let alert = NSAlert()
        alert.messageText = "DockShredder"
        alert.addButtonWithTitle("button.ok".localized)
        alert.informativeText = message
        alert.runModal()
    }
    
    /**
     * Push notification
     *
     * @param String message
     */
    static func pushNotification(message: String)
    {
        let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        let notification = NSUserNotification()
        notification.title = "DockShredder"
        notification.informativeText = message
        notification.deliveryDate = NSDate(timeIntervalSinceNow: 0)
        notification.soundName = NSUserNotificationDefaultSoundName
        notificationCenter.scheduleNotification(notification)
    }
}