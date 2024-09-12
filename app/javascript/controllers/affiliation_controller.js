import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  toggleInputs(event) {
    this.inputTargets.forEach((inputTarget) => {
      inputTarget.disabled = true
    })
    event.target.parentElement.querySelectorAll("input[type='hidden'],input[type='text']").forEach((inputElement) => {
      inputElement.disabled = false
    })
  }
}
