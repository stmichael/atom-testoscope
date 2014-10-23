require '../spec-helper'
path = require 'path'

JasmineHandler = require '../../lib/handlers/jasmine-handler'

describe 'JasmineHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeJasmineHandler extends JasmineHandler
    getReportPath: ->
      path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports')

    cleanReportPath: ->

  beforeEach ->
    handler = new FakeJasmineHandler
    mockExecData = mockExec()

  afterEach ->
    resetExec(mockExecData)

  it 'parses the junit report', ->
    failingTests = undefined
    errorCallback = (errors) ->
      failingTests = errors

    handler.run 'failing-test', noop, errorCallback
    mockExecData.callback(1)

    waitsFor ->
      failingTests != undefined
    runs ->
      expect(failingTests.length).toEqual 1
      failingTest = failingTests[0]
      expect(failingTest.namespace).toEqual 'jasmine test suite'
      expect(failingTest.name).toEqual 'a failing test',
      expect(failingTest.message).toEqual 'Expected true to equal false.',
      expect(failingTest.file).toEqual 'fail_spec.js',
      expect(failingTest.line).toEqual '6'
      expect(failingTest.stacktrace).toEqual [
        'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/fail_spec.js:6:18)'
      ]
      expect(failingTest.fullStacktrace).toEqual [
        'Error: Expected true to equal false.',
        'at new jasmine.ExpectationResult (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:114:32)',
        'at null.toEqual (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1316:29)',
        'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/node_modules/some_library.js:64:98)',
        'at null.&lt;anonymous&gt; (/Users/stmichael/Projects/atom/test-runner/spec/fixtures/fail_spec.js:6:18)',
        'at jasmine.Block.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:1145:17)',
        'at jasmine.Queue.next_ (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)',
        'at jasmine.Queue.start (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)',
        'at jasmine.Spec.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2458:14)',
        'at jasmine.Queue.next_ (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2177:31)',
        'at jasmine.Queue.start (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2130:8)',
        'at jasmine.Suite.execute (/Users/stmichael/Projects/atom/test-runner/node_modules/jasmine-node/lib/jasmine-node/jasmine-1.3.1.js:2604:14)'
      ]
