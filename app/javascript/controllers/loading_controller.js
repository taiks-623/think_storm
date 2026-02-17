// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  show(event) {
    // メッセージを設定
    const message = event.currentTarget.dataset.loadingMessage || "処理中..."
    document.getElementById("loading-message").textContent = message

    // オーバーレイを表示
    this.overlayTarget.classList.remove("hidden")

    // ページ離脱・戻り時にオーバーレイを消す
    window.addEventListener("pageshow", () => {
      this.overlayTarget.classList.add("hidden")
    })

    // フォームをsubmit（Turbo対応）
    const form = event.currentTarget.closest("form")
    if (form) {
      setTimeout(() => {
        const submitEvent = new Event("submit", { bubbles: true, cancelable: true })
        form.dispatchEvent(submitEvent)
        if (!submitEvent.defaultPrevented) {
          form.submit()
        }
      }, 100)
    }
  }
}