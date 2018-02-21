//
//  CardList.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation

public struct CardList: Codable {
    public let id: String
    public let name: String
    public let boardId: String?
    public let pos: Int?
    public let subscribed: Bool?
    public let closed: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, pos, subscribed, closed
        case boardId = "idBoard"
    }
}
