import FluentSQLite
import Foundation
import Vapor

struct User: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var username: String
    var content: String
    var mdCSS: String
    var codeCSS: String
    var date: Date
}
