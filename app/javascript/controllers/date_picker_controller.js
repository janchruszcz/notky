import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["date"]

  submit() {
    this.dateTarget.form.requestSubmit();
  }
}