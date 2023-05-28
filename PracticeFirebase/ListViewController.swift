//
//  ListViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import UIKit
import FirebaseFirestore

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

       itemListener = Firestore.firestore().collection("users")
            .addSnapshotListener { [weak self] (querySnapshot, err) in

            guard let sSelf = self else { return }

            if err != nil {
                print("データ取得に失敗")
            } else {
                sSelf.itemModelList = querySnapshot!.documents.map{ item -> ItemModel in
                    let data = item.data()
                    return ItemModel(name: data["name"] as! String,
                                     number: data["number"] as! String,
                                     unit: data["unit"] as! String)
                }
                sSelf.itemList.reloadData()
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
        Firestore.firestore().collection("users").document("[document]").delete()

    }
}
