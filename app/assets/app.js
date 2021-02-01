import CodeMirror from 'codemirror/lib/codemirror'

class CodeMirrorEditor {
  constructor(app, mode, input) {
    this.marks = []
    this.app = app
    this.input = input

    const config = {
      mode,
      matchBrackets: true,
      autoCloseBrackets: true,
      theme: 'ambiance',
      extraKeys: { Tab: (cm) => app.tab(this) }
    }
    this.cm = CodeMirror.fromTextArea(input, config)
    this.cm.on('changes', () => this.app.update(this.cm)) // https://github.com/codemirror/CodeMirror/issues/6416
    this.setupResize()
  }

  setupResize(cm) {
    // This is the actual "business logic" of the whole thing! ;)
    if (window.ResizeObserver) // Chrome 64+
      new ResizeObserver(() => this.resize(cm)).observe(this.resizeFrame(cm))
    else if (window.MutationObserver) // others
      new MutationObserver(() => this.resize(cm)).observe(this.resizeFrame(cm), {attributes: true})
    this.resize(cm)
  }

  // Resize code adapted from https://codepen.io/sakifargo/pen/KodNyR
  resize() {
    this.cm.setSize(this.resizeFrame().clientWidth + 2,   // Chrome needs +2, others don't mind...
               this.resizeFrame().clientHeight - 10) // And CM needs room for the resize handle...
  }

  resizeFrame() {
    return this.cm.getWrapperElement().parentNode
  }

  mark(unistPos, data) {
    this.marks.push(
      this.cm.markText(
        this.unistToPoint(unistPos.start),
        this.unistToPoint(unistPos.end),
        data
      )
    )
  }

  clearMarks() {
    this.marks.forEach(mark => mark.clear())
    this.marks = []
  }

  unistToPoint(point) {
    return {line: point.line - 1, ch: point.column - 1}
  }

  uriComponent() {
    return encodeURIComponent(this.input.value)
  }
}

class NodePatternEditor extends CodeMirrorEditor {
  addMarks(data) {
    if (!data)
      return

    const match = App.MATCH[data.matched]
    const attr = {
      className: 'dummy', // https://github.com/codemirror/CodeMirror/issues/6414
      attributes: {'data-match': match}
    }
    if (match && data.position)
      this.mark(data.position, attr)
    for(const child of data.children || [])
      this.addMarks(child)
  }
}

class RubyEditor extends CodeMirrorEditor {
  addMarks(data) {
    const className = App.MATCH[data.node_pattern_unist.matched]
    this.mark(data.best_match, { className })

    for(const other of data.also_matched)
      this.mark(other, { className: 'also-matched' })
  }
}

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
