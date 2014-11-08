path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
JunitReportParser = require '../report-parsers/junit-report-parser'

module.exports =
class JasmineHandler extends BaseHandler

  _getCommand: (testFilePath, reportPath) ->
    "node_modules/jasmine-node/bin/jasmine-node --junitreport --output #{reportPath} #{testFilePath}"

  parseErrors: (successCallback, errorCallback, error, stdout, stderr) ->
    fs.readdir @getReportPath(), (err, files) =>
      if files.length > 0
        file = path.join(@getReportPath(), files[0])
        fs.readFile file, encoding: 'UTF-8', (err, data) =>
          result = new JunitReportParser().parse(data)
          successCallback(result)
      else
        errorCallback(stdout)
