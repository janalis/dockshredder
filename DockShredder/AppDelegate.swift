//
//  AppDelegate.swift
//  DockShredder
//
//  Created by Pierre Hennequart on 12/10/2015.
//  Copyright © 2015 Janalis. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var icon: Icon = Icon()
    
    /**
     * Application did finish launching
     *
     * @param NSNotification
     */
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Set default preferences
        if NSUserDefaults.standardUserDefaults().objectForKey(Constant.optionAskForConfirmationBeforeDeletion) == nil {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constant.optionAskForConfirmationBeforeDeletion)
        }
        if NSUserDefaults.standardUserDefaults().objectForKey(Constant.optionSendNotificationAfterDeletion) == nil {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constant.optionSendNotificationAfterDeletion)
        }
        if NSUserDefaults.standardUserDefaults().objectForKey(Constant.optionLaunchAtLogin) == nil {
            Startup.setLaunchAtStartup(false)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constant.optionLaunchAtLogin)
        }
    }

    /**
     * Application will terminate
     *
     * @param NSNotification
     */
    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }
    
    /**
     * Open file
     *
     * @param NSApplication sender
     * @param String filename
     */
    @IBAction func openDocument(sender: NSApplication)
    {
        let confirm: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionAskForConfirmationBeforeDeletion)
        let notify: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionSendNotificationAfterDeletion)
        var errors = 0
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = true
        openPanel.directoryURL = nil
        openPanel.allowedFileTypes = nil
        if openPanel.runModal() == NSModalResponseOK {
            let files = openPanel.URLs
            if confirm && !System.confirm(files.count > 1 ? "confirm.delete.files".localized : "confirm.delete.file".localized) {
                return
            }
            icon.startAnimation()
            for file in files {
                errors = errors + Int(shredFile(file))
            }
            icon.stopAnimation()
            if notify {
                if errors == 0 {
                    System.pushNotification(files.count > 1 ? "alert.files.deleted".localized : "alert.file.deleted".localized)
                }
            }
        }
    }
    
    /**
     * Open file
     *
     * @param NSApplication sender
     * @param String filename
     * @return Bool
     */
    func application(sender: NSApplication, openFile filename: String) -> Bool
    {
        let confirm: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionAskForConfirmationBeforeDeletion)
        let notify: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionSendNotificationAfterDeletion)
        if confirm && !System.confirm("confirm.delete.file".localized) {
            return false
        }
        icon.startAnimation()
        if shredFile(NSURL(fileURLWithPath: filename)) {
            if notify {
                System.pushNotification("alert.file.deleted".localized)
            }
            icon.stopAnimation()
            
            return true
        }
        icon.stopAnimation()
        
        return false
    }
    
    /**
     * Open files
     *
     * @param NSApplication sender
     * @param [String] filenames
     */
    func application(sender: NSApplication, openFiles filenames: [String])
    {
        let confirm: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionAskForConfirmationBeforeDeletion)
        let notify: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionSendNotificationAfterDeletion)
        var errors = 0
        if confirm && !System.confirm(filenames.count > 1 ? "confirm.delete.files".localized : "confirm.delete.file".localized) {
            return
        }
        icon.startAnimation()
        for filename in filenames {
            errors = errors + Int(shredFile(NSURL(fileURLWithPath: filename)))
        }
        icon.stopAnimation()
        if notify {
            if errors == 0 {
                System.pushNotification(filenames.count > 1 ? "alert.files.deleted".localized : "alert.file.deleted".localized)
            }
        }
    }
    
    /**
     * Shred a file
     *
     * @param NSURL path
     */
    func shredFile(url: NSURL) -> Bool
    {
        do {
            let path: String! = url.path
            let infos: NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            let fileSize: Double = infos["NSFileSize"]!.doubleValue
            let bytes = String(Int(ceil(sqrt(fileSize))))
            fillWithZeros(path, bytes: bytes)
            fillWithOnes(path, bytes: bytes)
            fillWithRandom(path, bytes: bytes)
            deleteFile(path)
            
            return true
        } catch {
            print(error)
            
            return false
        }
    }
    
    /**
     * Fill a file with zeros
     *
     * @param String path
     * @param String bytes
     */
    func fillWithZeros(path: String, bytes: String)
    {
        let dd = NSTask()
        dd.launchPath = "/bin/dd"
        dd.arguments = ["if=/dev/zero", "bs=\(bytes)", "count=\(bytes)", "of=\(path)"]
        dd.launch()
        dd.waitUntilExit()
    }
    
    /**
     * Fill a file with ones
     *
     * @param String path
     * @param String bytes
     */
    func fillWithOnes(path: String, bytes: String)
    {
        let file: NSFileHandle = NSFileHandle(forWritingAtPath: path)!
        let dd = NSTask()
        dd.launchPath = "/bin/dd"
        dd.arguments = ["if=/dev/zero", "bs=\(bytes)", "count=\(bytes)"]
        let pipe = NSPipe()
        dd.standardOutput = pipe
        dd.launch()
        let tr = NSTask()
        tr.launchPath = "/usr/bin/tr"
        tr.arguments = ["'\\0'", "'\\377'"]
        tr.standardInput = pipe
        tr.standardOutput = file
        tr.launch()
        tr.waitUntilExit()
        file.closeFile()
    }
    
    /**
     * Fill a file with random
     *
     * @param String path
     * @param String bytes
     */
    func fillWithRandom(path: String, bytes: String)
    {
        let dd = NSTask()
        dd.launchPath = "/bin/dd"
        dd.arguments = ["if=/dev/urandom", "bs=\(bytes)", "count=\(bytes)", "of=\(path)"]
        dd.launch()
        dd.waitUntilExit()
    }
    
    /**
     * Delete a file
     *
     * @param String path
     */
    func deleteFile(path: String)
    {
        let rm = NSTask()
        rm.launchPath = "/bin/rm"
        rm.arguments = ["\(path)"]
        rm.launch()
        rm.waitUntilExit()
    }
}

