# Status bar indicator showing current tab settings.
module.exports =

class ReadOnlyUtilHelper
  @isReadOnly: (filepath) ->
    fs= require 'fs'
    modeToPermissions = require 'mode-to-permissions'
    stats = fs.statSync(filepath)

    modes = modeToPermissions(stats.mode)
    ro = !modes.write.owner
    return ro

  @makeWritable: (filepath) ->
    chmod = require 'chmod'
    chmod(filepath, {write: true})


  @makeReadonly: (filepath) ->
    chmod = require 'chmod'
    chmod(filepath, {write: false})

  @toggleWriteable: (filepath) ->
    if @isReadOnly(filepath)
      @makeWritable(filepath)
    else
      @makeReadonly(filepath)

  @confirmForceWrite: (filepath) ->
    enable = atom.config.get "readonly-utils.enableOverwrite"
    if enable && @isReadOnly(filepath)
      if confirm("Would you like to overwrite the write protected file: #{filepath}?")
        @makeWritable(filepath)
