import CodeMirror from 'codemirror/lib/codemirror'
import { NodePatternEditor, RubyEditor } from './editors'

function updateHTML(data) {
  for(const id in data) {
    document.getElementById(id).innerHTML = data[id]
  }
}

class Debugger {
  constructor(app) {
    this.app = app
    this.pattern = app.pattern
    this.ruby = new RubyEditor(app, 'text/x-ruby',
      app.form.querySelector('textarea[name="ruby"]'))
  }

  mode = 'debug'

  makePermalink() {
    let p = this.pattern.uriComponent()
    let ruby = this.ruby.uriComponent()
    history.pushState(null, '', `?p=${p}&ruby=${ruby}`)
    let prompt = document.querySelector('.prompt.make-permalink')
    prompt.classList.remove('invisible')
    setTimeout(() => { prompt.classList.add('invisible') }, 750)
  }

  update() {
    fetch('/update', {
      method: 'POST',
      body: new FormData(this.app.form)
    })
      .then(response => response.json())
      .then(data => this.process(data))
  }

  process(data) {
    this.pattern.clearMarks()
    this.ruby.clearMarks()
    updateHTML(data.html)
    this.pattern.addMarks(data.node_pattern_unist)
    this.pattern.addMarks(data.comments_unist)
    this.ruby.addMarks(data)
  }

  tab(cur) {
    const other = cur == this.ruby ? this.pattern : this.ruby
    other.cm.focus()
  }
}

class Search{
  constructor(app) {
    this.app = app
    this.pattern = app.pattern
    this.results = document.getElementById('search_results')
    this.socket = null
  }

  mode = 'search'

  update() {
    if (this.socket)
      this.socket.close()

    this.socket = new WebSocket(`ws://${window.location.host}/search`)
    this.socket.addEventListener('open', () => {
      this.socket.send(this.pattern.input.value)
    })
    this.socket.addEventListener('message', (event) => process(event.data))
  }

  process(data) {
    console.log('received', data)
    this.results.insertAdjacentHTML('beforeend', data)
  }
}

class App {
  constructor(form) {
    this.form = form
    this.pattern = new NodePatternEditor(this, 'text/text',
      form.querySelector('textarea[name="pattern"]'))
    this.ui = this.debug = new Debugger(this)
    this.search = new Search(this)

    this.ui.update()
  }

  update(mirror) {
    mirror.save() // Update textarea
    this.ui.update()
  }

  tab(cur) {
    this.ui.tab(cur)
  }

  changeMode(elem) {
    const classes = document.documentElement.classList
    this.navClassList().remove('active')
    classes.remove(`mode-${this.ui.mode}`)
    this.ui = this[elem.getAttribute('data-mode')]
    this.navClassList().add('active')
    classes.add(`mode-${this.ui.mode}`)
    this.ui.update()
  }

  navClassList() {
    return document.querySelector(`.nav-link[data-mode="${this.ui.mode}"]`).classList
  }
}

App.CodeMirror = CodeMirror
App.MATCH = {
  false: 'not-matched',
  true: 'matched',
  null: 'not-visited',
  not_visitable: 'not-visitable',
  comment: 'comment',
}

export default App
