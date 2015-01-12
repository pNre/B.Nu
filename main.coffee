hapi        = require 'hapi'
marked      = require 'marked'
moment      = require 'moment'
hljs        = require 'highlight.js'

global.AppDir ?= __dirname

controllers = require __dirname + '/controllers'

#   New server
#   - TPL engine -> jade
server = new hapi.Server 3000, {
    views: {
        engines:    { jade: require 'jade' },
        path:       __dirname + '/views',
        compileOptions: {
            pretty: true,
        }
    }
}

#   Configure code highlighting
renderer = new marked.Renderer
renderer.code = (code, lang, escaped) ->
    if lang
        try
            code = hljs.highlight(lang, code).value
        catch error
            return '<pre class="code">' + code + '</pre>'
    else
        code = hljs.highlightAuto(code).value

    result = '<pre class="code hljs'

    if lang?
        result += ' ' + @options.langPrefix + lang + '"'
    else
        result += '"'

    result += '>' + code + '</pre>'
    result

marked.setOptions {
    renderer: renderer
}

#   Include a marked object in each view
server.ext 'onPreResponse', (request, reply) ->
    return reply() if request.response.variety  isnt 'view'

    context = request.response.source.context
    context.marked ?= marked
    context.moment ?= moment

    reply()

#   Route for static files
#   Serve everything in ./static as is
server.route {
    method:     'GET',
    path:       '/{file*}',
    handler:    {
        directory: {
            path: __dirname + '/static',
            listing: false
        }
    }
}

#   Setup a route for each included controller
for own name of controllers
    #   The used method and path are static properties
    {method, path}  = controllers[name]
    #   Controller instance
    controller      = new controllers[name] server

    server.route {
        method:     method,
        path:       path,
        handler:    (request, reply) ->
            controller.handle request, reply
    }

#   This cache is used to store the parsed articles
server.mainCache ?= server.cache 'main', { expiresIn: 3600 * 24 }

#   Plugins registration
plugins = [ {
    plugin: require __dirname + '/plugins/articles',
} ]

server.pack.register plugins, () ->
    server.start () -> console.log "Alive at: " + server.info.uri
