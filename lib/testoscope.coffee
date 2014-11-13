ResultStatusView = require './result-status-view'
StacktraceSelectView = require './stacktrace-select-view'
TestResultPanel = require './test-result-panel'

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
      @testResultPanel = new TestResultPanel

      @testSuite.onDidStart =>
        @resultStatusView.setRunning()
        @testResultPanel.clear()
        @testResultPanel.attach()
      @testSuite.onWasSuccessful (event) =>
        @resultStatusView.setSuccessful(atom.project.relativize(event.file))
        @testResultPanel.detach()
      @testSuite.onWasFaulty =>
        result = @testSuite.getLastResult()
        @resultStatusView.setFaulty("#{result.getFirstFailure().file}:#{result.getFirstFailure().line}")
        @testResultPanel.showFailure(result.getFirstFailure())
      @testSuite.onWasErroneous (event) =>
        @resultStatusView.setFaulty event.message
      @testSuite.onOutput (output) =>
        @testResultPanel.addOutput(output)

      atom.workspaceView.statusBar.appendLeft(@resultStatusView)

      atom.workspaceView.command 'testoscope:run-all', =>
        @testSuite.run(atom.workspace.getActiveTextEditor().getPath())
      atom.workspaceView.command 'testoscope:toggle-last-stack-trace', =>
        unless @testSuite.wasSuccessful()
          @stacktraceSelectView.show(@testSuite.getLastResult().getFirstFailure().stacktrace)
      atom.workspaceView.command 'core:cancel', =>
        @testResultPanel.detach()

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', =>
        createStatusEntry()

  deactivate: ->
    @resultStatusView.destroy() if @resultStatusView
    @stacktraceSelectView.destroy() if @stacktraceSelectView
    @testResultPanel.destroy() if @testResultPanel

  handlerRegistry: handlerRegistry
