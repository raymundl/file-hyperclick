# coffeelint: disable=max_line_length
{CompositeDisposable} = require 'atom'
mfs = require 'match-files'
path = require 'path'

module.exports = FileHyperclick =
  subscriptions: null
  config:
    directories:
      description: "directories under project paths that may contain the file",
      type: 'array',
      default: ['/src','/views']
    extensions:
      description: "extension names of the file",
      type: 'array',
      default: ['.coffee','.jade']

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    return

  getProvider: ->
    providerName: 'file-hyperclick',
    getSuggestionForWord: (editor, text, range) ->
      range: range, callback: ->
        dirs = do atom.project.getPaths
        subDirs = atom.config.get 'file-hyperclick.directories'
        exts = atom.config.get 'file-hyperclick.extensions'
        targets = ("#{text}#{ext}" for ext in exts)
        dirs.forEach (dir) ->
          subDirs.forEach (subDir) ->
            sdir = path.join dir, subDir
            options =
              fileFilters: [
                (path) ->
                  for file in targets
                    if path.slice(-file.length) is file
                      return true
                  false
              ]
            mfs.find sdir, options, (err, files) ->
              if not err
                files?.forEach (file) ->
                  atom.workspace.open file
                  return
              return
            return
          return
        return

  deactivate: ->
    @subscriptions.dispose()
    return
