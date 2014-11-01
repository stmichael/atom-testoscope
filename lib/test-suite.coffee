{Emitter} = require 'event-kit'
path = require 'path'
TestHandlerFactory = require './test-handler-factory'

module.exports =
class TestSuite

  constructor: (handlerRegistry) ->
    @emitter = new Emitter
    @lastFailure = []
    @handlerFactory = new TestHandlerFactory(handlerRegistry)

  run: (file) ->
    @emitter.emit 'did-start'
    @handlerFactory.readConfigurations()
    @_runFile(file)

  _runFile: (file) ->
    @lastFailure = []
    filename = atom.project.relativize(file)
    handler = @handlerFactory.findByPath(file)
    if handler
      @lastFile = file
      handler.run(file, (=> @_testSuccessCallback(filename)), @_testFailureCallback)
    else if @lastFile
      @_runFile(@lastFile)
    else
      @emitter.emit 'was-faulty', message: "Don't know how to run #{filename}"

  _testSuccessCallback: (filename) =>
    @emitter.emit 'was-successful', message: filename

  _testFailureCallback: (failures) =>
    @lastFailure = failures
    @emitter.emit 'was-faulty', message: "#{failures[0].file}:#{failures[0].line}"

  wasLastTestFailure: ->
    @lastFailure.length > 0

  onDidStart: (callback) ->
    @emitter.on 'did-start', callback

  onWasSuccessful: (callback) ->
    @emitter.on 'was-successful', callback

  onWasFaulty: (callback) ->
    @emitter.on 'was-faulty', callback
