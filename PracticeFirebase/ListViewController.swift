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

    var itemListener: ListenerRegistration?

    var itemModelList: [ItemModel] = []

    @IBOutlet weak var itemList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        itemList.dataSource = self
        itemList.delegate = self

        itemList.register(UINib(nibName: "CustomTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "CustomTableViewCell")

        guard Auth.auth().currentUser != nil else { return }
        itemListener = Firestore.firestore().collection("shoppingItem")
            .addSnapshotListener { [weak self] (querySnapshot, err) in

                guard let sSelf = self else { return }

                if err != nil {
                    print("データ取得に失敗")
                } else {
                    if let querySnapshot = querySnapshot {
                        sSelf.itemModelList = querySnapshot.documents.map{ item -> ItemModel in
                            let data = item.data()
                            return ItemModel(id: item.documentID,
                                             name: data["name"] as? String ?? "",
                                             number: data["number"] as? String ?? "",
                                             unit: data["unit"] as? String ?? "")
                        }
                        sSelf.itemList.reloadData()
                    } else {
                        print("現在データはありません")
                    }
                }
            }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated )
        if let mUnsubscribe = itemListener { mUnsubscribe.remove() }
    }

    @IBAction func sharedItem(_ sender: Any) {
    }


    @IBAction func addItem(_ sender: Any) {
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModelList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell

        let itemModelList = itemModelList[indexPath.row]
        cell.setItem(name: itemModelList.name, number: itemModelList.number, unit: itemModelList.unit)
        return cell
    }
}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルのインデックスを取得
        let selectedRowIndex = indexPath.row
        // 選択されたセルに対応するドキュメントIDを取得
        let documentID = itemModelList[selectedRowIndex].id ?? ""
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
