{Emitter} = require 'event-kit'
path = require 'path'

module.exports =
class TestSuite

  constructor: (@handlerRegistry) ->
    @emitter = new Emitter
    @lastErrors = []

  run: (file) ->
    @emitter.emit 'did-start'
    @_runFile(file)

  _runFile: (file) ->
    @lastErrors = []
    filename = path.basename(file)
    handler = @handlerRegistry.findForFile(file)
    if handler
      @lastFile = file
      handler.run(file, (=> @_testSuccessCallback(filename)), @_testFailureCallback)
    else if @lastFile
      @_runFile(@lastFile)
    else
      @emitter.emit 'was-faulty', message: "Don't know how to run #{filename}"

  _testSuccessCallback: (filename) =>
    @emitter.emit 'was-successful', message: filename

  _testFailureCallback: (errors) =>
    @lastErrors = errors
    @emitter.emit 'was-faulty', message: "#{errors[0].file}:#{errors[0].line} / #{errors[0].message}"

  wasLastTestErroneous: ->
    @lastErrors.length > 0

  onDidStart: (callback) ->
    @emitter.on 'did-start', callback

  onWasSuccessful: (callback) ->
    @emitter.on 'was-successful', callback

  onWasFaulty: (callback) ->
    @emitter.on 'was-faulty', callback
