TestSuite = require '../lib/test-suite'
TestHandlerRegistry = require '../lib/test-handler-registry'
TestHandlerFactory = require '../lib/test-handler-factory'

describe 'TestSuite', ->

  handlerRegistry = undefined
  testSuite = undefined
  successfulResult =
    wasSuccessful: ->
      true
  failureResult =
    wasSuccessful: ->
      false
    getFailures: ->
      [
        file: 'example_spec.js'
        line: '9'
      ]
  successHandler = ->
  successHandler.prototype.run = (file, successCallback, failureCallback) ->
    successCallback(successfulResult)
  failureHandler = ->
  failureHandler.prototype.run = (file, successCallback, failureCallback) ->
    successCallback(failureResult)

  beforeEach ->
    handlerRegistry = new TestHandlerRegistry
    handlerFactory = new TestHandlerFactory(handlerRegistry)
    testSuite = new TestSuite(handlerFactory)
    waitsForPromise ->
      atom.packages.activatePackage('status-bar')
    waitsForPromise ->
      atom.packages.activatePackage('testoscope')

  it 'emits an event before executing the tests', ->
    called = false
    testSuite.onDidStart ->
      called = true

    testSuite.run 'example_spec.js'

    expect(called).toBeTruthy()

  it 'emits an event when the tests passed', ->
    handlerRegistry.add 'jasmine', successHandler
    event = undefined
    testSuite.onWasSuccessful (e) ->
      event = e

    testSuite.run 'example_spec.js'

    expect(event.file).toEqual 'example_spec.js'

  it 'emits an event when no appropriate handler has been found', ->
    handlerRegistry.add 'jasmine', successHandler
    event = undefined
    testSuite.onWasErroneous (e) ->
      event = e

    testSuite.run 'some_file.rb'

    expect(event.message).toEqual "Don't know how to run some_file.rb"

  it 'emits an event when the tests failed', ->
    handlerRegistry.add 'jasmine', failureHandler
    called = false
    testSuite.onWasFaulty ->
      called = true

    testSuite.run 'example_spec.js'

    expect(called).toBeTruthy()

  it 'runs the last test again when no handler has been found', ->
    handlerRegistry.add 'jasmine', successHandler
    testSuite.run 'example_spec.js'

    event = undefined
    testSuite.onWasSuccessful (e) ->
      event = e
    testSuite.run 'example_spec.rb'

    expect(event.file).toEqual 'example_spec.js'

  describe 'failure check', ->

    it 'is false when no tests have been run', ->
      expect(testSuite.wasSuccessful()).toBeTruthy()

    it 'is false when the tests have been successful', ->
      handlerRegistry.add 'jasmine', successHandler
      testSuite.run 'example_spec.js'

      expect(testSuite.wasSuccessful()).toBeTruthy()

    it 'is true when the tests failed', ->
      handlerRegistry.add 'jasmine', failureHandler
      testSuite.run 'example_spec.js'

      expect(testSuite.wasSuccessful()).toBeFalsy()
