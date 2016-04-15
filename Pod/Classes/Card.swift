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
    let closed: Bool?
    let position: Int?
    let dueDate: NSDate?
    let listId: String?
    let memberIds: [String]?
    let boardId: String?
    let shortURL: String?
    let labels: [Label]?
}

extension Card: Decodable {
    private static var isoDateFormatter = Card.isoDateFormatterInit()
    
    private static func isoDateFormatterInit() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        return dateFormatter
    }
    
    public static func decode(json: AnyObject) throws -> Card {
        let dueDate: NSDate?
        
        if let jsonDate = try json =>? "due" as! String? {
            dueDate = Card.isoDateFormatter.dateFromString(jsonDate)
        } else {
            dueDate = nil
        }
        
        return try Card(id: json => "id",
                        name: json => "name",
                        description: json =>? "description",
                        closed: json =>? "closed",
                        position: json =>? "position",
                        dueDate: dueDate,
                        listId: json =>? "idList",
                        memberIds: json =>? "idMembers",
                        boardId: json =>? "idBoard",
                        shortURL: json =>? "shortUrl",
                        labels: json =>? "labels")
    }
}
