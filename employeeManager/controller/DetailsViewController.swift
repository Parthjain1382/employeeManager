//
//  DetailsViewController.swift
//  employeeManager
//
//  Created by E5000846 on 23/06/24.
//

import UIKit

class DetailsViewController: UIViewController {

    
    var empData = EmployeeStruct(name: "", emp_id: 0, emp_age: 0, profileImg: UIImage(named: "profile")!, DOB: Date())
    
    let nameField = UILabel(frame: CGRect(x: 190, y: 355, width: 183, height: 34))
    let empIdField = UILabel(frame: CGRect(x: 190, y: 448, width: 185, height: 34))
    let ageField = UILabel(frame: CGRect(x: 190, y: 543, width: 97, height: 34))
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
        setUpFormsLabel()
        setUpDetailLabel()
    }
    
    //Image view
    func setUpImageView(){
        let profileImg = UIImageView()
        profileImg.frame = CGRect(x: 104, y: 124, width: 154, height: 154)
        profileImg.image = empData.profileImg
        profileImg.layer.borderWidth = 1.0
        profileImg.layer.borderColor = UIColor.white.cgColor
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.layer.masksToBounds = true
        profileImg.clipsToBounds = true
        view.addSubview(profileImg)
    }
    
    //setting Up all forms Label
    func setUpFormsLabel(){
        let headerLB = UILabel(frame: CGRect(x: view.self.frame.size.width*0.3, y: 59, width: 347, height: 20))
        let nameLb = UILabel(frame: CGRect(x: 40, y: 360, width: 300, height: 21))
        let stdIdLb = UILabel(frame: CGRect(x: 40, y: 453, width: 300 , height: 21))
        let ageLb = UILabel(frame: CGRect(x: 40, y: 550, width: 300, height: 21))
        
        headerLB.text = "About Information"
        nameLb.text = "Name : "
        stdIdLb.text = "Student ID : "
        ageLb.text = "Age :"
        
        view.addSubview(headerLB)
        view.addSubview(nameLb)
        view.addSubview(stdIdLb)
        view.addSubview(ageLb)
    }
    
    func setUpDetailLabel(){
        
        nameField.text = empData.name
        empIdField.text = String(empData.emp_id)
        ageField.text = String(empData.emp_age)
     
        view.addSubview(nameField)
        view.addSubview(empIdField)
        view.addSubview(ageField)
    }
}
