import FluentSQLite
import Foundation
import Vapor

struct File: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var description: String = ""
    var note: Int = 0
    var nbOfVotes: Int = 0
    var main: String
    var name: String
    var date: Date
}
