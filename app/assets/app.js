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

    this.update()
  }

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

class App {
  constructor(form) {
    this.form = form
    this.pattern = new NodePatternEditor(this, 'text/text',
      form.querySelector('textarea[name="pattern"]'))
    this.ui = new Debugger(this)
  }

  update(mirror) {
    mirror.save() // Update textarea
    this.ui.update()
  }

  tab(cur) {
    this.ui.tab(cur)
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
