import Vapor
import Leaf
import FluentSQLite

final class ProfileController {

    func find(_ req: Request) throws -> Future<Profile> {
        let username = try req.parameters.next(String.self)
        return Profile.query(on: req).filter(\Profile.username == username).first().map(to: Profile.self) { user in
            guard let user = user else {
                throw Abort(.notFound, reason: "Could not find user.")
            }
            return user
        }
    }

    func create(_ req: Request) throws ->  Future<Response> {
        let username: String = try req.content.syncGet(at: "username")
        let content: String = try req.content.syncGet(at: "content")
        let p = Profile(id: nil, username: username, content: content, date: Date())
        return p.save(on: req).map(to: Response.self) {_ in return req.redirect(to: "/index.html")}
    }
}
