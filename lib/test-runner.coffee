ResultStatusView = require './result-status-view'
StacktraceSelectView = require './stacktrace-select-view'
StacktraceView = require './stacktrace-view'

TestSuite = require './test-suite'
TestHandlerRegistry = require './test-handler-registry'
TestHandlerFactory = require './test-handler-factory'

KarmaHandler = require './handlers/karma-handler'
JasmineHandler = require './handlers/jasmine-handler'
RspecHandler = require './handlers/rspec-handler'

handlerRegistry = new TestHandlerRegistry
handlerRegistry.add('karma', KarmaHandler)
handlerRegistry.add('jasmine', JasmineHandler)
handlerRegistry.add('rspec', RspecHandler)

handlerFactory = new TestHandlerFactory(handlerRegistry)

module.exports =
  activate: (state) ->
    createStatusEntry = ->
      @testSuite = new TestSuite(handlerFactory)
      @resultStatusView = new ResultStatusView
      @stacktraceSelectView = new StacktraceSelectView
      @stacktraceView = new StacktraceView

      @testSuite.onDidStart =>
        @resultStatusView.setRunning()
        @stacktraceView.detach()
      @testSuite.onWasSuccessful (event) =>
        @resultStatusView.setSuccessful(atom.project.relativize(event.file))
      @testSuite.onWasFaulty =>
        result = @testSuite.getLastResult()
        @resultStatusView.setFaulty("#{result.getFirstFailure().file}:#{result.getFirstFailure().line}")
        @stacktraceView.show(result.getFirstFailure())
      @testSuite.onWasErroneous (event) =>
        @resultStatusView.setFaulty event.message

      atom.workspaceView.statusBar.appendLeft(@resultStatusView)

      atom.workspaceView.command 'test-runner:run-all', =>
        @testSuite.run(atom.workspace.getActiveTextEditor().getPath())
      atom.workspaceView.command 'test-runner:toggle-last-stack-trace', =>
        unless @testSuite.wasSuccessful()
          @stacktraceSelectView.show(@testSuite.getLastResult().getFirstFailure().stacktrace)
      atom.workspaceView.command 'core:cancel', =>
        @stacktraceView.detach()

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', =>
        createStatusEntry()

  deactivate: ->
    @resultStatusView.destroy() if @resultStatusView

  handlerRegistry: handlerRegistry
