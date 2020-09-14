import CodeMirror from 'codemirror/lib/codemirror'

class App {
  constructor(form) {
    this.form = form
    this.pattern = form.querySelector('textarea[name="pattern"]')
    this.codemirror = CodeMirror.fromTextArea(this.pattern, this.cmConfig())
    form.addEventListener('input', () => this.update())
  }

  cmConfig() {
    return {
      value: "function myScript(){return 100;}\n",
      mode:  "javascript"
    }
  }

  update() {
    this.codemirror.save() // Update textarea
    fetch('/update', {
      method: 'POST',
      body: new FormData(this.form)
    })
      .then(response => response.json())
      .then(data => this.show(data))
  }

  show(data) {
    for(const id in data) {
      document.getElementById(id).innerHTML = data[id]
    }
  }
}

App.CodeMirror = CodeMirror

export default App
