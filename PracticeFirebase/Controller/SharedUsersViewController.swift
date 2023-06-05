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

    @IBOutlet weak var addSharedUsersButton: UIButton!


    var usersListener: ListenerRegistration?

    // FireStoreのsharedUsersの配列を保持するための変数
    var sharedUsers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSharedUsers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usersListener?.remove()
    }

    @IBAction func deletedSharedUIDOne(_ sender: Any) {
        deletedSharedUID(deleteUID: 0)
    }

    @IBAction func deletedSharedUIDTwo(_ sender: Any) {
        deletedSharedUID(deleteUID: 1)
    }

    @IBAction func deletedSharedUIDThree(_ sender: Any) {
        deletedSharedUID(deleteUID: 2)
    }

    @IBAction func addSharedUsers(_ sender: Any) {
        print("ボタンが押されて処理が開始されました")
        guard inputUIDTextField.text != "" else {
            print("uidを入力してね")
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
            guard (querySnapshot?.documents.first) != nil else {
                print("実在しません")
                return
            }

            let userRef = usersRef.document(uid)
            userRef.updateData(["sharedUsers": FieldValue.arrayUnion([inputUID])]) { err in
                if err != nil {
                    print("登録できませんでした")
                } else {
                    print("登録成功だよ")
                    sSelf.inputUIDTextField.text = ""
                }
            }
        }
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

    /// 共有アカウントを表示するメソッド
    func setSharedUsers() {
        getSharedUsers(completion: { [weak self] in
            guard let sSelf = self else { return }
            // sharedUsers配列の数によってラベルの表示と削除ボタンを切り替える
            switch sSelf.sharedUsers.count {
                case 1:
                    sSelf.changeUserName(sharedUsersUID: sSelf.sharedUsers[0], label: sSelf.firstSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: nil, label: sSelf.secondSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: nil, label: sSelf.thirdSharedUsersLabel)

                case 2:
                    sSelf.changeUserName(sharedUsersUID: sSelf.sharedUsers[0], label: sSelf.firstSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: sSelf.sharedUsers[1], label: sSelf.secondSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: nil, label: sSelf.thirdSharedUsersLabel)

                case 3:
                    sSelf.changeUserName(sharedUsersUID: sSelf.sharedUsers[0], label: sSelf.firstSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: sSelf.sharedUsers[1], label: sSelf.secondSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: sSelf.sharedUsers[2], label: sSelf.thirdSharedUsersLabel)

                default:
                    sSelf.changeUserName(sharedUsersUID: nil, label: sSelf.firstSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: nil, label: sSelf.secondSharedUsersLabel)
                    sSelf.changeUserName(sharedUsersUID: nil, label: sSelf.thirdSharedUsersLabel)
            }
            sSelf.deleteOneButton.isEnabled = sSelf.sharedUsers.count >= 1
            sSelf.deleteTwoButton.isEnabled = sSelf.sharedUsers.count >= 2
            sSelf.deleteThreeButton.isEnabled = sSelf.sharedUsers.count >= 3
        })
    }

    /// リストを共有しているメンバーのUIDを取得するメソッド
    func getSharedUsers(completion: @escaping () -> Void) {
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
                    completion()
                } else {
                    print("現在データはありません")
                }
            }
    }

    /// 登録されているUIDを登録されているnameに変換するメソッド
    func changeUserName(sharedUsersUID: String?, label: UILabel) {
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

    /// 共有アカウント登録の削除メソッド、引数に
    /// 引数に削除する配列の番号を入力
    func deletedSharedUID (deleteUID: Int) {
        // 現在ログインしているユーザーの「uid」をuidに宣言、ログインしていなければ抜ける
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // usersコレクションの自分のドキュメントにアクセス
        let docRef = Firestore.firestore().collection("users").document(uid)
        // 保じたsharedUsers配列から指定した値を削除
        sharedUsers.remove(at: deleteUID)
        // 新たに更新したsharedUsersで上書き
        docRef.updateData([
            "sharedUsers": sharedUsers
        ]) { error in
            if error != nil {
                print("共有相手の削除に失敗")
            } else {
                print("共有相手の削除に成功")
            }
        }
    }


}
