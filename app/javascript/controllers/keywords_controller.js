import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['input']

    static outlets = [ 'form-add' ]

    add(event) {
        event.preventDefault();
        this.inputTarget.value.split(/, ?/).forEach((keyword) => {
            const id = this.formAddOutlet.addRow(keyword);
            const rowElement = document.getElementById(id);
            rowElement.querySelector('input').value = keyword;
        })
        this.inputTarget.value = '';
    }   
}