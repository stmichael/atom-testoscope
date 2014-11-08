module.exports =
class TestSuiteResult

  constructor: ->
    @testcases = []

  getTestcases: ->
    @testcases

  getFirstFailure: ->
    for testcase in @testcases
      if testcase.status == 'failed'
        return testcase

  addFailure: (failure) ->
    failure.status = 'failed'
    @testcases.push failure

  addSuccess: (success) ->
    success.status = 'passed'
    @testcases.push success

  wasSuccessful: ->
    for testcase in @testcases
      if testcase.status == 'failed'
        return false
    true

  getNumberOfTestcases: ->
    @testcases.length
