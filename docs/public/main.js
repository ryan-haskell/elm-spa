const app = Elm.Main.init({ flags: window.__FLAGS__ })

// Handle smoothly scrolling to links
const scrollToHash = () => {
  const BREAKPOINT_XL = 1920
  const NAVBAR_HEIGHT_PX = window.innerWidth > BREAKPOINT_XL ? 127 : 102
  const element = window.location.hash && document.querySelector(window.location.hash)
  if (element) {
    // element.scrollIntoView({ behavior: 'smooth' })
    window.scroll({ behavior: 'smooth', top: window.pageYOffset + element.getBoundingClientRect().top - NAVBAR_HEIGHT_PX })
  } else {
    window.scroll({ behavior: 'smooth', top: 0 })
  }
}

app.ports.onUrlChange.subscribe(_ => setTimeout(scrollToHash, 400))
setTimeout(scrollToHash, 200)

// Quick search shortcut (/)
window.addEventListener('keypress', (e) => {
  if (e.key === '/') {
    const el = document.getElementById('quick-search')
    if (el && el !== document.activeElement) {
      el.focus()
      el.select()
      e.preventDefault()
    }
  }
  return false
})

// HighlightJS custom element
customElements.define('prism-js', class HighlightJS extends HTMLElement {
  constructor() { super() }
  connectedCallback() {
    const pre = document.createElement('pre')

    pre.className = `language-elm`
    pre.textContent = this.body

    this.appendChild(pre)
    window.Prism.highlightElement(pre)
  }
})

// Dropdown arrow key support
customElements.define('dropdown-arrow-keys', class DropdownArrowKeys extends HTMLElement {
  constructor() {
    super()
  }
  connectedCallback() {
    const component = this
    const arrows = { ArrowUp: -1, ArrowDown: 1 }
    const interactiveChildren = () => component.querySelectorAll('input, a, button')

    const onBlur = (e) => window.requestAnimationFrame(_ => {
      const active = document.activeElement
      const siblings = interactiveChildren()
      let foundFocusedSibling = false

      e.target.removeEventListener('blur', onBlur)

      siblings.forEach(sibling => {
        if (sibling === active) {
          sibling.addEventListener('blur', onBlur)
          foundFocusedSibling = true
        }
      })
      if (foundFocusedSibling === false) {
        component.dispatchEvent(new CustomEvent('clearDropdown'))
        siblings.forEach(el => el.addEventListener('focus', _ => el.addEventListener('blur', onBlur)))
      }
    })

    interactiveChildren().forEach(el => el.addEventListener('blur', onBlur))

    component.addEventListener('keydown', (e) => {
      const delta = arrows[e.key]
      if (delta) {
        e.preventDefault()
        const interactive = interactiveChildren()
        const count = interactive.length
        const active = document.activeElement
        if (count < 2) return

        interactive.forEach((el, i) => {
          if (active == el) {
            const next = interactive[(i + delta + count) % count]
            next.focus()
          }
        })
      }
    })
  }
})

window.addEventListener('keyup', (e) => {
  const el = document.getElementById('quick-search')
  if (e.key === 'Escape' && el === document.activeElement) {
    if (el) el.blur()
  }
})