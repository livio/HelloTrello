//
//  Board.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Board {
    let id: String
    let name: String
    let description: String?
    let url: String?
    let closed: Bool?
    let organizationId: String?
}

extension Board: Decodable {
    public static func decode(json: AnyObject) throws -> Board {
        return try Board(id: json => "id",
                         name: json => "name",
                         description: json =>? "desc",
                         url: json =>? "url",
                         closed: json =>? "closed",
                         organizationId: json =>? "idOrganization")
    }
}
