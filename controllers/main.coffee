marked = require 'marked'

class Main
    @method:    'GET'
    @path:      '/'

    constructor: (@server) ->

    handle: (request, @reply) =>
        articles = @server.plugins.articles.all()
        article = articles.all()
            .then (articles) =>
                articles.sort (a, b) -> (a.date - b.date) < 0
                @reply.view 'main', { articles: articles }
            .catch (error) =>
                @reply error

        return

module.exports = Main
