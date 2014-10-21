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
    execDefer.promise.then ->
      execCallback(null)
    execDefer.promise.catch (errorCode) ->
      execCallback(code: errorCode)

    require '../lib/test-runner'
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.workspace.open('rspec_spec.rb')
    waitsForPromise ->
      atom.packages.activatePackage('status-bar')
    waitsForPromise ->
      promise = atom.packages.activatePackage('test-runner')
      atom.workspaceView.trigger 'test-runner:toggle'
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
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('All tests in rspec_spec.rb have been successful')

    it 'shows a failure message', ->
      atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
      runs ->
        execDefer.reject(1)
      waitsForPromise shouldReject: true, ->
        execDefer.promise

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('The tests in rspec_spec.rb were faulty')
