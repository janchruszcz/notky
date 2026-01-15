import { Controller } from "@hotwired/stimulus"

// Handles todo item interactions and animations
export default class extends Controller {
  static targets = ["checkbox", "text"]
  static values = { completed: Boolean }

  toggle() {
    const isCompleted = this.checkboxTarget.checked

    // Update visual state immediately for responsiveness
    if (this.hasTextTarget) {
      if (isCompleted) {
        this.textTarget.classList.add("line-through", "text-cork-400")
        this.element.classList.add("completed", "opacity-60")
      } else {
        this.textTarget.classList.remove("line-through", "text-cork-400")
        this.element.classList.remove("completed", "opacity-60")
      }
    }

    // Update value
    this.completedValue = isCompleted
  }

  completedValueChanged() {
    // Sync visual state with value
    if (this.hasTextTarget) {
      if (this.completedValue) {
        this.textTarget.classList.add("line-through", "text-cork-400")
      } else {
        this.textTarget.classList.remove("line-through", "text-cork-400")
      }
    }
  }
}
