{WorkspaceView, $} = require 'atom'
StacktraceView = require '../lib/stacktrace-view'

describe 'stacktrace view', ->

  view = undefined
  stacktrace = [
    {file: '/Users/someuser/Projects/atom/test-runner/lib/file.js', line: '8', caller: 'test_method'}
    {file: '/Users/someuser/Projects/atom/test-runner/source.js', line: '54', caller: 'start'}
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

    expect(view.find('li div:first-child').map((i, e) -> $(e).text())
      .toArray()).toEqual [
        'file.js:8 at test_method',
        'source.js:54 at start'
      ]

  it 'shows the line number along with the stacktrace', ->
    view.show stacktrace

    expect(view.find('li:first-child div:first-child').text()).toEqual 'file.js:8 at test_method'
    expect(view.find('li:first-child div:last-child').text()).toEqual 'lib/file.js'

  it 'opens the selected file', ->
    view.show stacktrace
    view.trigger 'core:confirm'

    waitsFor ->
      atom.workspace.getActiveTextEditor() != undefined &&
        atom.workspace.getActiveTextEditor().getPath().match /file\.js$/
