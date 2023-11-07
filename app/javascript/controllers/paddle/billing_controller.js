import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ]
  static values = {
    class: {type: String, default: "paddle-billing-checkout"},
    customData: String,
    environment: {type: String, default: "production"},
    email: String,
    transactionId: String,
    items: Array,
    clientToken: String,
    displayMode: {type: String, default: "inline"}
  }

  async connect() {
    await this.addScript("https://cdn.paddle.com/paddle/v2/paddle.js")

    // Ensure class for mounting inline checkout is defined
    this.element.classList.add(this.classValue)

    Paddle.Environment.set(this.environmentValue)
    Paddle.Setup({
      token: this.clientTokenValue,
      eventCallback: this.callback.bind(this),
      checkout: { settings: this.settings }
    })

    // Render checkout, otherwise just include the JS to handle ?_ptxn= pages for updating subscriptions
    if (this.itemsValue.length > 0 || this.transactionId)
      this.open()
  }

  disconnect() {
    delete window.Paddle
  }

  open() {
    Paddle.Checkout.open({
      customer: {
        email: this.emailValue
      },
      customData: this.customDataValue,
      items: this.itemsValue,
    });
  }

  callback(event) {
    const price = event.data?.recurring_totals
    if (price) {
      document.getElementById("recurringTotal").innerHTML = `${price.total} ${event.data.currency_code}`
    }

    if (event.name == "checkout.completed") {
      Turbo.visit(`/subscriptions/paddle_billing?user_id=${event.data.customer.id}&transaction_id=${event.data.transaction_id}`)
    }
  }

  get settings() {
    return {
      allowLogout: false, // Don't allow customer to edit email
      displayMode: this.displayModeValue,
      theme: this.theme,
      frameTarget: this.classValue,
      frameInitialHeight: 450,
      frameStyle: 'width:100%; background-color: transparent; border: none;',
    }
  }

  get theme() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light";
  }

  addScript(src) {
    return new Promise((resolve, reject) => {
      const s = document.createElement('script')

      s.setAttribute('src', src)
      s.addEventListener('load', resolve)
      s.addEventListener('error', reject)

      document.body.appendChild(s)
    })
  }
}
