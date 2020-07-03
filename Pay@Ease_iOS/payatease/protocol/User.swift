//
//  User.swift
//  payatease
//
//  Created by Andy Lin on 2020-06-30.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import Foundation

struct User: Decodable {
    let username: String
    let email : String
    var company_name: String?
    var phone_number : Int
    var address : String
    var postal_code : String
    var industry : String?
    var balance : Float
    var bill : [Bill]
    
}
