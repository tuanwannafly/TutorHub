// Stimulus application singleton, used by all controllers in this app.
// The eager-load helper in controllers/index.js auto-registers every
// controller under app/javascript/controllers/, so we just need to expose
// the application instance here.
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Don't spew warnings in dev — keeps the dev console focused on our app.
application.debug = false
application.warnings = false

export { application }