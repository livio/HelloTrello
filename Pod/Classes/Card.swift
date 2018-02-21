//
//  Card.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation

public struct Card: Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let closed: Bool?
    public let position: Int?
    public let dueDate: Date?
    public let listId: String?
    public let memberIds: [String]?
    public let boardId: String?
    public let shortURL: String?
    public let labels: [Label]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, closed, position, labels
        case listId = "idList"
        case memberIds = "idMembers"
        case boardId = "idBoard"
        case shortURL = "shortUrl"
        case dueDate = "due"
    }
}
