//
//  ViewController.swift
//  CRUDCoreData
//
//  Created by Yashraj on 04/02/26.
//

import CoreData
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tblListItem: UITableView!
    //Core data conncetion
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext

    //array datasource of Entity
    var listItemArry: [ListItems] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Shopping List 🛍️"

        tblListItem.dataSource = self
        tblListItem.delegate = self
        tblListItem.clipsToBounds = true
        //Load store items
        loadSavedItems()
    }

    @IBAction func btnAddItem(_ sender: UIBarButtonItem) {
        showAlert(title: "Add item 🛒")
    }

    // MARK: - Show alert (Add / Edit)
    func showAlert(title: String, itemToEdit: ListItems? = nil) {
        var textField = UITextField()
        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "Enter item name"
            tf.text = itemToEdit?.name  // prefill for edit
            textField = tf
        }

        let actionTitle = itemToEdit == nil ? "Add" : "Update"
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            guard let text = textField.text, !text.isEmpty else { return }

            if let item = itemToEdit {
                // Edit existing item
                item.name = text
            } else {
                // ➕ Add new item
                let newItem = ListItems(context: self.context)
                newItem.name = text
                self.listItemArry.append(newItem)
            }

            self.saveData()
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    //MARK: Try save data method
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data\(error)")
        }
        tblListItem.reloadData()
    }

    //MARK: Load stored items
    func loadSavedItems() {
        //NSFetchRequest query to get data
        let request: NSFetchRequest<ListItems> = ListItems.fetchRequest()
        do {
            listItemArry = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
    }
}
//MARK: Extenion to implement tabledatasource and delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return listItemArry.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )
        cell.textLabel?.text = listItemArry[indexPath.row].name
        return cell
    }

    //MARK: Edit on tap
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedItem = listItemArry[indexPath.row]
        showAlert(title: "Edit Item ✏️", itemToEdit: selectedItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Swipe to delete func
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            //Delete from core data
            context.delete(listItemArry[indexPath.row])

            //delete from our arry
            listItemArry.remove(at: indexPath.row)

            saveData()
        }
    }

}
