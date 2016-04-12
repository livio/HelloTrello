//
//  Member.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Decodable

public struct Member {
    let id: String
    let avatarHash: String?
    let bio: String?
    let confirmed: Bool?
    let fullName: String?
    let initials: String?
    let username: String?
    let email: String?
}

extension Member: Decodable {
    public static func decode(json: AnyObject) throws -> Member {
        return try Member(id: json => "id",
                          avatarHash: json =>? "avatarHash",
                          bio: json =>? "bio",
                          confirmed: json =>? "confirmed",
                          fullName: json =>? "fullName",
                          initials: json =>? "initials",
                          username: json =>? "username",
                          email: json =>? "email")
    }
}
