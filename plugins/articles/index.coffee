fs          = require 'fs'
crypto      = require 'crypto'
findit      = require 'findit'
promise     = require 'bluebird'
moment      = require 'moment'

{Article}   = require '../../models'

#   Simple cache
class Cache
    storage: {}

    constructor: (@ttl = 24) ->

    #   Adds an object to the cache given:
    #   @key: Key to retrieve the object
    #   @loader: Function used to make a new object. Must return a Promise.
    set: (key, loader) =>
        loader().then (data) =>
            @storage[key] = {
                ts: new moment
                ttl: @ttl
                value: data
                loader: loader
            }

    #   Gets an object from the cache and returns a promise
    get: (key) ->
        new promise (resolve, reject) =>
            if key of @storage
                record = @storage[key]

                expiry = record.ts.add record.ttl, 'seconds'

                if expiry.isBefore new moment
                    console.log 'Expired'
                    resolve record.loader()
                else
                    resolve record.value
            else
                reject 'Not found'

#   Yep, this is the cache
cache = new Cache

articles = (cache) ->
    promise.resolve Object.keys(cache.storage).map (key) -> cache.get key

exports.register = (plugin, options, next) ->

    #   Articles methods
    plugin.expose 'all', () -> articles cache
    plugin.expose 'get', (id) -> cache.get id

    #   This plugin loads all the articles
    finder = findit AppDir + '/articles'

    finder.on 'file', (file) ->
        #   discard hidden files
        return if /(^|.\/)\.+[^\/\.]/g.test file

        #   check for a valid path: year/month/day-title
        [year, month, day] = file.match(/(\d{4})\/(\w{3})\/(\d{1,2})/)[1..3]

        #   is the date valid
        date = new moment day + ' ' + month + ' ' + year, 'DD MMM YYYY', true

        #   nope, next file
        return if !date.isValid()

        #   the id is the sha1 of the filename (to keep it persistent across sessions)
        shasum = crypto.createHash 'sha1'
        shasum.update file

        id = shasum.digest('hex').substring 0, 10

        #   generates the article record if needed
        record = cache.get id

        record.catch (error) ->
            cache.set id, () -> Article.new id, file, date

    next()

exports.register.attributes = {
    pkg: {
        name: 'articles'
        main: 'index.coffee'
    }
}
