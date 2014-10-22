require '../spec-helper'
path = require 'path'

BaseHandler = require '../../lib/handlers/base-handler'

describe 'BaseHandler', ->

  class FakeBaseHandler extends BaseHandler

    cleanReportPath: ->

    getCommand: (testFilePath, reportPath) ->
      "spec #{testFilePath}"

    parseErrors: (callback) ->
      callback [
        file: 'spec.js'
        line: '28'
      ]

  handler = undefined
  mockExecData = undefined
  noop = ->

  beforeEach ->
    handler = new FakeBaseHandler
    mockExecData = mockExec()

  afterEach ->
    resetExec(mockExecData)

  it 'executes the testing command successfully', ->
    called = false
    successCallback = ->
      called = true

    handler.run 'path/to/file', successCallback
    mockExecData.callback()

    waitsFor ->
      called
    runs ->
      expect(mockExecData.command).toMatch(/^bash -l -c 'cd .* spec path\/to\/file'$/)

  it 'the testing command was erroneous', ->
    called = false
    errorCallback = ->
      called = true

    handler.run 'path/to/file', noop, errorCallback
    mockExecData.callback(1)

    waitsFor ->
      called
    runs ->
      expect(mockExecData.command).toMatch(/^bash -l -c 'cd .* spec path\/to\/file'$/)

  describe 'tests were erroneous', ->
    it 'returns the last error', ->
      failingSpecs = undefined
      errorCallback = (errors) ->
        failingSpecs = errors

      handler.run 'failing_spec', noop, errorCallback
      mockExecData.callback(1)

      waitsFor ->
        failingSpecs != undefined
      runs ->
        expect(failingSpecs).toEqual [
          file: 'spec.js'
          line: '28'
        ]
