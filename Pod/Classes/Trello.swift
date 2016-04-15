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
    case Failure(ErrorType)
    case Success(T)
    
    public var value: T? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}

public enum TrelloError: ErrorType {
    case NetworkError(error: NSError?)
    case JSONError(error: ErrorType?)
}

public enum ListType: String {
    case All = "all"
    case Closed = "closed"
    case None = "none"
    case Open = "open"
}

public class Trello {
    
    let authParameters: [String: AnyObject]
    
    public init(apiKey: String, authToken: String) {
        self.authParameters = ["key": apiKey, "token": authToken]
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
    public func getAllBoards(completion: (Result<[Board]>) -> Void) {
        Alamofire.request(.GET, Router.AllBoards, parameters: self.authParameters).responseJSON { (let response) in
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
}

// MARK: Lists
extension Trello {
    public func listsForBoard(id: String, filter: ListType = .Open, completion: (Result<[CardList]>) -> Void) {
        let parameters = self.authParameters + ["filter": filter.rawValue]
        
        Alamofire.request(.GET, Router.Lists(boardId: id), parameters: parameters).responseJSON { (let response) in
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
    
    public func listsForBoard(board: Board, filter: ListType = .Open, completion: (Result<[CardList]>) -> Void) {
        listsForBoard(board.id, filter: filter, completion: completion)
    }
}


// MARK: Cards
extension Trello {
    public func cardsForList(id: String, withMembers: Bool = false, completion: (Result<[Card]>) -> Void) {
        let parameters = self.authParameters + ["members": withMembers]
        
        Alamofire.request(.GET, Router.CardsForList(listId: id), parameters: parameters).responseJSON { (let response) in
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
    public func getMember(id: String, completion: (Result<Member>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(.GET, Router.Member(id: id), parameters: parameters).responseJSON { (let response) in
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
    
    public func membersForCard(cardId: String, completion: (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(.GET, Router.Member(id: cardId), parameters: parameters).responseJSON { (let response) in
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
    
    public func getAvatarImage(avatarHash: String, size: AvatarSize, completion: (Result<Image>) -> Void) {
        Alamofire.request(.GET, "https://trello-avatars.s3.amazonaws.com/\(avatarHash)/\(size.rawValue).png").responseImage { response in
            guard let image = response.result.value else {
                completion(.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            completion(.Success(image))
        }
    }
    
    public enum AvatarSize: Int {
        case Small = 30
        case Large = 170
    }
}


private enum Router: URLStringConvertible {
    static let baseURLString = "https://api.trello.com/1/"
    
    case Search
    case AllBoards
    case Lists(boardId: String)
    case CardsForList(listId: String)
    case Member(id: String)
    case MembersForCard(cardId: String)
    
    var URLString: String {
        switch self {
        case .Search:
            return Router.baseURLString + "search/"
        case .AllBoards:
            return Router.baseURLString + "members/me/boards/"
        case .Lists(let boardId):
            return Router.baseURLString + "boards/\(boardId)/lists/"
        case .CardsForList(let listId):
            return Router.baseURLString + "lists/\(listId)/cards/"
        case .Member(let memberId):
            return Router.baseURLString + "members/\(memberId)/"
        case .MembersForCard(let cardId):
            return Router.baseURLString + "cards/\(cardId)/members/"
        }
    }
}

// MARK: Dictionary Operator Overloading
// http://stackoverflow.com/questions/24051904/how-do-you-add-a-dictionary-of-items-into-another-dictionary/
func +=<K, V> (inout left: [K: V], right: [K: V]) {
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
