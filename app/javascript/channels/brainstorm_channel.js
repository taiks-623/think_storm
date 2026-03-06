// app/javascript/channels/brainstorm_channel.js
import consumer from "./consumer"

const brainstormChannelSubscriptions = {}

function subscribeToBrainstorm(brainstormId) {
  if (brainstormChannelSubscriptions[brainstormId]) return

  brainstormChannelSubscriptions[brainstormId] = consumer.subscriptions.create(
    { channel: "BrainstormChannel", brainstorm_id: brainstormId },
    {
      connected() {
        console.log(`Connected to BrainstormChannel (brainstorm: ${brainstormId})`)
        fetch(`/brainstorms/${brainstormId}/online_members`)
          .then(res => res.json())
          .then(data => handleMemberPresence(data))
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
          case "member_connected":
          case "member_disconnected":
            handleMemberPresence(data)
            break
        }
      }
    }
  )
}

function handleIdeaCreated(data) {
  const ungroupedContainer = document.querySelector('.sortable-ideas[data-group-id=""]')
  const ideaList = document.querySelector('#ideas-list')
  const target = ungroupedContainer || ideaList

  if (target) {
    target.insertAdjacentHTML('beforeend', data.html)
    const emptyState = document.querySelector('#empty-state')
    if (emptyState) emptyState.style.display = 'none'
  } else {
    window.location.reload()
  }
}

function handleIdeaUpdated(data) {
  const ideaCard = document.querySelector(`.idea-card[data-idea-id="${data.idea_id}"]`)
  if (ideaCard) {
    ideaCard.outerHTML = data.html
  }
}

function handleIdeaDestroyed(data) {
  const ideaCard = document.querySelector(`.idea-card[data-idea-id="${data.idea_id}"]`)
  if (ideaCard) {
    ideaCard.remove()
  }
}

function handleGroupUpdated(data) {
  window.location.reload()
}

function handleMemberPresence(data) {
  const container = document.querySelector('#online-members')
  if (!container) return

  // 全バッジを一旦削除して再描画
  container.innerHTML = ''

  data.online_members.forEach(member => {
    const badge = document.createElement('span')
    badge.className = 'online-member-badge inline-flex items-center gap-1 px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs'
    badge.dataset.userId = member.id
    badge.innerHTML = `
      <span class="w-2 h-2 bg-green-500 rounded-full inline-block"></span>
      ${member.name}
    `
    container.appendChild(badge)
  })
}

document.addEventListener('turbo:load', () => {
  const brainstormEl = document.querySelector('[data-brainstorm-id]')
  if (brainstormEl) {
    const brainstormId = brainstormEl.dataset.brainstormId

    // 既存サブスクリプションを解除して再接続
    if (brainstormChannelSubscriptions[brainstormId]) {
      brainstormChannelSubscriptions[brainstormId].unsubscribe()
      delete brainstormChannelSubscriptions[brainstormId]
    }

    subscribeToBrainstorm(brainstormId)
  }
})

document.addEventListener('turbo:before-cache', () => {
  Object.keys(brainstormChannelSubscriptions).forEach(id => {
    brainstormChannelSubscriptions[id].unsubscribe()
    delete brainstormChannelSubscriptions[id]
  })
})

export { subscribeToBrainstorm }