path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
RspecReportParser = require '../report-parsers/rspec-report-parser'

module.exports =
class RspecHandler extends BaseHandler

  constructor: (options) ->
    super
    options = options || {}
    @useBundler = options.useBundler

  _getCommand: (testFilePath, reportPath) ->
    if @useBundler
      "bundle"
    else
      "rspec"

  _getCommandArgs: (testFilePath, reportPath) ->
    if @useBundler
      ['exec', 'rspec', '--format', 'progress', '--format', 'json', '--out', path.join(reportPath, 'rspec.json'), testFilePath]
    else
      ['--format', 'progress', '--format', 'json', '--out', path.join(reportPath, 'rspec.json'), testFilePath]

  parseErrors: (defer) ->
    fs.readdir @getReportPath(), (err, files) =>
      console.log files
      if files.length > 0
        file = path.join(@getReportPath(), 'rspec.json')
        fs.readFile file, encoding: 'UTF-8', (err, data) =>
          if data.match(/^\s*$/)
            defer.reject()
          else
            result = new RspecReportParser().parse(data)
            defer.resolve result
      else
        defer.reject()
