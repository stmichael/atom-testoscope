{WorkspaceView, $} = require 'atom'
StacktraceView = require '../lib/stacktrace-view'

describe 'stacktrace view', ->

  view = undefined
  stacktrace = [
    'at /Users/someuser/Projects/atom/test-runner/file.js:8:29',
    'at /Users/someuser/Projects/atom/test-runner/source.js:54:12'
  ]

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner/dummy'])
    view = new StacktraceView

  it 'shows from the top down', ->
    view.show []

    expect(view).toHaveClass('overlay from-top')

  it 'lists all items', ->
    view.show stacktrace

    expect(view.find('li').map((i, e) -> $(e).text())
      .toArray()).toEqual [
        'file.js',
        'source.js'
      ]

  it 'opens the selected file', ->
    view.show stacktrace
    view.trigger 'core:confirm'

    waitsFor ->
      atom.workspace.getActiveTextEditor() != undefined &&
        atom.workspace.getActiveTextEditor().getPath().match /file\.js$/
