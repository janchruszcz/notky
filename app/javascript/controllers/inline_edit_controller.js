import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="inline-edit"
export default class extends Controller {
  connect() {
    this.element.addEventListener('turbo:frame-load', () => {
      const input = this.element.querySelector('input, textarea, select');
      if (input) {
        input.focus();
        const len = input.value.length;
        input.setSelectionRange(len, len);
      }
    });
  }
}
