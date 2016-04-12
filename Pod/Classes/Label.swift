//
//  Label.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Label {
    let id: String
    let name: String?
    let color: String
    let boardId: String?
    let uses: Int?
}

extension Label: Decodable {
    public static func decode(json: AnyObject) throws -> Label {
        return try Label(id: json => "id",
                         name: json =>? "name",
                         color: json => "color",
                         boardId: json =>? "idBoard",
                         uses: json =>? "uses")
    }
}