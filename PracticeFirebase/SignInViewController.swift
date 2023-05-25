//
//  SignInViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/24.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    
    @IBOutlet weak var mailAddress: UITextField!

    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboard()
        // Do any additional setup after loading the view.
    }

    @IBAction func signIn(_ sender: Any) {
        guard let email = mailAddress.text , let password = password.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
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
                        case .wrongPassword:
                            strongSelf.resultLabel.text = "パスワードが正しくありません"
                            strongSelf.resultLabel.backgroundColor = UIColor.red

                        case .networkError:
                            strongSelf.resultLabel.text = "通信障害のため登録できません"
                            strongSelf.resultLabel.backgroundColor = UIColor.red
                        default:
                            break
                    }
                }
            } else {
                print("成功")
                strongSelf.resultLabel.text = "成功だぞ"
                strongSelf.resultLabel.backgroundColor = UIColor.blue
                strongSelf.dismiss(animated: true)
            }
        }
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
        mailAddress.inputAccessoryView = toolbar
        password.inputAccessoryView = toolbar

    }
    //完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        mailAddress.resignFirstResponder()
        password.resignFirstResponder()
    }

    @IBAction func clear(_ sender: Any) {
        mailAddress.text = ""
        password.text = ""
        resultLabel.backgroundColor = UIColor.clear
        resultLabel.text = "メールアドレスとパスワードを入力して登録ボタンを押してね"
    }
}
