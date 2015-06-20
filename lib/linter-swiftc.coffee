module.exports = LinterSwiftc =
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  scopes: ['source.swift']

  activate: ->
    console.log 'activate linter-swiftc'# if atom.inDevMode()
    unless atom.packages.getLoadedPackages 'linter-plus'
      @showError '[linter-swiftc] `linter-plus` package not found, please install it'

  showError: (message = '') ->
    atom.notifications.addError message

  provideLinter: -> {
    grammarScopes: @scopes
    scope: 'file'
    lint: @lint
    lintOnFly: false
  }

  lint: (TextEditor) ->
    CP = require 'child_process'
    path = require 'path'
    XRegExp = require('xregexp').XRegExp

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
      filePath = TextEditor.getPath()
      file = TextEditor.getTitle()
      cwd = path.dirname(TextEditor.getPath())
      return unless filePath # Files that have not be saved
      Data = []
      Process = CP.exec("swiftc -parse #{file}", {cwd: cwd})
      Process.stderr.on 'data', (data) -> Data.push(data.toString())
      Process.on 'close', ->
        Content = []
        for line in Data
          console.log "linter-swiftc command output: #{line}" if atom.inDevMode()
          Content.push line.match(regex)[1..5] if line.match regex
        ToReturn = []
        Content.forEach (regex) ->
          if regex
            ToReturn.push(
              type: regex[3],
              text: regex[4],
              filePath: path.join(cwd, regex[0]).normalize()
              range: [[regex[1] - 1, regex[2] - 1], [regex[1] - 1, regex[2] - 1]]
            )
        Resolve(ToReturn)
