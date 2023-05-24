//
//  ViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/22.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {


    @IBOutlet weak var editMailAddress: UITextField!


    @IBOutlet weak var editPassword: UITextField!


    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func isClear(_ sender: Any) {
        editMailAddress.text = ""
        editPassword.text = ""
        resultLabel.text = "メールアドレスとパスワードを入力して登録ボタンを押してね"
    }


    @IBAction func isRegister(_ sender: Any) {
        guard let mailAddress = editMailAddress.text,
              let password = editPassword.text else { return }


        Auth.auth().createUser(withEmail: mailAddress, password: password, completion: {(user, error) in
            // エラー処理
            if error != nil {
                print(error!)
                self.resultLabel.text = "登録失敗"
                self.resultLabel.backgroundColor = UIColor.red
                return
            }
            // 成功した時
            self.resultLabel.text = "いらっしゃいませ！"
            self.resultLabel.backgroundColor = UIColor.blue
            print("登録完了")
        })
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
        editMailAddress.inputAccessoryView = toolbar
        editPassword.inputAccessoryView = toolbar

    }
    //完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        editMailAddress.resignFirstResponder()
        editPassword.resignFirstResponder()
    }
}
