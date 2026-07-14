// Import and register all your controllers from the importmap via the controllers directory:
//
//    import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
//    eagerLoadControllersFrom("controllers", application)
//
// Or, fine-grained manual registration:
//
//    import { application } from "controllers/application"
//    import HelloController from "controllers/hello_controller"
//    application.register("hello", HelloController)

import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)