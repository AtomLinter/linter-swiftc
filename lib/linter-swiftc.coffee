child_process = require 'child_process'
path = require 'path'

module.exports = LinterSwiftc =
  activate: ->
    unless atom.packages.getLoadedPackages 'linter-plus'
      @atom.notifications.addError '[linter-swiftc] `linter-plus` package not found, please install it'

  provideLinter: -> {
    grammarScopes: ['source.swift']
    scope: 'file'
    lint: @lint
    lintOnFly: false
  }

  lint: (TextEditor) ->
    # Sample of conforming text:
    #   type_assignment_error.swift:1:17: error: 'Int' is not convertible to 'String'
    regex = ///
      (\S+):  #The file with issue.
      (\d+):  #The line number with issue.
      (\d+):  #The column where the issue begins.
      \s+     #A space.
      (\w+):  #The type of issue being reported.
      \s+     #A space.
      (.*)    #A message explaining the issue at hand.
    ///
    return new Promise (Resolve) ->
      if TextEditor.getPath()
        file = path.basename TextEditor.getPath()
        cwd = path.dirname TextEditor.getPath()
        data = []
        process = child_process.exec "swiftc -parse #{file}", {cwd: cwd}
        process.stderr.on 'data', (d) -> data.push d.toString()
        process.on 'close', ->
          toReturn = []
          for line in data
            console.log "linter-swiftc command output: #{line}" if atom.inDevMode()
            if line.match regex
              match = line.match(regex)[1..5]
              file = match[0]
              line = match[1]
              column = match[2]
              type = match[3]
              message = match[4]
              toReturn.push(
                type: type,
                text: message,
                filePath: path.join(cwd, file).normalize()
                range: [[line - 1, column - 1], [line - 1, column - 1]]
              )
          Resolve(toReturn)
