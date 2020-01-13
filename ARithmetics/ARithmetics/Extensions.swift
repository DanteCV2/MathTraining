//
//  Extensions.swift
//  ARithmetics
//
//  Created by Dante Cervantes Vega on 01/11/19.
//  Copyright © 2019 Dante Cervantes Vega. All rights reserved.
//

import Foundation
extension Int{
    var hasUniqueDigits : Bool{
        let strValue = String(self)
        let uniqueChars = Set(strValue)
        return uniqueChars.count == strValue.count
    }
}
