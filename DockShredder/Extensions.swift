//
//  Extensions.swift
//  DockShredder
//
//  Created by Pierre Hennequart on 13/10/2015.
//  Copyright © 2015 Janalis. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}

extension Int {
    init(_ value: Bool){
        if value {
            self.init(1)
        } else {
            self.init(0)
        }
    }
}