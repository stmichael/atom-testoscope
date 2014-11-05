module.exports =
class TestSuiteResult

  constructor: ->
    @failures = []

  addFailure: (failure) ->
    @failures.push failure

  getFailures: ->
    @failures

  getFirstFailure: ->
    @failures[0]

  wasSuccessful: ->
    @failures.length == 0
