import CodeMirror from 'codemirror/lib/codemirror'
import { NodePatternEditor, RubyEditor } from './editors'
class App {
  constructor(form) {
    this.form = form
    this.pattern = new NodePatternEditor(this, 'text/text',
      form.querySelector('textarea[name="pattern"]'))

    this.ruby = new RubyEditor(this, 'text/x-ruby',
      form.querySelector('textarea[name="ruby"]'))

    this.update(this.ruby.cm)
  }

  makePermalink() {
    let p = this.pattern.uriComponent()
    let ruby = this.ruby.uriComponent()
    history.pushState(null, '', `?p=${p}&ruby=${ruby}`)
    let prompt = document.querySelector('.prompt.make-permalink')
    prompt.classList.remove('invisible')
    setTimeout(() => { prompt.classList.add('invisible') }, 750)
  }

  update(mirror) {
    mirror.save() // Update textarea
    fetch('/update', {
      method: 'POST',
      body: new FormData(this.form)
    })
      .then(response => response.json())
      .then(data => this.process(data))
  }

  process(data) {
    this.pattern.clearMarks()
    this.ruby.clearMarks()
    this.updateHTML(data.html)
    this.pattern.addMarks(data.node_pattern_unist)
    this.pattern.addMarks(data.comments_unist)
    this.ruby.addMarks(data)
  }

  updateHTML(data) {
    for(const id in data) {
      document.getElementById(id).innerHTML = data[id]
    }
  }

  tab(cur) {
    const other = cur == this.ruby ? this.pattern : this.ruby
    other.cm.focus()
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
