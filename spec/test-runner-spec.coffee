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
      atom.packages.activatePackage('status-bar')
    waitsForPromise ->
      promise = atom.packages.activatePackage('test-runner')
      promise

  it 'exposes a handler registry', ->
    thisPackage = require '../lib/test-runner'
    TestHandlerRegistry = require '../lib/test-handler-registry'

    expect(thisPackage.handlerRegistry instanceof TestHandlerRegistry).toBeTruthy()

  describe 'running complete test files', ->
    it 'shows that the tests are running', ->
      waitsForPromise ->
        atom.workspace.open('example_spec.js')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'

        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-clock')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('running')

    it 'shows a success message', ->
      waitsForPromise ->
        atom.workspace.open('success_spec.js')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
        execDefer.resolve()
      waitsForPromise ->
        execDefer.promise

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-check')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('All tests in success_spec.js have been successful')

    it 'shows a failure message', ->
      waitsForPromise ->
        atom.workspace.open('fail_spec.js')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
        execDefer.resolve(errorCode: 1)
      waitsForPromise ->
        execDefer.promise

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('First failed test: fail_spec.js:3')

    it 'shows a message when no appropriate handler has been found', ->
      waitsForPromise ->
        atom.workspace.open('example.b')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('Don\'t know how to run example.b')
