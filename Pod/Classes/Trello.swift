//
//  Trello.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Alamofire
import AlamofireImage

public enum Result<T> {
    case failure(Error)
    case success(T)
    
    public var value: T? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public enum TrelloError: Error {
    case networkError(error: NSError?)
    case jsonError(error: Error?)
}

public enum ListType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
}

public enum CardType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
    case Visible = "visible"
}

public enum MemberType: String {
    case Admins = "admins"
    case All = "all"
    case None = "none"
    case Normal = "normal"
    case Owners = "owners"
}

open class Trello {
    
    let authParameters: [String: AnyObject]
    
    public init(apiKey: String, authToken: String) {
        self.authParameters = ["key": apiKey as AnyObject, "token": authToken as AnyObject]
    }
    
    // TODO: The response end of this is tough
//    public func search(query: String, partial: Bool = true) {
//        let parameters = authParameters + ["query": query] + ["partial": partial]
//        
//        Alamofire.request(.GET, Router.Search, parameters: parameters).responseJSON { (let response) in
//            print("Search Response \(response.result)")
//            // Returns a list of actions, boards, cards, members, and orgs that match the query
//        }
//    }
}

extension Trello {
    // MARK: Boards
    public func getAllBoards(_ completion: @escaping (Result<[Board]>) -> Void) {
        Alamofire.request(.GET, Router.AllBoards, parameters: self.authParameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let boards = try [Board].decode(json)
                completion(.Success(boards))
            } catch (let error) {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getBoard(_ id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
        let parameters = self.authParameters + ["cards": cardType.rawValue] + ["lists": listType.rawValue] + ["members": memberType.rawValue]
        
        Alamofire.request(.GET, Router.Board(boardId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let board = try Board.decode(json)
                completion(.Success(board))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
}

// MARK: Lists
extension Trello {
    public func getListsForBoard(_ id: String, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        let parameters = self.authParameters + ["filter": filter.rawValue]
        
        Alamofire.request(.GET, Router.Lists(boardId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let lists = try [CardList].decode(json)
                completion(.Success(lists))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getListsForBoard(_ board: Board, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        getListsForBoard(board.id, filter: filter, completion: completion)
    }
}


// MARK: Cards
extension Trello {
    public func getCardsForList(_ id: String, withMembers: Bool = false, completion: @escaping (Result<[Card]>) -> Void) {
        let parameters = self.authParameters + ["members": withMembers]
        
        Alamofire.request(.GET, Router.CardsForList(listId: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let cards = try [Card].decode(json)
                completion(.Success(cards))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
}


// Member API
extension Trello {
    public func getMember(_ id: String, completion: @escaping (Result<Member>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(.GET, Router.Member(id: id), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let member = try Member.decode(json)
                completion(.Success(member))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getMembersForCard(_ cardId: String, completion: @escaping (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(.GET, Router.Member(id: cardId), parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let members = try [Member].decode(json)
                completion(.Success(members))
            } catch {
                completion(.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func getAvatarImage(_ avatarHash: String, size: AvatarSize, completion: (Result<Image>) -> Void) {
        Alamofire.request(.GET, "https://trello-avatars.s3.amazonaws.com/\(avatarHash)/\(size.rawValue).png").responseImage { response in
            guard let image = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            completion(.Success(image))
        }
    }
    
    public enum AvatarSize: Int {
        case small = 30
        case large = 170
    }
}


private enum Router: URLStringConvertible {
    static let baseURLString = "https://api.trello.com/1/"
    
    case search
    case allBoards
    case board(boardId: String)
    case lists(boardId: String)
    case cardsForList(listId: String)
    case member(id: String)
    case membersForCard(cardId: String)
    
    var URLString: String {
        switch self {
        case .search:
            return Router.baseURLString + "search/"
        case .allBoards:
            return Router.baseURLString + "members/me/boards/"
        case .board(let boardId):
            return Router.baseURLString + "boards/\(boardId)/"
        case .lists(let boardId):
            return Router.baseURLString + "boards/\(boardId)/lists/"
        case .cardsForList(let listId):
            return Router.baseURLString + "lists/\(listId)/cards/"
        case .member(let memberId):
            return Router.baseURLString + "members/\(memberId)/"
        case .membersForCard(let cardId):
            return Router.baseURLString + "cards/\(cardId)/members/"
        }
    }
}

// MARK: Dictionary Operator Overloading
// http://stackoverflow.com/questions/24051904/how-do-you-add-a-dictionary-of-items-into-another-dictionary/
func +=<K, V> (left: inout [K: V], right: [K: V]) {
    right.forEach({ left.updateValue($1, forKey: $0) })
}

func +<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    var newDict: [K: V] = [:]
    for (k, v) in left {
        newDict[k] = v
    }
    for (k, v) in right {
        newDict[k] = v
    }
    
    return newDict
}
