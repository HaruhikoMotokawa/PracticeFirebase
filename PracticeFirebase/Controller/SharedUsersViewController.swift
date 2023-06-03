//
//  SharedUsersViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/31.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class SharedUsersViewController: UIViewController {


    @IBOutlet weak var firstSharedUsersLabel: UILabel!

    @IBOutlet weak var secondSharedUsersLabel: UILabel!

    @IBOutlet weak var thirdSharedUsersLabel: UILabel!

    @IBOutlet weak var deleteOneButton: UIButton!

    @IBOutlet weak var deleteTwoButton: UIButton!

    @IBOutlet weak var deleteThreeButton: UIButton!

    @IBOutlet weak var inputUIDTextField: UITextField!


    var usersListener: ListenerRegistration?

    var usersList: [UserModel] = []

    var sharedUsers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboard()
        deleteOneButton.isEnabled = false
        deleteTwoButton.isEnabled = false
        deleteThreeButton.isEnabled = false
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSharedUsers(completion: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.setUserName(sharedUsersUID: sSelf.firstSharedUsersLabel.text, label: sSelf.firstSharedUsersLabel)
            sSelf.setUserName(sharedUsersUID: sSelf.secondSharedUsersLabel.text, label: sSelf.secondSharedUsersLabel)
            sSelf.setUserName(sharedUsersUID: sSelf.thirdSharedUsersLabel.text, label: sSelf.thirdSharedUsersLabel)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usersListener?.remove()
    }

    @IBAction func deletedSharedUIDOne(_ sender: Any) {
        deletedSharedUID(deleteNumber: 0)
        deleteOneButton.isEnabled = false
    }

    @IBAction func deletedSharedUIDTwo(_ sender: Any) {
        deletedSharedUID(deleteNumber: 1)
        deleteTwoButton.isEnabled = false
    }

    @IBAction func deletedSharedUIDThree(_ sender: Any) {
        deletedSharedUID(deleteNumber: 2)
        deleteThreeButton.isEnabled = false
    }

    @IBAction func addSharedUsers(_ sender: Any) {
        print("ボタンが押されて処理が開始されました")
        guard inputUIDTextField.text != "" else {
            print("uidがからです")
            return
        }
        guard let uid = Auth.auth().currentUser?.uid, let inputUID = inputUIDTextField.text else {
            print("追加できません、ログインしてください")
            return
        }
        let usersRef = Firestore.firestore().collection("users")
        let inputUserQuery = usersRef.whereField(FieldPath.documentID(), isEqualTo: inputUID)

        inputUserQuery.getDocuments { [weak self] (querySnapshot, error) in
            // selfをweakでキャプチャしているため、selfの値が解放された後のアクセスを防ぐ
            guard let sSelf = self else { return }
            if error != nil {
                print("エラー")
                return
            }
            guard let doc = querySnapshot?.documents.first else {
                print("実在しません")
                return
            }
            sSelf.sharedUsers = doc.data()["sharedUsers"] as? [String] ?? []

            let userRef = usersRef.document(uid)
            userRef.updateData(["sharedUsers": FieldValue.arrayUnion(sSelf.sharedUsers)]) { err in
                if err != nil {
                    print("登録できませんでした")
                } else {
                    print("登録成功だよ")
                    sSelf.inputUIDTextField.text = ""
                }
            }
        }
    }


    @IBAction func confirmationSharedUsers(_ sender: Any) {
        setUserName(sharedUsersUID: firstSharedUsersLabel?.text, label: firstSharedUsersLabel)
    }
    // キーボード閉じるボタンセット
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
        inputUIDTextField.inputAccessoryView = toolbar
    }
    //完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        inputUIDTextField.resignFirstResponder()
    }

    /// リストを共有しているメンバーのUIDを取得するメソッド
    func setSharedUsers(completion: @escaping () -> Void) {
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
                    let sharedUsers = data["sharedUsers"] as? [String] ?? []
                    if sharedUsers.count >= 1 {
                        sSelf.firstSharedUsersLabel.text = sharedUsers[0]
                        sSelf.deleteOneButton.isEnabled = true
                    }
                    if sharedUsers.count >= 2 {
                        sSelf.secondSharedUsersLabel.text = sharedUsers[1]
                        sSelf.deleteTwoButton.isEnabled = true
                    }
                    if sharedUsers.count >= 3 {
                        sSelf.thirdSharedUsersLabel.text = sharedUsers[2]
                        sSelf.deleteThreeButton.isEnabled = true
                    }
                        print("再読み込み")
                    completion()
                } else {
                    print("現在データはありません")
                }
            }
    }

    func setUserName(sharedUsersUID: String?, label: UILabel) {
        // sharedUsersUIDがnilの場合はラベルの表示を変更して終了
        guard let sharedUsersUID = sharedUsersUID else {
            label.text = "現在登録なし"
            print("現在登録はなしなので抜けます")
            return
        }
        //FirestoreのusersコレクションからsharedUsersUIDに該当するドキュメントを取得
        let userDocRef = Firestore.firestore().collection("users").document(sharedUsersUID)
        print(userDocRef)
        // ドキュメントを取得する
        userDocRef.getDocument { [weak self](documentSnapshot, error) in
            guard self != nil else { return }
            // ドキュメントが存在し、エラーがない場合にのみ処理を行う
            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                // 取得したデータから"name"プロパティの値を取得する
                let name = documentSnapshot.get("name") as! String
                label.text = name
            }
        }
    }

    /// 共有アカウント登録の削除
    /// 引数に削除する配列の番号を入力
    func deletedSharedUID (deleteNumber: Int) {
        // 現在ログインしているユーザーの「uid」をuidに宣言、ログインしていなければ抜ける
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // usersコレクションの自分のドキュメントにアクセス
        let docRef = Firestore.firestore().collection("users").document(uid)
        // 値の追加
        docRef.updateData([
            "sharedUsers": FieldValue.arrayRemove([sharedUsers[deleteNumber]])
        ]) { error in
            if error != nil {
                print("共有相手の削除に失敗")
            } else {
                print("共有相手の削除に成功")
            }
        }
    }


}
