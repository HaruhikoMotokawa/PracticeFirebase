//
//  ListViewController.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {


    let db = Firestore.firestore()

    var itemModelList: [ItemModel] = []

    @IBOutlet weak var itemList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        itemList.dataSource = self
        itemList.delegate = self

        itemList.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        itemList.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        let itemModelList = itemModelList[indexPath.row]
        cell.setItem(name: itemModelList.name, number: itemModelList.number, unit: itemModelList.unit)
        return cell
    }
}

extension ListViewController: UITableViewDelegate {}
