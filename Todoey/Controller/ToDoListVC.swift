//
//  ViewController.swift
//  Todoey
//
//  Created by user137691 on 2/4/19.
//  Copyright © 2019 user137691. All rights reserved.
//

import UIKit
import CoreData
class ToDoListVC: UITableViewController,UISearchBarDelegate
{
    var itemsArray=[Item]()
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    loadItems()
        tableView.tableFooterView=UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item=itemsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text=item.title
        cell.accessoryType =   item.checked ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsArray[indexPath.row].checked = !itemsArray[indexPath.row].checked
        saveItem()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        let alert=UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        var textEntered=UITextField()
        let action=UIAlertAction(title: "Ok", style: .default) { (action) in
            let item=Item(context: self.context)
            item.title=textEntered.text
            self.itemsArray.append(item)
            
            self.saveItem()
        }
        alert.addTextField { (textField) in
            textEntered=textField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    func saveItem(){
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        tableView.reloadData()
    }
    func loadItems(){
        let request:NSFetchRequest<Item>=Item.fetchRequest()
        do{
        itemsArray=try context.fetch(request)
        }catch{
            
        }
    }
  //make swipe cell
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
   /* override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            context.delete(itemsArray[indexPath.row])
            itemsArray.remove(at: indexPath.row)
            saveItem()
        }
       
    }*/
   // If you want to show Edit button also with Delete button then you need to implement editActionsForRowAt method with canEditRowAt method instead of commit editingStyle.

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.itemsArray[indexPath.row].title
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.itemsArray[indexPath.row].title = alert.textFields!.first!.text!
                self.saveItem()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        editAction.backgroundColor=UIColor.green
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.context.delete(self.itemsArray[indexPath.row])
            self.itemsArray.remove(at: indexPath.row)
            self.saveItem()
        })
        
        return [deleteAction,editAction]
    }
    //if you need swipe action to appear on thr right of the cell.
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit=UIContextualAction(style: .normal, title: "Edit") { (ac, view, success) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.itemsArray[indexPath.row].title
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.itemsArray[indexPath.row].title = alert.textFields!.first!.text!
                self.saveItem()
            }))
        //    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                tableView.isEditing=false
            }))
            self.present(alert, animated: false)
        }
        edit.backgroundColor=UIColor.green
        return UISwipeActionsConfiguration(actions:[edit])
    }
}

