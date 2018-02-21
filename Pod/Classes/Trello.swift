//
//  Trello.swift
//  Pods
//
//  Created by Joel Fischer on 4/8/16.
//
//

import Foundation
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
    case networkError(error: Error?)
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
    let jsonDecoder = JSONDecoder()
    let authParameters: [String: AnyObject]
    
    public init(apiKey: String, authToken: String) {
        self.authParameters = ["key": apiKey as AnyObject, "token": authToken as AnyObject]

        jsonDecoder.dateDecodingStrategy = .iso8601
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
        Alamofire.request(Router.allBoards, parameters: self.authParameters).response { (response: DefaultDataResponse) in
            guard let jsonData = response.data else {
                completion(.failure(TrelloError.networkError(error: response.error)))
                return
            }

            do {
                let boards = try self.jsonDecoder.decode([Board].self, from: jsonData)
                completion(.success(boards))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getBoard(_ id: String, includingLists listType: ListType = .None, includingCards cardType: CardType = .None, includingMembers memberType: MemberType = .None, completion: @escaping (Result<Board>) -> Void) {
        let parameters = self.authParameters + ["cards": cardType.rawValue as AnyObject] + ["lists": listType.rawValue as AnyObject] + ["members": memberType.rawValue as AnyObject]
        
        Alamofire.request(Router.board(boardId: id).URLString, parameters: parameters).response { (response) in
            guard let jsonData = response.data else {
                completion(.failure(TrelloError.networkError(error: response.error)))
                return
            }

            do {
                let board = try self.jsonDecoder.decode(Board.self, from: jsonData)
                completion(.success(board))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
}

// MARK: Lists
extension Trello {
    public func getListsForBoard(_ id: String, filter: ListType = .Open, completion: @escaping (Result<[CardList]>) -> Void) {
        let parameters = self.authParameters + ["filter": filter.rawValue as AnyObject]
        
        Alamofire.request(Router.lists(boardId: id).URLString, parameters: parameters).response { (response) in
            guard let jsonData = response.data else {
                completion(.failure(TrelloError.networkError(error: response.error)))
                return
            }

            do {
                let lists = try self.jsonDecoder.decode([CardList].self, from: jsonData)
                completion(.success(lists))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
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
        let parameters = self.authParameters + ["members": withMembers as AnyObject]
        
        Alamofire.request(Router.cardsForList(listId: id).URLString, parameters: parameters).response { (response) in
            guard let jsonData = response.data else {
                completion(.failure(TrelloError.networkError(error: response.error)))
                return
            }

            do {
                let cards = try self.jsonDecoder.decode([Card].self, from: jsonData)
                completion(.success(cards))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
}


// Member API
extension Trello {
    public func getMember(_ id: String, completion: @escaping (Result<Member>) -> Void) {
        let parameters = self.authParameters

        Alamofire.request(Router.member(id: id).URLString, parameters: parameters).response { (response) in
            guard let jsonData = response.data else {
                completion(.failure(TrelloError.networkError(error: response.error)))
                return
            }

            do {
                let member = try self.jsonDecoder.decode(Member.self, from: jsonData)
                completion(.success(member))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getMembersForCard(_ cardId: String, completion: @escaping (Result<[Member]>) -> Void) {
        let parameters = self.authParameters
        
        Alamofire.request(Router.member(id: cardId).URLString, parameters: parameters).response { (response) in
            guard let jsonData = response.data else {
                completion(.failure(TrelloError.networkError(error: response.error)))
                return
            }
            
            do {
                let members = try self.jsonDecoder.decode([Member].self, from: jsonData)
                completion(.success(members))
            } catch (let error) {
                completion(.failure(TrelloError.jsonError(error: error)))
            }
        }
    }
    
    public func getAvatarImage(_ avatarHash: String, size: AvatarSize, completion: @escaping (Result<Image>) -> Void) {
        Alamofire.request("https://trello-avatars.s3.amazonaws.com/\(avatarHash)/\(size.rawValue).png").responseImage { response in
            guard let image = response.result.value else {
                completion(.failure(TrelloError.networkError(error: response.result.error)))
                return
            }
            
            completion(.success(image))
        }
    }
    
    public enum AvatarSize: Int {
        case small = 30
        case large = 170
    }
}


private enum Router: URLConvertible {
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

    func asURL() throws -> URL {
        return URL(string: self.URLString)!
    }
}

// MARK: Dictionary Operator Overloading
// http://stackoverflow.com/questions/24051904/how-do-you-add-a-dictionary-of-items-into-another-dictionary/
func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
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
