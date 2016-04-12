//
//  Card.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Card {
    let id: String
    let name: String
    let description: String?
    let url: String?
    let closed: Bool?
    let position: Int?
    let dueDate: NSDate?
    let members: [Member]?
    let labels: [Label]?
}

extension Card: Decodable {
    public static func decode(json: AnyObject) throws -> Card {
        var date: NSDate?
        if let jsonDate = try json =>? "date" as! String? {
            date = try NSDateFormatter().dateFromString(jsonDate)
        } else {
            date = nil
        }
        
        return try Card(id: json => "id",
                        name: json => "name",
                        description: json =>? "description",
                        url: json =>? "url",
                        closed: json =>? "closed",
                        position: json =>? "position",
                        dueDate: date,
                        members: json =>? "members",
                        labels: json =>? "labels")
    }
}
