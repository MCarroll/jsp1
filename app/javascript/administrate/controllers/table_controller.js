import { Controller } from "@hotwired/stimulus";

var keycodes = { space: 32, enter: 13 };

export default class extends Controller {
  visitDataUrl(event) {
    if (event.type == "click" ||
        event.keyCode == keycodes.space ||
        event.keyCode == keycodes.enter) {

      if (event.target.href) {
        return
      }

      const dataUrl = event.target.closest("tr").dataset.url
      const selection = window.getSelection().toString()
      if (selection.length === 0 && dataUrl) {
        Turbo.visit(dataUrl)
        event.preventDefault()
      }
    }
  }
}
