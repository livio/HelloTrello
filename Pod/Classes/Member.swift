//
//  Member.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation

public struct Member: Codable {
    public let id: String
    public let avatarHash: String?
    public let bio: String?
    public let confirmed: Bool?
    public let fullName: String?
    public let initials: String?
    public let username: String?
    public let email: String?

    enum CodingKeys: String, CodingKey {
        case id, avatarHash, bio, confirmed, fullName, initials, username, email
    }
}
