//
//  Bill.swift
//  payatease
//
//  Created by Andy Lin on 2020-06-30.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import Foundation

struct Bill: Decodable {
    var billID: Int
    var amount : Float
    var description : String?
    var receiver : String
    var payer : String
    var paid : Bool
    var date: String
}


