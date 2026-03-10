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

function getAvatarColor(userId) {
  const colors = [
    '#0ABFA3', '#00C8D7', '#6C47FF', '#F59E0B',
    '#EF4444', '#10B981', '#3B82F6', '#EC4899'
  ]
  return colors[userId % colors.length]
}

function getInitial(name) {
  if (!name || name === '名前未設定') return '?'
  // 日本語対応：最初の1文字
  return Array.from(name)[0].toUpperCase()
}

function handleMemberPresence(data) {
  const container = document.querySelector('#online-members')
  if (!container) return

  container.innerHTML = ''

  data.online_members.forEach(member => {
    const color = getAvatarColor(member.id)
    const initial = getInitial(member.name)

    const wrapper = document.createElement('div')
    wrapper.className = 'online-member-avatar'
    wrapper.dataset.userId = member.id
    wrapper.title = member.name
    wrapper.innerHTML = `
      <div class="ts-avatar-circle" style="background-color: ${color};">
        ${initial}
      </div>
    `
    container.appendChild(wrapper)
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