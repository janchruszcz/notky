import { Controller } from "@hotwired/stimulus"

// Handles inline todo creation
export default class extends Controller {
  static targets = ["input"]

  submit(event) {
    if (event.type === "keydown" && event.key === "Enter") {
      event.preventDefault()

      const value = this.inputTarget.value.trim()
      if (!value) return

      // Submit the form
      this.element.requestSubmit()

      // Clear input for next entry
      this.inputTarget.value = ""
    }
  }

  // Clear input after successful submission
  reset() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }
}
