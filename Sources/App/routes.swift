import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req -> Future<View> in
        return try req.view().render("hello", ["title": "Caca"])
    }

    // Example of configuring a controller
    let profileController = ProfileController()
    router.get("profile", String.parameter, use: profileController.find)
    router.post("profile", use: profileController.create)

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
