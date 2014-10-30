TestSuite = require '../lib/test-suite'
TestHandlerRegistry = require '../lib/test-handler-registry'

describe 'TestSuite', ->

  handlerRegistry = undefined
  testSuite = undefined
  successHandler =
    run: (file, successCallback, failureCallback) ->
      successCallback()
  failureHandler =
    run: (file, successCallback, failureCallback) ->
      failureCallback [
        file: 'some_file.js'
        line: '9'
      ]

  beforeEach ->
    handlerRegistry = new TestHandlerRegistry
    testSuite = new TestSuite(handlerRegistry)

  it 'emits an event before executing the tests', ->
    called = false
    testSuite.onDidStart ->
      called = true

    testSuite.run 'some_file.js'

    expect(called).toBeTruthy()

  it 'emits an event when the tests passed', ->
    handlerRegistry.add successHandler, /\.js$/
    event = undefined
    testSuite.onWasSuccessful (e) ->
      event = e

    testSuite.run 'some_file.js'

    expect(event.message).toEqual 'some_file.js'

  it 'emits an event when no appropriate handler has been found', ->
    handlerRegistry.add successHandler, /\.js$/
    event = undefined
    testSuite.onWasFaulty (e) ->
      event = e

    testSuite.run 'some_file.rb'

    expect(event.message).toEqual "Don't know how to run some_file.rb"

  it 'emits an event when the tests failed', ->
    handlerRegistry.add failureHandler, /\.js$/
    event = undefined
    testSuite.onWasFaulty (e) ->
      event = e

    testSuite.run 'some_file.js'

    expect(event.message).toEqual 'some_file.js:9'

  it 'runs the last test again when no handler has been found', ->
    handlerRegistry.add successHandler, /\.js$/
    testSuite.run 'some_file.js'

    event = undefined
    testSuite.onWasSuccessful (e) ->
      event = e
    testSuite.run 'some_file.rb'

    expect(event.message).toEqual 'some_file.js'

  describe 'failure check', ->

    it 'is false when no tests have been run', ->
      expect(testSuite.wasLastTestFailure()).toBeFalsy()

    it 'is false when the tests have been successful', ->
      handlerRegistry.add successHandler, /\.js$/
      testSuite.run 'some_file.js'

      expect(testSuite.wasLastTestFailure()).toBeFalsy()

    it 'is true when the tests failed', ->
      handlerRegistry.add failureHandler, /\.js$/
      testSuite.run 'some_file.js'

      expect(testSuite.wasLastTestFailure()).toBeTruthy()
