//
//  Payment.swift
//  payatease
//
//  Created by Andy Lin on 2020-07-01.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import Foundation


struct Payment: Encodable {
    var billID: Int
    var balance : Float
    var payee : String
}
