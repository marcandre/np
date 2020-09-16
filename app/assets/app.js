import CodeMirror from 'codemirror/lib/codemirror'

class App {
  constructor(form) {
    this.form = form
    this.pattern = form.querySelector('textarea[name="pattern"]')
    this.npCodemirror = this.initCodeMirror(this.pattern, 'text/text');

    this.ruby = form.querySelector('textarea[name="ruby"]')
    this.rubyCodemirror = this.initCodeMirror(this.ruby, 'text/x-ruby')

    this.update(this.rubyCodemirror)
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
    this.clearMarks()
    this.updateHTML(data.html)
    this.addMarks(data.node_pattern_unist)
    this.addMarks(data.comments_unist)
  }

  addMarks(data) {
    if (!data)
      return

    const match = App.MATCH[data.matched]
    if (match && data.position)
      this.marks.push(
        this.npCodemirror.markText(
          this.unist_point(data.position.start),
          this.unist_point(data.position.end),
          {
            className: 'dummy', // https://github.com/codemirror/CodeMirror/issues/6414
            attributes: {'data-match': match}
          }
        )
      )
    for(const child of data.children || [])
      this.addMarks(child)
  }

  unist_point(point) {
    return {line: point.line - 1, ch: point.column - 1}
  }

  clearMarks() {
    if (this.marks)
      this.marks.forEach(mark => mark.clear())
    this.marks = []
  }

  updateHTML(data) {
    for(const id in data) {
      document.getElementById(id).innerHTML = data[id]
    }
  }

  initCodeMirror(textarea, mode) {
    const config = {
      mode,
      matchBrackets: true,
      autoCloseBrackets: true,
      theme: 'ambiance',
      extraKeys: { Tab: (cm) => this.tab(cm) }
    }
    const cm = CodeMirror.fromTextArea(textarea, config)
    cm.on('changes', () => this.update(cm)) // https://github.com/codemirror/CodeMirror/issues/6416
    this.setupResize(cm)
    return cm
  }

  // Resize code adapted from https://codepen.io/sakifargo/pen/KodNyR
  resize(cm) {
    cm.setSize(this.resizeFrame(cm).clientWidth + 2,   // Chrome needs +2, others don't mind...
               this.resizeFrame(cm).clientHeight - 10) // And CM needs room for the resize handle...
  }

  resizeFrame(cm) {
    return cm.getWrapperElement().parentNode
  }

  setupResize(cm) {
    // This is the actual "business logic" of the whole thing! ;)
    if (window.ResizeObserver) // Chrome 64+
      new ResizeObserver(() => this.resize(cm)).observe(this.resizeFrame(cm))
    else if (window.MutationObserver) // others
      new MutationObserver(() => this.resize(cm)).observe(this.resizeFrame(cm), {attributes: true})
    this.resize(cm)
  }

  tab(cm) {
    const other = cm == this.npCodemirror ? this.rubyCodemirror : this.npCodemirror
    other.focus()
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
