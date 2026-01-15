import { Controller } from "@hotwired/stimulus"

// Handles dropdown menu toggle with click-outside closing
export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.menuTarget.classList.add("animate-scale-in")
    document.addEventListener("click", this.closeOnClickOutside)
    document.addEventListener("keydown", this.closeOnEscape.bind(this))
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("animate-scale-in")
    document.removeEventListener("click", this.closeOnClickOutside)
    document.removeEventListener("keydown", this.closeOnEscape.bind(this))
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
  }
}
