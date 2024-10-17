import CodeMirror from 'codemirror/lib/codemirror'
import 'codemirror/addon/edit/matchbrackets'
import 'codemirror/addon/edit/closebrackets'
import 'codemirror/mode/ruby/ruby'
import 'bootstrap'

import App from './app'

document.addEventListener('DOMContentLoaded', () => {
  const app = new App(document.querySelector('form'))
  window.app = app;
})
