QuickResultView = require './quick-result-view'
{Emitter} = require 'event-kit'
TestHandlerRegistry = require './test-handler-registry'
JasmineHandler = require('./handlers/jasmine-handler')
RspecHandler = require('./handlers/rspec-handler')

handlerRegistry = new TestHandlerRegistry
handlerRegistry.add(new JasmineHandler, /_spec\.js$/)
handlerRegistry.add(new RspecHandler, /_spec\.rb$/)

class TestSuite

  constructor: (@handlerRegistry) ->
    @emitter = new Emitter

  run: (testPath) ->
    @emitter.emit 'did-start'
    handler = @handlerRegistry.findForFile(testPath)
    handler.run(testPath
      , =>
        @emitter.emit 'was-successful', executedFile: 'rspec_spec.rb'
      , =>
        @emitter.emit 'was-faulty', executedFile: 'rspec_spec.rb'
      )

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
