//
//  PreferencesViewController.swift
//  DockShredder
//
//  Created by Pierre Hennequart on 12/10/2015.
//  Copyright © 2015 Janalis. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController
{    
    /**
     * Click on launch at login option
     *
     * @param NSButton sender
     */
    @IBAction func toggleLaunchAtLogin(sender: NSButton)
    {
        let option: Bool = NSUserDefaults.standardUserDefaults().boolForKey(Constant.optionLaunchAtLogin)
        Startup.setLaunchAtStartup(option)
        if option {
            if System.confirm("confirm.option.startup".localized) {
                NSAppleScript(source: "tell application \"System Preferences\"\nactivate\nset current pane to pane \"com.apple.preference.users\"\nend tell")!.executeAndReturnError(nil)
            }
        }
    }
    
    /**
     * View will layout
     */
    override func viewWillLayout()
    {
        NSUserDefaults.standardUserDefaults().setBool(Startup.applicationIsInStartupItems(), forKey: Constant.optionLaunchAtLogin)
    }
    
    /**
     * View did load
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

