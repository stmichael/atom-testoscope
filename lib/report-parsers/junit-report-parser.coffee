path = require 'path'
xpath = require('xpath')
{DOMParser} = require('xmldom')

module.exports =
class JunitReportParser
  parse: (data) ->
    doc = new DOMParser().parseFromString(data)
    failures = xpath.select('(//failure)', doc)
    for failure in failures
      fullStacktrace = @_buildArrayedStacktrace(xpath.select('./text()', failure)[0].nodeValue)
      stacktrace = @_extractRelevantLines(fullStacktrace)
      callerLine = @_extractTestCaller(stacktrace)

      namespace: failure.parentNode.getAttribute('classname')
      name: failure.parentNode.getAttribute('name')
      message: failure.getAttribute('message')
      file: callerLine.file
      line: callerLine.line
      fullStacktrace: fullStacktrace
      stacktrace: stacktrace

  _buildArrayedStacktrace: (stacktrace) ->
    result = stacktrace.split("\n")
    result = (line.replace(/^\s*/g, '') for line in result)
    result.filter (line) ->
      line.length > 0

  _extractRelevantLines: (stacktrace) ->
    blacklistRegex = new RegExp('node_modules')
    whitelistRegex = new RegExp('(\\/[\\w\\d\\-_]+)+')
    stacktrace.filter (line) ->
      line.match(whitelistRegex) && !line.match(blacklistRegex)

  _extractTestCaller: (stacktrace) ->
    lineRegex = new RegExp("(#{atom.project.getPaths()[0]}[^:]*):([0-9]+)")
    for line in stacktrace.slice(0).reverse()
      match = line.match(lineRegex)
      if match
        return {
          file: path.relative(atom.project.getPaths()[0], match[1])
          line: match[2]
        }
    file: undefined
    line: undefined
