import UIKit
import CoreData
import Foundation

class FormViewController: UIViewController {
    
    var isUpdateMode = false
    var updateArr = EmployeeStruct(name: "", emp_id: 0, emp_age: 0, profileImg: UIImage(named: "profile")!, DOB: Date())
    
    @IBOutlet weak var imageView: UIImageView!
    
    let headerLB = UILabel(frame: CGRect(x: 130, y: 59, width: 347, height: 20))
    let nameLb = UILabel(frame: CGRect(x: 40, y: 360, width: 69, height: 21))
    let empId = UILabel(frame: CGRect(x: 40, y: 453, width: 128 , height: 21))
    let dateLb = UILabel(frame: CGRect(x: 40, y: 550, width: 128, height: 21))
    
    let imageBtn = UIButton(frame: CGRect(x: 97, y: 140, width: 184, height: 132))
    
    let nameTxt = UITextField(frame: CGRect(x: 165, y: 355, width: 183, height: 34))
    let empIdTxt = UITextField(frame: CGRect(x: 165, y: 448, width: 185, height: 34))
    let datePicker = UIDatePicker(frame: CGRect(x: 90, y: 543, width: 70, height: 34))
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
        setUpFormsLabel()
        setUpTextView()
        settingUpImageBtn()
        setUpDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSubmitButton()
    }
    
    func setUpImageView() {
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        if isUpdateMode {
            imageView.image = updateArr.profileImg
        }
    }
    
    // Setting Up all forms Label
    func setUpFormsLabel() {
        headerLB.text = isUpdateMode ? "Update Employee" : "Add New Employee"
        nameLb.text = "Name : "
        empId.text = "Employee ID : "
        dateLb.text = "DOB :"
        
        view.addSubview(headerLB)
        view.addSubview(nameLb)
        view.addSubview(empId)
        view.addSubview(dateLb)
    }
    
    // Setting up the text Views
    func setUpTextView() {
        nameTxt.borderStyle = .roundedRect
        nameTxt.textAlignment = .left
        nameTxt.clearButtonMode = .whileEditing
        nameTxt.font = UIFont.systemFont(ofSize: 14)
        
        empIdTxt.borderStyle = .roundedRect
        empIdTxt.textAlignment = .left
        empIdTxt.clearButtonMode = .whileEditing
        empIdTxt.font = UIFont.systemFont(ofSize: 14)
        
        if isUpdateMode {
            nameTxt.text = updateArr.name
            empIdTxt.text = String(updateArr.emp_id)
        } else {
            nameTxt.placeholder = "Enter your Name"
            empIdTxt.placeholder = "Enter your Employee Id"
        }
        
        view.addSubview(nameTxt)
        view.addSubview(empIdTxt)
    }
    
    func setUpDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.maximumDate = .now
        datePicker.backgroundColor = .white
        datePicker.calendar = .current
        datePicker.date = isUpdateMode ? updateArr.DOB : Date()
        
        view.addSubview(datePicker)
    }
    
    func setUpSubmitButton() {
        let btn = UIButton(frame: CGRect(x: 159, y: 705, width: 75, height: 35))
        if isUpdateMode {
            btn.addTarget(self, action: #selector(updateEmp), for: .touchUpInside)
            btn.setTitle("Update", for: .normal)
            btn.backgroundColor = .systemMint
            btn.setTitleColor(.systemGray2, for: .highlighted)
        } else {
            btn.addTarget(self, action: #selector(dataTransfer), for: .touchUpInside)
            btn.setTitle("Submit", for: .normal)
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.systemGray2, for: .highlighted)
        }
        view.addSubview(btn)
    }
    
    // Setting up the submit button
    func settingUpImageBtn() {
        let imageBtn = UIButton(frame: CGRect(x: 97, y: 135, width: 184, height: 132))
        imageBtn.addTarget(self, action: #selector(imagePicker), for: .touchUpInside)
        imageBtn.setTitle("Change Image", for: .normal)
        imageBtn.backgroundColor = .systemBlue
        imageBtn.setImage(.add, for: .normal)
        imageBtn.backgroundColor = .none
        imageBtn.setTitleColor(.systemGray2, for: .highlighted)
        view.addSubview(imageBtn)
    }
    
    @objc func imagePicker() {
        let photoVc = UIImagePickerController()
        photoVc.sourceType = .photoLibrary
        photoVc.delegate = self
        photoVc.allowsEditing = true
        present(photoVc, animated: true)
    }
    
    // Adding the new employee to the coredata
    @objc func dataTransfer() {
        if validateID() && validateName() {
            let emp = Employee(context: self.context)
            
            guard let empIdText = empIdTxt.text, !empIdText.isEmpty,
                  let name = nameTxt.text, !name.isEmpty,
                  let image = imageView.image else {
                showAction("Fill Details", "Please Fill all the text Field Properly")
                return
            }
            
            if let defaultImage = UIImage(named: "profile"),
               let defaultImageData = defaultImage.pngData(),
               let selectedImageData = image.pngData(),
               defaultImageData == selectedImageData {
                showAction("Select Image", "Please Select an Image")
                return
            }
            
            let imageData: Data? = image.jpegData(compressionQuality: 1.0)
            emp.name = name
            emp.emp_id = Int64(empIdTxt.text!) ?? 0
            emp.emp_age = Int64(calculateAge(from: datePicker.date))
            emp.profileImg = imageData
            emp.dob = datePicker.date
            
            do {
                try context.save()
                showAction("Saved Successfully", "The new employee has been successfully registered")
            } catch {
                showAction("Not saved", "The new student Can't be added, try Again.")
            }
        }
    }
    
    @objc func updateEmp() {
        if validateID() && validateName() {
            guard let empIdText = empIdTxt.text, !empIdText.isEmpty,
                  let name = nameTxt.text, !name.isEmpty,
                  let image = imageView.image else {
                showAction("Fill Details", "Please Fill all the text Field Properly")
                return
            }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Employee")
            fetchRequest.predicate = NSPredicate(format: "emp_id == %d", updateArr.emp_id)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let empToUpdate = results.first as? NSManagedObject {
                    empToUpdate.setValue(name, forKey: "name")
                    empToUpdate.setValue(Int64(empIdTxt.text!) ?? 0, forKey: "emp_id")
                    empToUpdate.setValue(Int64(calculateAge(from: datePicker.date)), forKey: "emp_age")
                    empToUpdate.setValue(image.jpegData(compressionQuality: 1.0), forKey: "profileImg")
                    empToUpdate.setValue(datePicker.date, forKey: "dob")
                    
                    try context.save()
                    showAction("Updated Successfully", "The employee details have been successfully updated")
                }
            } catch {
                showAction("Update Failed", "Failed to update the employee details")
                print("Failed to fetch employee: \(error)")
            }
        }
    }
    
    // Calculate the age from the current date
    func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        return ageComponents.year ?? 0
    }
    
    func validateID() -> Bool {
        guard let id = empIdTxt.text, !id.isEmpty else {
            showAction("Enter Id", "ID cannot be empty.")
            return false
        }
        guard let _ = Int(id) else {
            showAction("Numeric Id", "Please enter a numeric ID.")
            return false
        }
        return true
    }
    
    func validateName() -> Bool {
        guard let name = nameTxt.text, !name.isEmpty else {
            showAction("Enter Name", "Name cannot be empty.")
            return false
        }
        let nameCharacterSet = CharacterSet.letters.union(CharacterSet.whitespaces)
        if name.rangeOfCharacter(from: nameCharacterSet.inverted) != nil {
            showAction("Enter valid Credentials", "Please enter a valid name (alphabetic characters only).")
            return false
        }
        return true
    }
    
    func showAction(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate Methods
extension FormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
