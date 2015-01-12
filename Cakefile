fs      = require 'fs'
{exec}  = require 'child_process'
util    = require 'util'
path    = require 'path'
findit  = require 'findit'

mainFile = 'main.coffee'

serverProcess = null

task 'watch', 'Watch files and reload coffee', ->
    invoke 'run'
    util.log "Watching for changes"

    coffeeFiles = []

    #   Search for coffee files
    finder = findit '.'
    finder.on 'directory', (dir, stat, stop) ->
        name = path.basename(dir)
        return stop() if name is 'node_modules' or /(^|.\/)\.+[^\/\.]/g.test(name)

    finder.on 'file', (file, stat) ->
        return if path.extname(file) isnt '.coffee'
        coffeeFiles.push file

    #   Watch files
    finder.on 'end', () ->
        for file in coffeeFiles then do (file) ->
            fs.watchFile "#{file}", (curr, prev) ->
                if +curr.mtime isnt +prev.mtime
                    util.log "Saw change in #{file}"
                    invoke 'run'

task 'run', "Runs #{mainFile}", ->
    try
        process.kill serverProcess.pid if serverProcess?
    catch error
        util.log 'The server wasn\'t running'

    serverProcess = exec "coffee #{mainFile}", (err, stdout, stderr) ->
        if stderr? and err
            util.log err
        else
            util.log "Reloaded"

    serverProcess.stderr.pipe process.stderr
    serverProcess.stdout.pipe process.stdout
