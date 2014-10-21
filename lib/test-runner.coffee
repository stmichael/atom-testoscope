QuickResultView = require './quick-result-view'
{Emitter} = require 'event-kit'
{exec} = require 'child_process'
TestHandlerRegistry = require './test-handler-registry'

class BaseHandler

class RspecHandler extends BaseHandler

  run: (callback) ->
    exec 'ls', callback

handlerRegistry = new TestHandlerRegistry
handlerRegistry.add(new RspecHandler, /_spec\.rb$/)

class TestSuite

  constructor: (@handlerRegistry) ->
    @emitter = new Emitter

  run: (testPath) ->
    @emitter.emit 'did-start'
    handler = @handlerRegistry.findForFile(testPath)
    handler.run (error) =>
      if error
        @emitter.emit 'was-faulty', executedFile: 'rspec_spec.rb'
      else
        @emitter.emit 'was-successful', executedFile: 'rspec_spec.rb'

  onDidStart: (callback) ->
    @emitter.on 'did-start', callback

  onWasSuccessful: (callback) ->
    @emitter.on 'was-successful', callback

  onWasFaulty: (callback) ->
    @emitter.on 'was-faulty', callback

module.exports =
  activate: (state) ->
    @testSuite = new TestSuite(handlerRegistry)
    @quickResultView = new QuickResultView()
    @testSuite.onDidStart =>
      @quickResultView.setRunning()
    @testSuite.onWasSuccessful (event) =>
      @quickResultView.setSuccessful(event.executedFile)
    @testSuite.onWasFaulty (event) =>
      @quickResultView.setFaulty(event.executedFile)

    atom.workspaceView.statusBar?.appendLeft(@quickResultView)

    atom.workspaceView.command 'test-runner:run-all', =>
      @testSuite.run(atom.workspace.getActiveTextEditor().getPath())

  deactivate: ->
    @quickResultView.destroy() if @quickResultView

  handlerRegistry: handlerRegistry
