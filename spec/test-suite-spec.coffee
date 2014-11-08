TestSuite = require '../lib/test-suite'
TestHandlerRegistry = require '../lib/test-handler-registry'
TestHandlerFactory = require '../lib/test-handler-factory'
Q = require 'q'

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
  successHandler.prototype.run = (file) ->
    defer = Q.defer()
    defer.promise
  failureHandler = ->
  failureHandler.prototype.run = (file) ->
    defer = Q.defer()
    defer.promise

  executionDefer = undefined
  handler = ->
  handler.prototype.run = ->
    executionDefer = Q.defer()
    executionDefer.promise

  beforeEach ->
    handlerRegistry = new TestHandlerRegistry
    handlerRegistry.add 'jasmine', handler
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
    event = undefined
    testSuite.onWasSuccessful (e) ->
      event = e

    testSuite.run 'example_spec.js'
    executionDefer.resolve(successfulResult)

    waitsFor ->
      event isnt undefined
    runs ->
      expect(event.file).toEqual 'example_spec.js'
      expect(testSuite.wasSuccessful()).toBeTruthy()

  it 'emits an event when the command put something on stdout', ->
    output = ''
    testSuite.onOutput (data) ->
      output = output + data

    testSuite.run 'example_spec.js'
    executionDefer.notify 'command'
    executionDefer.notify 'successful'

    waitsFor ->
      output isnt ''
    runs ->
      expect(output).toEqual 'commandsuccessful'

  it 'emits an event when no appropriate handler has been found', ->
    event = undefined
    testSuite.onWasErroneous (e) ->
      event = e

    testSuite.run 'some_file.rb'

    expect(event.message).toEqual "Don't know how to run some_file.rb"

  it 'emits an event when the tests failed', ->
    called = false
    testSuite.onWasFaulty ->
      called = true

    testSuite.run 'example_spec.js'
    executionDefer.resolve(failureResult)

    waitsFor ->
      called
    runs ->
      expect(testSuite.wasSuccessful()).toBeFalsy()

  it 'runs the last test again when no handler has been found', ->
    firstCall = false
    testSuite.onWasSuccessful ->
      firstCall = true
    testSuite.run 'example_spec.js'
    executionDefer.resolve(successfulResult)
    waitsFor ->
      firstCall

    secondCall = false
    runs ->
      testSuite.onWasFaulty ->
        secondCall = true
      testSuite.run 'example_spec.rb'
      executionDefer.resolve(failureResult)

    waitsFor ->
      secondCall
    runs ->
      expect(testSuite.wasSuccessful()).toBeFalsy()

  describe 'failure check', ->

    it 'is false when no tests have been run', ->
      expect(testSuite.wasSuccessful()).toBeTruthy()

    it 'is false when the tests have been successful', ->
      called = false
      testSuite.onWasSuccessful ->
        called = true
      testSuite.run 'example_spec.js'
      executionDefer.resolve(successfulResult)

      waitsFor ->
        called
      runs ->
        expect(testSuite.wasSuccessful()).toBeTruthy()

    it 'is true when the tests failed', ->
      called = false
      testSuite.onWasFaulty ->
        called = true
      testSuite.run 'example_spec.js'
      executionDefer.resolve(failureResult)

      waitsFor ->
        called
      runs ->
        expect(testSuite.wasSuccessful()).toBeFalsy()
