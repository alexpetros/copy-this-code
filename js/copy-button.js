// Remember to include this script with the "defer" attribute

class CopyButton extends HTMLElement {
  static DEFAULT_CONFIRMATION_TEXT = 'Copied!'

  connectedCallback() {
    this.isClicked = false
    this.displayText = this.innerText

    this.innerHTML = ''

    this.content = this.getAttribute('content')
    this.confirmText = this.getAttribute('confirmtext') || CopyButton.DEFAULT_CONFIRMATION_TEXT

    const button = document.createElement('button')
    button.innerText = this.displayText
    button.className = this.className

    button.onclick = () => {
      this.isClicked = true
      button.innerText = this.confirmText
      button.disabled = true
      navigator.clipboard.writeText(this.content)

      setTimeout(() => {
        button.innerText = this.displayText
        button.disabled = false
      }, 1000)
    }

    this.appendChild(button)
  }
}

customElements.define('copy-button', CopyButton)
