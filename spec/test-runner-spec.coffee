{WorkspaceView} = require 'atom'
ChildProcess = require 'child_process'
Q = require 'q'

# stub exec
execCallback = undefined
ChildProcess.exec = (command, callback) ->
  execCallback = callback

describe "TestRunner", ->
  execDefer = undefined

  beforeEach ->
    execDefer = Q.defer()
    execDefer.promise.then (error) ->
      execCallback(error)

    require '../lib/test-runner'
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.workspace.open('example_spec.js')
    waitsForPromise ->
      atom.packages.activatePackage('status-bar')
    waitsForPromise ->
      promise = atom.packages.activatePackage('test-runner')
      promise

  it 'exposes a handler registry', ->
    thisPackage = require '../lib/test-runner'
    TestHandlerRegistry = require '../lib/test-handler-registry'

    expect(thisPackage.handlerRegistry instanceof TestHandlerRegistry).toBeTruthy()

  describe 'running tests', ->
    it 'shows that the tests are running', ->
      atom.workspaceView.getActiveView().trigger 'test-runner:run-all'

      expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-clock')
      expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('running')

    it 'shows a success message', ->
      atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
      runs ->
        execDefer.resolve()
      waitsForPromise ->
        execDefer.promise

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-check')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('All tests in example_spec.js have been successful')

    it 'shows a failure message', ->
      atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
      runs ->
        execDefer.resolve(errorCode: 1)
      waitsForPromise ->
        execDefer.promise

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('The tests in example_spec.js were faulty')

    it 'shows a message when no appropriate handler has been found', ->
      waitsForPromise ->
        atom.workspace.open('example.b')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('Don\'t know how to run example.b')
