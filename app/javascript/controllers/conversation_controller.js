import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form", "messages"]

  submitOnEnter(event) {
    if (event.isComposing || event.keyCode === 229) return

    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      event.stopPropagation()

      if (this.inputTarget.value.trim() === "") return

      this.submit()
    }
  }

  submit() {
    const message = this.inputTarget.value.trim()
    if (message === "") return

    // ユーザーメッセージを即座に表示
    this.appendUserMessage(message)

    // フォームを送信
    this.inputTarget.value = ""
    this.formTarget.requestSubmit()
  }

  appendUserMessage(message) {
    const messagesEl = document.getElementById("messages")
    if (!messagesEl) return

    const div = document.createElement("div")
    div.classList.add("flex", "justify-end")
    div.innerHTML = `
      <div class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg text-sm bg-teal-600 text-white">
        <p>${this.escapeHtml(message)}</p>
      </div>
    `
    messagesEl.appendChild(div)
    messagesEl.scrollTop = messagesEl.scrollHeight
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.appendChild(document.createTextNode(text))
    return div.innerHTML
  }
}