//
//  WordEntity2+CoreDataProperties.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 2/16/25.
//
//

import Foundation
import CoreData


extension WordEntity2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordEntity2> {
        return NSFetchRequest<WordEntity2>(entityName: "WordEntity2")
    }

    @NSManaged public var name: String?

}

extension WordEntity2 : Identifiable {

}
