//
//  ViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class CreateUserViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func isClear(_ sender: Any) {
        userNameTextField.text = ""
        email.text = ""
        password.text = ""
        resultLabel.backgroundColor = UIColor.clear
        resultLabel.text = "メールアドレスとパスワードを入力して登録ボタンを押してね"
    }

    @IBAction func isRegister(_ sender: Any) {
        // メールとパスワードのnil確認
        guard let email = email.text,
              let password = password.text else { return }
        // 登録の処理
        Auth.auth().createUser(withEmail: email, password: password) {  [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error != nil {
                if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error._code) {
                    switch errorCode {
                        case .invalidEmail:
                            strongSelf.resultLabel.text = "メールアドレスが正しくありません"
                            strongSelf.resultLabel.backgroundColor = UIColor.red
                        case .weakPassword:
                            strongSelf.resultLabel.text = "パスワードは７文字以上にしてください"
                            strongSelf.resultLabel.backgroundColor = UIColor.red
                        case .emailAlreadyInUse:
                            strongSelf.resultLabel.text = "このメールアドレスは既に登録されています"
                            strongSelf.resultLabel.backgroundColor = UIColor.red
                        case .networkError:
                            strongSelf.resultLabel.text = "通信障害のため登録できません"
                            strongSelf.resultLabel.backgroundColor = UIColor.red
                        default:
                            break
                    }
                }
            } else {
                // 成功した時
                strongSelf.resultLabel.text = "いらっしゃいませ！"
                strongSelf.resultLabel.backgroundColor = UIColor.blue
                strongSelf.dismiss(animated: true)
                print("登録完了")
            }
            strongSelf.createFirestoreOfUser()
        }
    }

    // FireStoreにユーザー情報を登録
    func createFirestoreOfUser() {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users").document(user.uid).setData([
                "name": userNameTextField.text ?? "",
                "email": email.text ?? "",
                "password": password.text ?? "",
                "sharedUsers": [""],
                "date": Date()

            ],completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        self.userNameTextField.text = ""
                    }
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboard()
    }

    func closeKeyboard() {
        //inputAccesoryViewに入れるtoolbar
        let toolbar = UIToolbar()
        //完了ボタンを右寄せにする為に、左側を埋めるスペース作成
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        //完了ボタンを作成
        let done = UIBarButtonItem(title: "完了",
                                   style: .done,
                                   target: self,
                                   action: #selector(didTapDoneButton))
        //toolbarのitemsに作成したスペースと完了ボタンを入れる。実際にも左から順に表示されます。
        toolbar.items = [space, done]
        toolbar.sizeToFit()
        //作成したtoolbarをtextFieldのinputAccessoryViewに入れる
        email.inputAccessoryView = toolbar
        password.inputAccessoryView = toolbar
    }
    //完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
}

