import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "paragraph"]

  connect() {
    this.updateCrossOut();
  }

  toggleCrossOut() {
    this.updateCrossOut();
  }

  updateCrossOut() {
    const isChecked = this.checkboxTarget.checked;
    if (isChecked) {
      this.paragraphTarget.classList.add('line-through');
    } else {
      this.paragraphTarget.classList.remove('line-through');
    }
  }
}