//
//  EntranceViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/24.
//
import UIKit
import FirebaseAuth

class EntranceViewController: UIViewController {

    @IBOutlet weak var conditionLabel: UILabel!

    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func goSingAndClear(_ sender: Any) {
        resultLabel.text = "😄"
        conditionLabel.text = "ログイン状況"
    }

    @IBAction func goCreateAndClear(_ sender: Any) {
        resultLabel.text = "😄"
        conditionLabel.text = "ログイン状況"
    }


    @IBAction func userCondition(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let email = user.email
                conditionLabel.text = "\(email!)"
            }
        } else {
            conditionLabel.text = "ログインしてないよ"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }


    @IBAction func deleteAccount(_ sender: Any) {
        let user = Auth.auth().currentUser

        user?.delete { [ weak self ] error in
            guard let strongSelf = self else { return }
            if error != nil {
                // An error happened.
                print("削除失敗")
                strongSelf.resultLabel.text = "うまくいかんかった"
            } else {
                // Account deleted.
                print("アカウントの削除")
                strongSelf.resultLabel.text = "ばいばい🙋🏻‍♂️"
            }
        }
    }
}
