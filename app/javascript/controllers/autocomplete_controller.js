import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.timeout = null
    console.log("autocomplete controller connected!")  // 追加
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query.length < 1) {
      this.hideSuggestions()
      return
    }

    // 300msのデバウンス（入力のたびにリクエストしない）
    this.timeout = setTimeout(() => {
      fetch(`/dashboard/search_suggestions?q=${encodeURIComponent(query)}`, {
        headers: { "Accept": "application/json" }
      })
      .then(response => response.json())
      .then(suggestions => this.showSuggestions(suggestions))
    }, 300)
  }

  showSuggestions(suggestions) {
    if (suggestions.length === 0) {
      this.hideSuggestions()
      return
    }

    this.suggestionsTarget.innerHTML = suggestions.map(title => `
      <div class="suggestion-item px-4 py-2 hover:bg-teal-50 cursor-pointer text-gray-700 text-sm"
           data-action="click->autocomplete#select"
           data-title="${title}">
        ${title}
      </div>
    `).join("")

    this.suggestionsTarget.classList.remove("hidden")
  }

  select(event) {
    this.inputTarget.value = event.currentTarget.dataset.title
    this.hideSuggestions()
    // そのまま検索実行
    this.inputTarget.closest("form").submit()
  }

  hideSuggestions() {
    this.suggestionsTarget.innerHTML = ""
    this.suggestionsTarget.classList.add("hidden")
  }

  // フォーム外をクリックしたら候補を閉じる
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}