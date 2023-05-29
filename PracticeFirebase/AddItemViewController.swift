//
//  AddItemViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class AddItemViewController: UIViewController {


    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var numberTextField: UITextField!

    @IBOutlet weak var unitTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction func addItem(_ sender: Any) {
        guard (UIDevice.current.identifierForVendor?.uuidString) != nil else { return }

        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("shoppingItem").addDocument(data: [
                "name": nameTextField.text ?? "",
                "number": numberTextField.text ?? "",
                "unit": unitTextField.text ?? "",
                "user": user.uid,
                "date": Date()
            ]) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        self.nameTextField.text = ""
                    }
                }
            }
            dismiss(animated: true)
        }
    }
}
