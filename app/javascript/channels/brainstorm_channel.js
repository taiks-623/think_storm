import consumer from "./consumer"

const brainstormChannelSubscriptions = {}

function subscribeToBrainstorm(brainstormId) {
  if (brainstormChannelSubscriptions[brainstormId]) return

  brainstormChannelSubscriptions[brainstormId] = consumer.subscriptions.create(
    { channel: "BrainstormChannel", brainstorm_id: brainstormId },
    {
      connected() {
        console.log(`Connected to BrainstormChannel (brainstorm: ${brainstormId})`)
      },

      disconnected() {
        console.log(`Disconnected from BrainstormChannel`)
      },

      received(data) {
        console.log("Received:", data)

        switch (data.event) {
          case "idea_created":
            handleIdeaCreated(data)
            break
          case "idea_updated":
            handleIdeaUpdated(data)
            break
          case "idea_destroyed":
            handleIdeaDestroyed(data)
            break
          case "group_updated":
            handleGroupUpdated(data)
            break
        }
      }
    }
  )
}

function handleIdeaCreated(data) {
  // グループあり：未分類エリアに追加
  const ungroupedContainer = document.querySelector('.sortable-ideas[data-group-id=""]')
  // グループなし：ideas-listに追加
  const ideaList = document.querySelector('#ideas-list')
  const target = ungroupedContainer || ideaList

  if (target) {
    target.insertAdjacentHTML('beforeend', data.html)
    // 空の状態表示を非表示にする
    const emptyState = document.querySelector('#empty-state')
    if (emptyState) emptyState.style.display = 'none'
  } else {
    // どこにも挿入先がなければリロード
    window.location.reload()
  }
}

function handleIdeaUpdated(data) {
  // idea-cardクラスを持つ要素に絞って検索
  const ideaCard = document.querySelector(`.idea-card[data-idea-id="${data.idea_id}"]`)
  if (ideaCard) {
    ideaCard.outerHTML = data.html
  }
}

function handleIdeaDestroyed(data) {
  // idea-cardクラスを持つ要素に絞って検索
  const ideaCard = document.querySelector(`.idea-card[data-idea-id="${data.idea_id}"]`)
  if (ideaCard) {
    ideaCard.remove()
  }
}

function handleGroupUpdated(data) {
  // ページリロードで対応（クラスタリング結果など大きな変更）
  window.location.reload()
}

// ページ読み込み時に自動サブスクライブ
document.addEventListener('turbo:load', () => {
  const brainstormEl = document.querySelector('[data-brainstorm-id]')
  if (brainstormEl) {
    subscribeToBrainstorm(brainstormEl.dataset.brainstormId)
  }
})

export { subscribeToBrainstorm }
