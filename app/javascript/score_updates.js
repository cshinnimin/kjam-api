// Simple JS module to handle score increment/decrement via Fetch
document.addEventListener('turbo:load', () => {
  attachScoreButtons()
  attachCompleteToggles()
})

function attachCompleteToggles() {
  document.querySelectorAll('.complete-toggle').forEach(input => {
    input.addEventListener('change', async (e) => {
      const gameId = input.dataset.gameId
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      try {
        const resp = await fetch(`/games/${gameId}/toggle_complete`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': token
          }
        })
        if (!resp.ok) throw new Error('Network response was not ok')
        const data = await resp.json()
        if (data.complete === undefined) throw new Error('Invalid response')
        // ensure checkbox matches server value
        input.checked = !!data.complete
      } catch (err) {
        console.error('Toggle complete failed', err)
        // revert checkbox on failure
        input.checked = !input.checked
      }
    })
  })
}

function attachScoreButtons() {
  document.querySelectorAll('.score-controls').forEach(node => {
    const gameId = node.dataset.gameId
    node.querySelectorAll('button[data-action]').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const action = btn.dataset.action
        let url = ''
        const token = document.querySelector('meta[name="csrf-token"]')?.content
        if (action === 'increment-home-one') url = `/games/${gameId}/increment_home_half1`
        if (action === 'decrement-home-one') url = `/games/${gameId}/decrement_home_half1`
        if (action === 'increment-away-one') url = `/games/${gameId}/increment_away_half1`
        if (action === 'decrement-away-one') url = `/games/${gameId}/decrement_away_half1`
        if (action === 'increment-home-two') url = `/games/${gameId}/increment_home_half2`
        if (action === 'decrement-home-two') url = `/games/${gameId}/decrement_home_half2`
        if (action === 'increment-away-two') url = `/games/${gameId}/increment_away_half2`
        if (action === 'decrement-away-two') url = `/games/${gameId}/decrement_away_half2`
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
          const gameShow = node.closest('.game-show')
          if (data.home_score_half_1 !== undefined) {
            const el = parent.querySelector('[data-home-score]')
            if (el) el.textContent = data.home_score_half_1
          }
          if (data.away_score_half_1 !== undefined) {
            const el = parent.querySelector('[data-away-score]')
            if (el) el.textContent = data.away_score_half_1
          }
          if (data.home_score_half_2 !== undefined) {
            const el = parent.querySelector('[data-home-score]')
            if (el) el.textContent = data.home_score_half_2
          }
          if (data.away_score_half_2 !== undefined) {
            const el = parent.querySelector('[data-away-score]')
            if (el) el.textContent = data.away_score_half_2
          }
          // recompute totals (home and away) from half 1 + half 2
          try {
            const getInt = (el) => el ? (parseInt(el.textContent, 10) || 0) : 0
            const home1El = gameShow.querySelector('.half-row[data-half="1"] [data-home-score]')
            const home2El = gameShow.querySelector('.half-row[data-half="2"] [data-home-score]')
            const away1El = gameShow.querySelector('.half-row[data-half="1"] [data-away-score]')
            const away2El = gameShow.querySelector('.half-row[data-half="2"] [data-away-score]')
            const homeTotalEl = gameShow.querySelector('[data-home-total]')
            const awayTotalEl = gameShow.querySelector('[data-away-total]')
            const homeTotal = getInt(home1El) + getInt(home2El)
            const awayTotal = getInt(away1El) + getInt(away2El)
            if (homeTotalEl) homeTotalEl.textContent = homeTotal
            if (awayTotalEl) awayTotalEl.textContent = awayTotal
          } catch (e) {
            // ignore total calc errors
          }
        } catch (err) {
          console.error('Score update failed', err)
        }
      })
    })
  })
}
