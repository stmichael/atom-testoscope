QuickResultView = require './quick-result-view'
{Emitter} = require 'event-kit'
{exec} = require 'child_process'

class TestSuite

  constructor: ->
    @emitter = new Emitter

  run: ->
    @emitter.emit 'did-start'
    exec 'ls', (error) =>
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
    @testSuite = new TestSuite()
    @quickResultView = new QuickResultView()
    @testSuite.onDidStart =>
      @quickResultView.setRunning()
    @testSuite.onWasSuccessful (event) =>
      @quickResultView.setSuccessful(event.executedFile)
    @testSuite.onWasFaulty (event) =>
      @quickResultView.setFaulty(event.executedFile)

    atom.workspaceView.statusBar?.appendLeft(@quickResultView)

    atom.workspaceView.command 'test-runner:run-all', =>
      @testSuite.run()

  deactivate: ->
    @quickResultView.destroy() if @quickResultView
