//
//  CardList.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct CardList {
    let id: String
    let name: String
    let boardId: String?
    let pos: Int?
    let subscribed: Bool?
    let closed: Bool?
}

extension CardList: Decodable {
    public static func decode(json: AnyObject) throws -> CardList {
        return try CardList(id: json => "id",
                            name: json => "name",
                            boardId: json =>? "idBoard",
                            pos: json =>? "pos",
                            subscribed: json =>? "subscribed",
                            closed: json =>? "closed")
    }
}
