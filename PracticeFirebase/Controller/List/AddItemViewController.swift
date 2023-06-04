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

    var usersListener: ListenerRegistration?

    // FireStoreのsharedUsersの配列を保持するための変数
    var sharedUsers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getSharedUsers()
        print(sharedUsers)
    }
    

    @IBAction func addItem(_ sender: Any) {
        guard (UIDevice.current.identifierForVendor?.uuidString) != nil else { return }

        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("shoppingItem").addDocument(data: [
                "name": nameTextField.text ?? "",
                "number": numberTextField.text ?? "",
                "unit": unitTextField.text ?? "",
                "owner": user.uid,
                "sharedUsers": sharedUsers,
                // ここにsharedUsersを入れる
                // まずは別のところでusersにアクセスしてsharedUsersを定数に入れて
                // その定数をここで代入する
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

    /// リストを共有しているメンバーのUIDを取得するメソッド
    func getSharedUsers() {
        // 現在ログイン中のユーザーのUIDを取得する
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(uid)
        // Firestoreのusersコレクションからログイン中のユーザーのドキュメントを取得する
        usersListener = Firestore.firestore().collection("users").document(uid)
            .addSnapshotListener { [weak self] ( documentSnapshot, err) in
                // selfをweakでキャプチャしているため、selfの値が解放された後のアクセスを防ぐ
                guard let sSelf = self else { return }
                // documentSnapshotがnilでなく、かつ存在する場合にのみ、ドキュメントからデータを取得する
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    // ドキュメントが存在する場合は、そのドキュメントからデータを取得する
                    let data = documentSnapshot.data()!
                    print(data)
                    // sharedUsersキーの値を取得する
                    sSelf.sharedUsers = data["sharedUsers"] as? [String] ?? []
                    print("再読み込み")

                } else {
                    print("現在データはありません")
                }
            }
    }
}
