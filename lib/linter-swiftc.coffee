module.exports = LinterSwiftc =
  activate: ->
    # Show the user an error if they do not have the appropriate
    #   Swift Language package from Atom Package Manager installed.
    atom.notification.addError(
      'Swift Language Package not found.',
      {
        detail: 'Please install the `language-swift` package in your
                  Settings view.'
      }
    ) unless atom.packages.getLoadedPackages 'language-swift'

    # Show the user an error if they do not have an appropriate linter based
    #   package installed from Atom Package Manager. This will not be an issue
    #   after a base linter package is integrated into Atom, in the coming
    #   months.
    # TODO: Remove when Linter Base is integrated into Atom.
    atom.notifications.addError(
      'Linter package not found.',
      {
        detail: 'Please install the `linter` package in your Settings view'
      }
    ) unless atom.packages.getLoadedPackages 'linter'

  provideLinter: ->
    LinterProvider = require './provider'
    provider = new LinterProvider()
    return {
      name: 'swiftc'
      grammarScopes: ['source.swift']
      scope: 'file'
      lint: provider.lint
      lintsOnChange: false
    }
