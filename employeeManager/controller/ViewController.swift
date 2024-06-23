import UIKit
import CoreData

class ViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    var empArr = [EmployeeStruct]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
              
        fetchPath()
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch new data
        ReadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReadData()
    }
     
    // Reading the data from the sqlite storage
    func ReadData() {
        empArr.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let tempEmp = EmployeeStruct(name: data.value(forKey: "name") as! String,
                                             emp_id: data.value(forKey: "emp_id") as! Int64,
                                             emp_age: data.value(forKey: "emp_age") as! Int64,
                                             profileImg: UIImage(data: data.value(forKey: "profileImg") as! Data)!, DOB: data.value(forKey: "dob") as? Date ?? Date())
                empArr.append(tempEmp)
            }
            tableView.reloadData()
            refreshControl.endRefreshing() // End the refreshing animation
        } catch {
            print("Not able to get the data")
            refreshControl.endRefreshing() // End the refreshing animation even if there's an error
        }
    }
 
    //alert for update and delete
    func showAlert(_ title: String, _ message : String, completion: @escaping(Bool)-> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Yes", style: .default){(action) in
           completion(true)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel){
            (action) in
            completion(false)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert,animated: true)
    }
    
    func showAction(_ title:String ,_ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
}

//MARK: - UITableViewDelegate for the table view
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //update Functionality
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete 🗑️") { (action, view, completionHandler) in
            
            self.showAlert("Confirm Delete", "Do you really want to Delete this employee data ") { userDidConfirm in
                if userDidConfirm {
                    debugPrint("delete row\(indexPath.row)")
                    self.deleteEmp(indexPath.row)
                    completionHandler(true)
                }
            }
            
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    //delete Functionality
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updateAction = UIContextualAction(style: .normal, title: "📝 Update") { (action, view, completionHandler) in
            
            self.showAlert("Confirm Update", "Do you really want to navigate to update the Employee") { userDidConfirm in
                if userDidConfirm {
                    debugPrint("update row\(indexPath.row)")
                
                    let vc = UIStoryboard(name: "Main", bundle: nil)
                    if let formVc = vc.instantiateViewController(withIdentifier: "FormViewController") as? FormViewController{
                        formVc.isUpdateMode = true
                        formVc.updateArr = self.empArr[indexPath.row]
                        self.navigationController?.pushViewController(formVc, animated: true)
                    }
                    
                    completionHandler(true)
                }
            }
        }
        updateAction.backgroundColor = .systemBlue
        let configuration = UISwipeActionsConfiguration(actions: [updateAction])
        return configuration
    }
    
    //Deleting the employee in the core data
    func deleteEmp(_ rowNumber: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        
        
        let nameToFetch = empArr[rowNumber].name
        let ageToFetch = empArr[rowNumber].emp_age
        let idToFetch = empArr[rowNumber].emp_id
        
        // Set the predicate with the correct arguments
        let predicate = NSPredicate(format: "name == %@ AND emp_age == %d AND emp_id == %d", nameToFetch, ageToFetch, idToFetch)
        fetchRequest.predicate = predicate
        
        do {
            let emp = try managedContext.fetch(fetchRequest)
            
            if let objectToDelete = emp.first as? NSManagedObject {
                managedContext.delete(objectToDelete)
                
                do {
                    try managedContext.save()
                    empArr.remove(at: rowNumber)
                    tableView.deleteRows(at: [IndexPath(row: rowNumber, section: 0)], with: .fade)
                    showAction("Succesfully Deleted", "The data has been successfully deleted")
                } catch {
                    print("Failed to save context after deletion: \(error)")
                    showAction("Delete Failed", "Failed to Delete the data")
                }
            } else {
                print("No matching employee found to delete.")
            }
        } catch {
            print("Failed to fetch employee: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
        let detailVc = vc.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        detailVc.empData = empArr[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
    func reloadTableViewWithAnimation() {
         tableView.performBatchUpdates({
             let indexSet = IndexSet(integersIn: 0..<tableView.numberOfSections)
             tableView.reloadSections(indexSet, with: .automatic)
         }, completion: nil)
     }
    
}

//MARK: -UITableViewDataSource for the Employee tableView
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return empArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableEmpTableViewCell.identifier, for: indexPath) as! tableEmpTableViewCell
        cell.nameLb.text = empArr[indexPath.row].name
        cell.profImg.image = empArr[indexPath.row].profileImg
        return cell
    }
}


extension ViewController {
 
//     Checking if the file Path is present or not
    func fetchPath() {
        if let filePath = getCoreDataSQLiteFilePath() {
            debugPrint("Core Data SQLite file path: \(filePath)")
        } else {
            debugPrint("Failed to retrieve Core Data SQLite file path.")
        }
    }
    
//     Function to get the path
    func getCoreDataSQLiteFilePath() -> String? {
        guard let persistentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer else {
            return nil
        }
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        let url = storeDescription?.url
        return url?.path
    }
}
