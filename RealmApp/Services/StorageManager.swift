//
//  StorageManager.swift
//  RealmApp
//
//  Created by Victor on 29.01.2022.
//

import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
// MARK: - Task List
    func save(_ taskLists: [TaskList]) {
        try! realm.write{
            realm.add(taskLists)
        }
    }
    
    func save(_ taskLists: TaskList) {
        write {
            realm.add(taskLists)
        }
    }

    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }

    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
// MARK: - Tasks
    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(_ task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(_ task: Task, newTitle: String) {
        write {
            task.name = newTitle
        }
    }
    
    func done(_ task: Task) {
        write {
            task.setValue(true, forKey: "isComplete")
        }
    }
    
    func undo(_ task: Task) {
        write {
            task.setValue(false, forKey: "isComplete")
        }
    }
    
    private func write(comletion: () -> Void) {
        do {
            try realm.write {
                comletion()
            }
        } catch {
            print(error)
        }
    }

}
