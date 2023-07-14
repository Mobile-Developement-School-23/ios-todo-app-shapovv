//
//  Model+CoreDataProperties.swift
//  todo
//
//  Created by Артём Шаповалов on 14.07.2023.
//
//

import Foundation
import CoreData


extension Model {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Model> {
        return NSFetchRequest<Model>(entityName: "Model")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var importance: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var modificationDate: Date?

}

extension Model : Identifiable {

}
