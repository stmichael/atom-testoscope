xpath = require('xpath')
{DOMParser} = require('xmldom')
Entities = require('html-entities').AllHtmlEntities;
Stacktrace = require './stacktrace'
TestSuiteResult = require './test-suite-result'

module.exports =
class JunitReportParser
  parse: (data) ->
    result = new TestSuiteResult
    doc = new DOMParser().parseFromString(data)
    testcases = xpath.select('(//testcase)', doc)
    for testcase in testcases
      if xpath.select('./failure', testcase).length == 0
        result.addSuccess
          namespace: testcase.getAttribute('classname')
          name: testcase.getAttribute('name')
      else
        failure = xpath.select('./failure', testcase)[0]
        stacktraceTexts = @_buildArrayedStacktrace(xpath.select('./text()', failure)[0].nodeValue)
        stacktrace = new Stacktrace(@_parseStacktrace(stacktraceTexts))

        result.addFailure
          namespace: testcase.getAttribute('classname')
          name: testcase.getAttribute('name')
          messages: @_extractFailureMessages(xpath.select('./text()', failure)[0].nodeValue)
          file: atom.project.relativize(stacktrace.getTestCaller().file)
          line: stacktrace.getTestCaller().line
          fullStacktrace: stacktrace.getFullTrace()
          stacktrace: stacktrace.getRelevantTrace()

    result

  _buildArrayedStacktrace: (stacktrace) ->
    entities = new Entities
    result = entities.decode(stacktrace).split("\n")
    result = (line.replace(/^\s+/g, '') for line in result)
    result.filter (line) ->
      line.length > 0 && line.match(/(\/[^\/]+)+/)

  _parseStacktrace: (stacktraceText) ->
    result = []
    for line in stacktraceText
      matchData = line.match(/at (.*) \(((\/[^\/:]+)+):(\d+)/)
      if matchData
        result.push
          caller: matchData[1]
          file: matchData[2]
          line: matchData[4]
    result

  _extractFailureMessages: (stacktrace) ->
    entities = new Entities
    stacktraceLines = entities.decode(stacktrace).split("\n")
      .filter (line) ->
        line.length > 0
    [stacktraceLines[0].replace(/^\s+/g, '')]
