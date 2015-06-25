path = require 'path'
child_process = require 'child_process'

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
  lint: (TextEditor) ->
    new Promise (Resolve) ->
      file = path.basename TextEditor.getPath()
      cwd = path.dirname TextEditor.getPath()
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
            [file, line, column, type, message] = line.match(regex)[1..5]
            toReturn.push(
              type: type,
              text: message,
              filePath: path.join(cwd, file).normalize()
              range: [[line - 1, column - 1], [line - 1, column - 1]]
            )
        Resolve toReturn
