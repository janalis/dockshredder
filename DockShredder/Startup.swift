//
//  LaunchAtStartup.swift
//  DockShredder
//
//  Created by Pierre Hennequart on 13/10/2015.
//  Copyright © 2015 Janalis. All rights reserved.
//

import Foundation

class Startup
{    
    /**
     * Application is in startup items
     *
     * @return Bool
     */
    static func applicationIsInStartupItems() -> Bool
    {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    /**
     * Item references in login items
     *
     * @param LSSharedFileListItemRef existingReference
     * @param LSSharedFileListItemRef lastReference
     */
    static func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?)
    {
        if let appUrl: NSURL? = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as Array
                
                if loginItems.count == 0 {
                    return (nil, kLSSharedFileListItemBeforeFirst.takeRetainedValue())
                }
                
                let lastItemRef: LSSharedFileListItemRef = loginItems.last as! LSSharedFileListItemRef
                
                for currentItemRef in loginItems as! [LSSharedFileListItemRef] {
                    if let itemUrl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                        if (itemUrl.takeRetainedValue() as NSURL).isEqual(appUrl) {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                }
                
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
    
    /**
     * Set launch at startup
     *
     * @param Bool shouldLaunch
     */
    static func setLaunchAtStartup(shouldLaunch: Bool) {
        let itemReferences = itemReferencesInLoginItems()
        let alreadyExists = (itemReferences.existingReference != nil)
        let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef?
        if loginItemsRef != nil {
            if !alreadyExists && shouldLaunch {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(loginItemsRef,
                        itemReferences.lastReference, nil, nil, appUrl, nil, nil)
                }
            } else if alreadyExists && !shouldLaunch {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                }
            }
        }
    }
}