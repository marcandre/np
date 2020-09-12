import CodeMirror from 'codemirror/lib/codemirror'

class App {
  constructor(form) {
    this.form = form
    this.pattern = form.querySelector('textarea[name="pattern"]')
    this.npCodemirror = CodeMirror.fromTextArea(this.pattern, {
      mode: 'text/text',
      matchBrackets: true,
      autoCloseBrackets: true,
    })
    this.npCodemirror.on('changes', () => this.update(this.npCodemirror)) // https://github.com/codemirror/CodeMirror/issues/6416

    this.ruby = form.querySelector('textarea[name="ruby"]')
    this.rubyCodemirror = CodeMirror.fromTextArea(this.ruby, {
      mode: 'text/x-ruby',
      matchBrackets: true,
      autoCloseBrackets: true,
    })
    this.rubyCodemirror.on('changes', () => this.update(this.rubyCodemirror)) // https://github.com/codemirror/CodeMirror/issues/6416
  }

  cmConfig() {
    return {
      value: "function myScript(){return 100;}\n",
      mode:  "text"
    }
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
    this.clearMarks();
    this.updateHTML(data.html);
    this.addMarks(data.unist);
  }

  addMarks(data) {
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
      this.addMarks(child);
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
}

App.CodeMirror = CodeMirror
App.MATCH = {
  false: 'not-matched',
  true: 'matched',
  null: 'not-visited',
  not_visitable: 'not-visitable',
}

export default App
