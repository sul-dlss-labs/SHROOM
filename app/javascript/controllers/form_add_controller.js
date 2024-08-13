import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "template", "rowContainer"]

  add(event) {
    event.preventDefault();
    this.rowContainerTarget.insertAdjacentHTML('beforeend', this.newRow)
  }

  get maxIndex() {
    return Math.max(-1, ...this.rowTargets.map((row) => parseInt(row.dataset.index))) + 1
  }

  get newRow() {
    return this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.maxIndex + 1)
  }
}
