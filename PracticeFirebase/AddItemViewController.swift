//
//  AddItemViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import UIKit
import FirebaseFirestore

class AddItemViewController: UIViewController {


    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var numberTextField: UITextField!

    @IBOutlet weak var unitTextField: UITextField!

   

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func addItem(_ sender: Any) {
        guard let id = UIDevice.current.identifierForVendor?.uuidString else { return }

        db.collection("users").addDocument(data: [
            "name": nameTextField.text ?? "",
            "number": numberTextField.text ?? "",
            "unit": unitTextField.text ?? ""
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
