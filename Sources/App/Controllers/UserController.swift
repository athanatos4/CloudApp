import Vapor
import Leaf
import FluentSQLite
import Crypto

class UserController {
    func create(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.content.decode(User.self).flatMap() { user in
            user.password = try SHA256.hash(user.password).hexEncodedString()
            user.id = nil
            return user.save(on: req).flatMap(to: User.PublicUser.self) { createdUser in
                let accessToken = try Token.createToken(forUser: createdUser)
                return accessToken.save(on: req).map(to: User.PublicUser.self) { createdToken in
                    let publicUser = User.PublicUser(username: createdUser.username, token: createdToken.token)
                    return publicUser
                }
            }
        }
    }

    func login(_ req: Request) throws -> Future<User.PublicUser> {
        let username: String = try req.content.syncGet(at: "username")
        let password: String = try req.content.syncGet(at: "password")
        return try User.query(on: req).filter(\User.username == username)
        .filter(\User.password == SHA256.hash(password).hexEncodedString()).first()
        .flatMap() { wrappedUser throws -> Future<Token> in
            guard let user = wrappedUser else {throw Abort(.unauthorized)}
            let randomString = Token.randomToken(withLength: 60)
            return try Token(token: randomString, userId: user.requireID()).save(on: req)
        }.map(to: User.PublicUser.self) { token in
            return User.PublicUser(username: username, token: token.token)
        }
    }
}
