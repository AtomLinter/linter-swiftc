path = require 'path'
helpers = require 'atom-linter';
child_process = require 'child_process'

VALID_SEVERITY = ['error', 'warning', 'info']

getSeverity = (givenSeverity) ->
  severity = givenSeverity.toLowerCase()
  return if severity not in VALID_SEVERITY then 'warning' else severity

module.exports = class LinterProvider
  regex = ///
    (\S+):  #The file with issue.
    (\d+):  #The line number with issue.
    (\d+):  #The column where the issue begins.
    \s+     #A space.
    (\w+):  #The type of issue being reported.
    \s+     #A space.
    (.*)    #A message explaining the issue at hand.
  ///

  getCommand = -> "#{atom.config.get 'linter-swiftc.compilerExecPath'} -parse"

  getCommandWithFile = (file) -> "#{getCommand()} #{file}"

  # This is based on code taken right from the linter-plus rewrite
  #   of `linter-crystal`.
  lint: (textEditor) ->
    new Promise (Resolve) ->
      file = path.basename textEditor.getPath()
      cwd = path.dirname textEditor.getPath()
      data = []
      command = getCommandWithFile file
      console.log "Swift Linter Command: #{command}" if atom.inDevMode()
      process = child_process.exec command, {cwd: cwd}
      process.stderr.on 'data', (d) -> data.push d.toString()
      process.on 'close', ->
        toReturn = []
        for line in data
          console.log "Swift Linter Provider: #{line}" if atom.inDevMode()
          if line.match regex
            [file, line, column, severity, excerpt] = line.match(regex)[1..5]
            toReturn.push
              severity: getSeverity(severity)
              excerpt: excerpt
              location:
                file: path.join(cwd, file).normalize()
                position: helpers.generateRange(textEditor, Number.parseInt(line, 10) - 1, Number.parseInt(column, 10) - 1)
        Resolve toReturn
