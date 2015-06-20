module.exports = LinterSwiftc =
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  scopes: ['source.swift']

  activate: ->
    console.log 'activate linter-swiftc'# if atom.inDevMode()
    unless atom.packages.getLoadedPackages 'linter-plus'
      @atom.notifications.addError '[linter-swiftc] `linter-plus` package not found, please install it'

  provideLinter: -> {
    grammarScopes: @scopes
    scope: 'file'
    lint: @lint
    lintOnFly: false
  }

  lint: (TextEditor) ->
    child_process = require 'child_process'
    path = require 'path'

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
        file = TextEditor.getTitle()
        cwd = path.dirname(TextEditor.getPath())
        data = []
        process = child_process.exec "swiftc -parse #{file}", {cwd: cwd}
        process.stderr.on 'data', (d) -> data.push d.toString()
        process.on 'close', ->
          content = []
          for line in data
            console.log "linter-swiftc command output: #{line}" if atom.inDevMode()
            content.push line.match(regex)[1..5] if line.match regex
          toReturn = []
          content.forEach (regex) ->
            if regex
              toReturn.push(
                type: regex[3],
                text: regex[4],
                filePath: path.join(cwd, regex[0]).normalize()
                range: [[regex[1] - 1, regex[2] - 1], [regex[1] - 1, regex[2] - 1]]
              )
          Resolve(toReturn)
