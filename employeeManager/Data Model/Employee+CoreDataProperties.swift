//
//  Employee+CoreDataProperties.swift
//  employeeManager
//
//  Created by E5000846 on 19/06/24.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var profileImg: Data?
    @NSManaged public var name: String?
    @NSManaged public var emp_id: Int64
    @NSManaged public var emp_age: Int64

}

extension Employee : Identifiable {

}
