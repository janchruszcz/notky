import { Controller } from "@hotwired/stimulus"

// True inline editing without modals
// Handles click-to-edit, blur-to-save, escape-to-cancel
export default class extends Controller {
  static targets = ["display", "form", "input"]
  static values = { url: String }

  connect() {
    this.originalValue = this.hasInputTarget ? this.inputTarget.value : ""
  }

  edit(event) {
    event.preventDefault()

    // Store original value for cancel
    if (this.hasDisplayTarget) {
      this.originalValue = this.displayTarget.textContent.trim()
    }

    // Show form, hide display
    if (this.hasFormTarget && this.hasDisplayTarget) {
      this.displayTarget.classList.add("hidden")
      this.formTarget.classList.remove("hidden")
    }

    // Focus and select input
    if (this.hasInputTarget) {
      this.inputTarget.value = this.originalValue
      this.inputTarget.focus()
      this.inputTarget.select()
    }
  }

  save(event) {
    // Don't submit on shift+enter (for potential multiline)
    if (event.type === "keydown" && event.shiftKey) return

    if (event.type === "keydown") {
      event.preventDefault()
    }

    const newValue = this.inputTarget.value.trim()

    // Don't save if empty or unchanged
    if (!newValue || newValue === this.originalValue) {
      this.cancel()
      return
    }

    // Submit the form
    this.formTarget.requestSubmit()

    // Optimistically update display
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = newValue
    }

    this.hideForm()
  }

  cancel(event) {
    if (event) event.preventDefault()

    // Restore original value
    if (this.hasInputTarget) {
      this.inputTarget.value = this.originalValue
    }

    this.hideForm()
  }

  hideForm() {
    if (this.hasFormTarget && this.hasDisplayTarget) {
      this.formTarget.classList.add("hidden")
      this.displayTarget.classList.remove("hidden")
    }
  }

  // Handle turbo frame loads for server-side updates
  frameLoaded() {
    const input = this.element.querySelector('input, textarea, select')
    if (input) {
      input.focus()
      const len = input.value.length
      input.setSelectionRange(len, len)
    }
  }
}
