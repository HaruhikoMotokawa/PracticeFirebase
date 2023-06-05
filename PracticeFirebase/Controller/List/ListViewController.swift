//
//  ListViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ListViewController: UIViewController {

    @IBOutlet weak var itemList: UITableView!

    /// 自分自身のドキュメント監視
    var myItemListener: ListenerRegistration?

    /// 自身を共有相手に登録したユーザーのドキュメント作成を監視
    var otherItemListener: ListenerRegistration?

    /// 自分が作成したshoppingコレクションのドキュメントを保持する配列
    var myItemModelList: [ItemModel] = []

    /// 自身を共有相手に登録したユーザーが
    /// 作成したshoppingコレクションのドキュメントを保持する配列
    var otherItemModelList: [ItemModel] = []

    /// 自分と相手のshoppingコレクションのドキュメント配列を合わせた配列
    var shoppingItemList: [ItemModel] {
        return myItemModelList + otherItemModelList
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomCell()
        getMyShoppingItem()
        getOtherShoppingItem()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated )
        if let mUnsubscribe = myItemListener { mUnsubscribe.remove() }
        if let mUnsubscribe = otherItemListener { mUnsubscribe.remove() }
    }

    @IBAction func sharedItem(_ sender: Any) {
    }

    @IBAction func addItem(_ sender: Any) {
    }

    func setCustomCell() {
        itemList.dataSource = self
        itemList.delegate = self
        itemList.register(UINib(nibName: "CustomTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "CustomTableViewCell")
    }
    /// 自分が作成したドキュメントをFireStoreから取得して配列に保持するメソッド
    /// - 認証確認
    /// - データをItemModelの配列にマッピング
    /// - tableViewをリロード
    func getMyShoppingItem() {
        // ユーザーがログインしているかチェック
        guard Auth.auth().currentUser != nil else { return }
        // 現在ログインしているユーザー情報を取得
        guard let currentUser = Auth.auth().currentUser else { return }
        // 自分が作成したドキュメントのリスナーを設定
        myItemListener = Firestore.firestore().collection("shoppingItem")
            .whereField("owner", isEqualTo: currentUser.uid)
            .addSnapshotListener { [weak self] (querySnapshot, err) in
                // 参照を弱参照にする
                guard let sSelf = self else { return }

                if err != nil {
                    print("データ取得に失敗: \(err!)")
                } else {
                    if let querySnapshot = querySnapshot {
                        // データをItemModelの配列にマッピング
                        sSelf.myItemModelList = querySnapshot.documents.map{ item -> ItemModel in
                            let data = item.data()
                            return ItemModel(id: item.documentID,
                                             name: data["name"] as? String ?? "",
                                             number: data["number"] as? String ?? "",
                                             unit: data["unit"] as? String ?? "",
                                             owner: data["owner"] as? String ?? "")
                        }
                        // 配列の要素をnumberでソート
                        sSelf.myItemModelList.sort { $0.number < $1.number }
                        // tableViewをリロード
                        sSelf.itemList.reloadData()
                        print("再読み込み")
                    } else {
                        print("現在データはありません")
                    }
                }
            }
    }

    /// 自分を共有相手に登録しているユーザーがドキュメントを更新した場合にFireStoreから取得して配列に保持するメソッド
    func getOtherShoppingItem() {
        // ユーザーがログインしているかチェック
        guard Auth.auth().currentUser != nil else { return }
        // 現在ログインしているユーザー情報を取得
        guard let currentUser = Auth.auth().currentUser else { return }
        // 共有されたドキュメントのリスナーを設定
        otherItemListener = Firestore.firestore().collection("shoppingItem")
            .whereField("sharedUsers", arrayContains: currentUser.uid)
            .addSnapshotListener { [weak self] (querySnapshot, err) in
                // 参照を弱参照にする
                guard let sSelf = self else { return }
                if err != nil {
                    print("データ取得に失敗: \(err!)")
                } else {
                    if let querySnapshot = querySnapshot {
                        // データをItemModelの配列にマッピング
                        sSelf.otherItemModelList = querySnapshot.documents.map{ item -> ItemModel in
                            let data = item.data()
                            return ItemModel(id: item.documentID,
                                             name: data["name"] as? String ?? "",
                                             number: data["number"] as? String ?? "",
                                             unit: data["unit"] as? String ?? "",
                                             owner: data["owner"] as? String ?? "")
                        }
                        // 配列の要素をnumberでソート
                        sSelf.otherItemModelList.sort { $0.number < $1.number }
                        // tableViewをリロード
                        sSelf.itemList.reloadData()
                        print("再読み込み")
                    } else {
                        print("現在データはありません")
                    }
                }
            }
    }

}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell

        let itemModelList = shoppingItemList[indexPath.row]
        cell.setItem(name: itemModelList.name, number: itemModelList.number, unit: itemModelList.unit)
        return cell
    }

}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルのインデックスを取得
        let selectedRowIndex = indexPath.row
        // 選択されたセルに対応するドキュメントIDを取得
        let documentID = shoppingItemList[selectedRowIndex].id ?? ""
        // ドキュメントを参照して削除する
        Firestore.firestore().collection("shoppingItem").document(documentID).delete() { err in
            if err != nil {
                print("Error removing document: \\(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
