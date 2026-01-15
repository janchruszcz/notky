import { Controller } from "@hotwired/stimulus"

// Modal controller with backdrop click handling
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // Prevent body scroll when modal is open
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  // Hide modal
  hideModal() {
    this.element.parentElement.removeAttribute("src")
    // Remove src reference from parent frame element
    // Without this, turbo won't re-open the modal on subsequent click
    this.element.remove()
  }

  // Hide modal on successful form submission
  submitEnd(e) {
    if (e.detail.success) {
      this.hideModal()
    }
  }

  // Hide modal when clicking ESC
  closeWithKeyboard(e) {
    if (e.code === "Escape") {
      this.hideModal()
    }
  }

  // Hide modal when clicking backdrop
  closeBackground(e) {
    // Only close if clicking the backdrop itself, not the modal content
    if (e.target === this.element) {
      this.hideModal()
    }
  }

  // Stop propagation when clicking modal content
  stopPropagation(e) {
    e.stopPropagation()
  }
}