ChildProcess = require 'child_process'
console.log 'here'

window.mockExec = ->
  data =
    originalFunction: ChildProcess.exec
    command: undefined
    callback: undefined
  ChildProcess.exec = (command, callback) ->
    data.command = command
    data.callback = callback
  data

window.resetExec = (data) ->
  ChildProcess.exec = data.originalFunction
