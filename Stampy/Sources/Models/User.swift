//
//  User.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 17/11/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Codable { 
    let id: String   
    let fullname: String
    let email: String
    var paymentsTotal: Double = 0
    var balance: Double = 0
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
