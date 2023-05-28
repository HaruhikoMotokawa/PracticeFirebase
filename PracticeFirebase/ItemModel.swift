//
//  ItemModel.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemModel: Codable {
    @DocumentID var id: String?
    var name: String
    var number: String
    var unit: String
}
