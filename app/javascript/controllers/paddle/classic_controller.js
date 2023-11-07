import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ]
  static values = {
    class: "paddle-classic-checkout",
    email: String,
    environment: {type: String, default: "production"},
    override: String,
    passthrough: String,
    product: String,
    redirectUrl: String,
    vendorId: Number
  }

  async connect() {
    await this.addScript("https://cdn.paddle.com/paddle/paddle.js")

    // Ensure class for mounting inline checkout is defined
    this.element.classList.add(this.classValue)

    Paddle.Environment.set(this.environmentValue)
    Paddle.Setup({
      vendor: this.vendorIdValue,
      eventCallback: this.callback.bind(this)
    })

    // Render checkout, otherwise just include the JS
    if (this.overrideValue || this.productValue)
      this.open()
  }

  disconnect() {
    delete window.Paddle
  }

  open() {
    Paddle.Checkout.open({
      ...this.params,
      product: this.productValue,
      email: this.emailValue,
      passthrough: this.passthroughValue,
      override: this.overrideValue
    })
  }

  checkoutComplete(event) {
    Paddle.Order.details(event.checkout.id, (checkout) => {
      Turbo.visit(`/subscriptions/paddle_classic?user_id=${event.user.id}&subscription_id=${checkout.order.subscription_id}`)
    })
  }

  callback(event) {
    const price = event.eventData.checkout?.recurring_prices?.customer
    if (price) {
      document.getElementById("recurringTotal").innerHTML = `${price.total} ${price.currency}`
    }
  }

  get params() {
    return {
      method: 'inline',
      allowQuantity: false,
      disableLogout: true,
      frameTarget: this.classValue,
      frameInitialHeight: 450,
      frameStyle: 'width:100%; background-color: transparent; border: none;',
      successCallback: this.checkoutComplete.bind(this),
      displayModeTheme: this.theme
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
