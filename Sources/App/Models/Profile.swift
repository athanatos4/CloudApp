import FluentSQLite
import Foundation
import Vapor

struct Profile: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var username: String
    var content: String
    var date: Date
}
