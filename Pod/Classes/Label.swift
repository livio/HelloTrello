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
    let name: String
    let color: String
}

extension Label: Decodable {
    public static func decode(json: AnyObject) throws -> Label {
        return try Label(name: json => "name", color: json => "color")
    }
}