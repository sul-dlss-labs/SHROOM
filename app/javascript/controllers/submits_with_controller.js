import { Controller } from "@hotwired/stimulus"

// Alternative to turbo submits_with since it doesn't work when turbo=false
export default class extends Controller {
    showStatus() {
        const submitBtn = this.element.elements['commit'];
        submitBtn.disabled = true;
        submitBtn.value = 'Working...';
    }
}