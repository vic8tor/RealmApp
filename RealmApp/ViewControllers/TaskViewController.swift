//
//  TaskViewController.swift
//  RealmApp
//
//  Created by Victor on 29.01.2022.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
      
    // MARK: - Private Properties
    var taskList: TaskList!
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentTask = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            StorageManager.shared.delete(currentTask)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
            self.showAlert(with: currentTask) {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
            completion(true)
        }
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, completion in
            StorageManager.shared.done(currentTask)
            tableView.reloadData()
            completion(true)
        }

        deleteAction.backgroundColor = .red
        editAction.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
        editAction.image = UIImage(systemName: "square.and.pencil")
        deleteAction.image = UIImage(systemName: "trash.fill")
    
        return UISwipeActionsConfiguration(actions: [doneAction, deleteAction, editAction] )
    }
    
    private func alertAction(style: UIContextualAction.Style, and title: String, completion: () -> ()) -> UIContextualAction {
        let action = UIContextualAction(style: style, title: title) { _, _, completion in
            completion(true)
        }
        return action
    }
}

// MARK: - Extension
extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.rename(task, newTitle: newValue)
                completion()
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task, to: taskList)

        let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}
