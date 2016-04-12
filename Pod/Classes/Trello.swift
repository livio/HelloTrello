//
//  Trello.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import UIKit
import Alamofire

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
    
    
    // MARK: Boards
    public func getAllBoards(completion: (Result<[Board]>) -> Void) {
        Alamofire.request(.GET, Router.AllBoards, parameters: self.authParameters).responseJSON { (let response) in
            guard let json = response.result.value else {
                completion(Result.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let boards = try [Board].decode(json)
                completion(Result.Success(boards))
            } catch (let error) {
                completion(Result.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    
    // MARK: Lists
    public func listsForBoard(id: String, filter: ListType = .Open, completion: (Result<[CardList]>) -> Void) {
        let parameters = self.authParameters + ["filter": filter.rawValue]
        
        Alamofire.request(.GET, Router.Lists(boardId: id), parameters: parameters).responseJSON { (let response) in
            guard let json = response.result.value else {
                completion(Result.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let lists = try [CardList].decode(json)
                completion(Result.Success(lists))
            } catch {
                completion(Result.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
    
    public func listsForBoard(board: Board, filter: ListType = .Open, completion: (Result<[CardList]>) -> Void) {
        listsForBoard(board.id, filter: filter, completion: completion)
    }
    
    
    // MARK: Cards
    public func cardsForList(id: String, withMembers: Bool = false, completion: (Result<[Card]>) -> Void) {
        let parameters = self.authParameters + ["members": withMembers]
        
        Alamofire.request(.GET, Router.CardForList(listId: id), parameters: parameters).responseJSON { (let response) in
            guard let json = response.result.value else {
                completion(Result.Failure(TrelloError.NetworkError(error: response.result.error)))
                return
            }
            
            do {
                let cards = try [Card].decode(json)
                completion(Result.Success(cards))
            } catch {
                completion(Result.Failure(TrelloError.JSONError(error: error)))
            }
        }
    }
}


private enum Router: URLStringConvertible {
    static let baseURLString = "https://api.trello.com/1/"
    
    case Search
    case AllBoards
    case Lists(boardId: String)
    case CardForList(listId: String)
    
    var URLString: String {
        switch self {
        case .Search:
            return Router.baseURLString + "search/"
        case .AllBoards:
            return Router.baseURLString + "members/me/boards/"
        case .Lists(let boardId):
            return Router.baseURLString + "boards/\(boardId)/lists/"
        case .CardForList(let listId):
            return Router.baseURLString + "lists/\(listId)/cards/"
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
