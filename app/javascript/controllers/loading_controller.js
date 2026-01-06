import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner"]

  show(event) {
    // ボタンを無効化
    this.buttonTarget.disabled = true
    
    // スピナーを表示
    this.spinnerTarget.classList.remove("hidden")
    
    // ボタンのテキストを変更
    this.buttonTarget.querySelector("span").textContent = "生成中..."
  }
}