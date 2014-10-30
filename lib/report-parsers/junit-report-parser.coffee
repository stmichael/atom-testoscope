path = require 'path'
xpath = require('xpath')
{DOMParser} = require('xmldom')

module.exports =
class JunitReportParser
  parse: (data) ->
    doc = new DOMParser().parseFromString(data)
    failures = xpath.select('(//failure)', doc)
    for failure in failures
      fullStacktraceText = @_buildArrayedStacktrace(xpath.select('./text()', failure)[0].nodeValue)
      fullStacktrace = @_parseStacktrace(fullStacktraceText)
      stacktrace = @_extractRelevantLines(fullStacktrace)
      callerLine = @_extractTestCaller(stacktrace)

      namespace: failure.parentNode.getAttribute('classname')
      name: failure.parentNode.getAttribute('name')
      message: failure.getAttribute('message')
      file: atom.project.relativize(callerLine.file)
      line: callerLine.line
      fullStacktrace: fullStacktrace
      stacktrace: stacktrace

  _buildArrayedStacktrace: (stacktrace) ->
    result = stacktrace.split("\n")
    result = (line.replace(/^\s*/g, '') for line in result)
    result.filter (line) ->
      line.length > 0 && line.match(/(\/[\w\d\-_\.]+)+/)

  _parseStacktrace: (stacktraceText) ->
    for line in stacktraceText
      matchData = line.match(/at (.*) \(((\/[^\/:]+)+):(\d+)/)
      caller: matchData[1]
      file: matchData[2]
      line: matchData[4]

  _extractRelevantLines: (stacktrace) ->
    blacklistRegex = new RegExp('node_modules')
    whitelistRegex = new RegExp('(\\/[\\w\\d\\-_]+)+')
    stacktrace.filter (line) ->
      line.file.match(whitelistRegex) && !line.file.match(blacklistRegex)

  _extractTestCaller: (stacktrace) ->
    lineRegex = new RegExp(atom.project.getPaths()[0])
    for line in stacktrace.slice(0).reverse()
      if line.file.match(lineRegex)
        return line
