//
//  Board.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation

public struct Boards: Codable {
    public let boards: [Board]
}

public struct Board: Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let url: String?
    public let closed: Bool?
    public let organizationId: String?
    public let lists: [CardList]?
    public let cards: [Card]?
    public let members: [Member]?

    enum CodingKeys: String, CodingKey {
        case id, name, url, closed, lists, cards, members
        case description = "desc"
        case organizationId = "idOrganization"
    }
}

