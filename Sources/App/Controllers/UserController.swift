import Vapor
import Leaf
import FluentSQLite
import Crypto

class UserController {
    func create(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.content.decode(User.self).flatMap() { user in
            print("in create: " + user.password)
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
        let hashed = try SHA256.hash(password).hexEncodedString()
        return User.query(on: req).filter(\User.username == username)
        .filter(\User.password == hashed).first()
        .flatMap() { usr throws -> Future<Token> in
            print("user: " + usr!.password)
            let randomString = Token.randomToken(withLength: 60)
            let t = try Token(token: randomString, userId: usr!.requireID())
            return t.save(on: req)
        }.map(to: User.PublicUser.self) { token in
            return User.PublicUser(username: username, token: token.token)
        }
    }
}
