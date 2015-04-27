#   Article controller
class Article
    @method:    'GET'
    @path:      '/a/{id}/{title?}'

    #   The constructor is only used to get the server object
    constructor: (@server) ->

    handle: (request, @reply) =>
        {id} = request.params

        #   Using the articles plugin, get an article with the given id
        article = @server.plugins.articles.get id
            .then (article) =>
                @reply.view 'article', { article: article }
            .catch (error) =>
                @reply error

module.exports = Article
