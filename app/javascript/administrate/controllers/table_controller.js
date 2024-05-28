import { Controller } from "@hotwired/stimulus";

var keycodes = { space: 32, enter: 13 };

export default class extends Controller {
  visitDataUrl(event) {
    if (event.type == "click" ||
        event.keyCode == keycodes.space ||
        event.keyCode == keycodes.enter) {

      // If the click is on an anchor or a tag inside an anchor, let the browser do it's normal thing
      if (event.target.closest("[href]")) {
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
