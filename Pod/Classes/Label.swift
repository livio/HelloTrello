//
//  Label.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation

public struct Label: Codable {
    public let id: String
    public let name: String?
    public let color: String
    public let boardId: String?
    public let uses: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, color, uses
        case boardId = "idBoard"
    }
}
