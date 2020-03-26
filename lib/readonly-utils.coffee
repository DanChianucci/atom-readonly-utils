# Public: Package for controling and monitoring tab settings.
class ReadOnlyToggle
  config:
    displayInStatusBar:
      type: 'boolean'
      default: true
    displayInTab:
      type: 'boolean'
      default: true
    colorizeTabs:
      type: 'boolean'
      default: true
    enableOverwrite:
      type: 'boolean'
      default: true

  dialog: null
  status: null
  subs: null

  # Public: Creates status bar indicator and sets up commands for control dialog.
  activate: ->
    console.log("activate")
    # performance optimization: require only after activation
    {CompositeDisposable} = require 'atom'
    ReadOnlyToggleStatus = require './readonly-utils-status'
    ReadOnlyUtilHelper   = require './readonly-utils-helper'
    @subs = new CompositeDisposable
    @status = new ReadOnlyToggleStatus
    @subs.add atom.workspace.observeTextEditors (editor) =>
      disposable = editor.buffer?.onWillSave => ReadOnlyUtilHelper.confirmForceWrite(editor?.buffer?.file?.path)
      editor.onDidDestroy -> disposable.dispose()

      disposable = editor.buffer?.onDidSave => @status?.update()
      editor.onDidDestroy -> disposable.dispose()

  # Public: Removes status bar indicator and destroy control dialog.
  deactivate: ->
    console.log("Deactivate")
    @subs?.dispose()
    @subs = null
    @dialog?.destroy()
    @dialog = null
    @status?.destroy()
    @status = null

  # Private: Attaches status bar indicator to workspace status bar.
  consumeStatusBar: (statusBar) ->
    console.log("attach")
    @status.attach statusBar

module.exports = new ReadOnlyToggle
