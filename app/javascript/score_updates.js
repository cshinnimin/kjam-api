// Simple JS module to handle score increment/decrement via Fetch
document.addEventListener('turbo:load', () => {
  attachScoreButtons()
})

function attachScoreButtons() {
  document.querySelectorAll('.score-controls').forEach(node => {
    const gameId = node.dataset.gameId
    node.querySelectorAll('button[data-action]').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const action = btn.dataset.action
        let url = ''
        const token = document.querySelector('meta[name="csrf-token"]')?.content
        if (action === 'increment-home') url = `/games/${gameId}/increment_home_half1`
        if (action === 'decrement-home') url = `/games/${gameId}/decrement_home_half1`
        if (action === 'increment-away') url = `/games/${gameId}/increment_away_half1`
        if (action === 'decrement-away') url = `/games/${gameId}/decrement_away_half1`
        if (!url) return
        try {
          const resp = await fetch(url, {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-CSRF-Token': token
            }
          })
          if (!resp.ok) throw new Error('Network response was not ok')
          const data = await resp.json()
          // update DOM values
          const parent = node.closest('.half-row')
          if (data.home_score_half_1 !== undefined) {
            const el = parent.querySelector('[data-home-score]')
            if (el) el.textContent = data.home_score_half_1
          }
          if (data.away_score_half_1 !== undefined) {
            const el = parent.querySelector('[data-away-score]')
            if (el) el.textContent = data.away_score_half_1
          }
        } catch (err) {
          console.error('Score update failed', err)
        }
      })
    })
  })
}
