import FluentSQLite
import Foundation
import Vapor
import Authentication

final class User: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var username: String
    var email: String = ""
    var password: String
    var role: String = ""
    var content: String = ""
    var htmlCSS: String = ""
    var codeTheme: String = ""
    // var date: Date = Date()

    init(id: UUID, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }

    enum Role {
        case admin, moderator(Set<String>), user
        var toString: String {
            switch self {
            case .admin:
                return "admin"
            case .moderator:
                return "moderator"
            case .user:
                return "user"
            }
        }
    }
}

extension User: TokenAuthenticatable { typealias TokenType = Token }

extension User {
    struct PublicUser: Content {
        var username: String
        var token: String
    }
}

final class Token: SQLiteModel, Migration {
    var id: Int?
    var token: String
    var userId: User.ID
    var user: Parent<Token, User> {
        return parent(\.userId)
    }

    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

extension Token: BearerAuthenticatable {
   static var tokenKey: WritableKeyPath<Token, String> { return \Token.token }
}

extension Token: Authentication.Token {
  static var userIDKey: WritableKeyPath<Token, User.ID> { return \Token.userId }
  typealias UserType = User
  typealias UserIDType = User.ID
}

extension Token {
    static func createToken(forUser user: User) throws -> Token {
        let randomString = randomToken(withLength: 60)
        let newToken = try Token(token: randomString, userId: user.requireID())
        return newToken
   }

   static func randomToken(withLength length: Int) -> String {
       let allowedChars = "$!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
       let allowedCharsCount = UInt32(allowedChars.count)
       var randomString = ""
       for _ in 0..<length {
           let randomNumber = Int(arc4random_uniform(allowedCharsCount))
           let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNumber)
           let newCharacter = allowedChars[randomIndex]
           randomString += String(newCharacter)
       }
       return randomString
   }
}
