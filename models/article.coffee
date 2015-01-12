fs      = require 'fs'
promise = require 'bluebird'
marked  = require 'marked'

promise.promisifyAll fs

#   An empty Article model
class Article
    #   new (factory method)
    #   Reads the article from its file and initializes a new Article
    @new: (id, file, date) ->
        fs.readFileAsync file
            .then (data) ->
                #   split the content by line
                contents = data.toString().split(require('os').EOL)

                #   new empty Article
                article = new Article

                #   the first line in the file is the title
                article.title ?= contents.shift().substr(1)
                #   the rest goes as content
                article.contents ?= contents.join(require('os').EOL)

                #   date and id are passed as parameters
                article.date ?= date
                article.id ?= id

                text = marked article.contents

                return article

module.exports = Article
