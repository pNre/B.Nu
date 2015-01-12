marked = require 'marked'
moment = require 'moment'

class Archive
    @method:    'GET'
    @path:      '/r/{year}/{month?}'

    constructor: (@server) ->

    handle: (request, @reply) ->
        {year, month} = request.params

        requestedDate = new moment "#{month} #{year}", 'MMM YYYY'

        return @reply.redirect '/' if not requestedDate.isValid() or requestedDate.isAfter new moment

        articles = @server.plugins.articles.all()
        articles
            .filter (article) ->
                article.date.isSame requestedDate, 'month'
            .all()
            .then (articles) =>
                if articles.length > 0
                    @reply.view 'main', { marked: marked, articles: articles }
                else
                    @reply.redirect '/'
            .catch (error) =>
                @reply error

module.exports = Archive
