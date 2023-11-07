import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addressElement", "paymentElement", "error", "form", "default"]
  static values = {
    default: {type: Boolean, default: true},
    publicKey: String,
    clientSecret: String,
    returnUrl: String,
    name: String
  }

  connect() {
    console.log(this.returnUrl)
    this.initializePaymentElement()
  }

  initializePaymentElement() {
    this.stripe = Stripe(this.publicKeyValue)
    this.elements = this.stripe.elements({
      appearance: {
        theme: this.theme,
        variables: {
          fontSizeBase: "14px"
        }
      },
      clientSecret: this.clientSecretValue
    })

    this.paymentElement = this.elements.create("payment")
    this.paymentElement.mount(this.paymentElementTarget)

    if (this.hasAddressElementTarget) {
      this.addressElement = this.elements.create('address', {
        mode: 'billing',
        defaultValues: {
          name: this.nameValue
        }
      });
      this.addressElement.mount(this.addressElementTarget)
    }
  }

  changed(event) {
    this.errorTarget.textContent = event.error?.message || ""
  }

  defaultChanged(event) {
    this.defaultValue = event.currentTarget.checked
  }

  async submit(event) {
    event.preventDefault()

    let args = {
      elements: this.elements,
      confirmParams: { return_url: this.returnUrlValue },
    }

    // Payment Intents
    if (this.clientSecretValue.startsWith("pi_")) {
      const { error } = await this.stripe.confirmPayment(args)
      this.showError(error)
    // Setup Intents
    } else {
      const { error } = await this.stripe.confirmSetup(args)
      this.showError(error)
    }
  }

  showError(error) {
    this.errorTarget.textContent = error.message
  }

  get theme() {
    return document.documentElement.classList.contains("dark") ? "night" : "stripe";
  }
}

