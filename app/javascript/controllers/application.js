import { Application } from "@hotwired/stimulus"
import Flatpickr from "stimulus-flatpickr"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register("flatpickr", Flatpickr)

export { application }
