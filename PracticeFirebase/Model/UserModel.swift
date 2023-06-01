//
//  UserModel.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/29.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserModel: Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var password: String
    var sharedUsers: [String]?
}
