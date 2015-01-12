# B.Nu
Super-small Hapi.js powered and database-less content manager written in CoffeeScript (developed for personal use).

# Details
## Articles
### Naming
Articles are plain text files (with support for the markdown markup) stored in the `articles/` folder and having a very simple naming format:

```
articles/[YYYY]/[MMM]/[DD]-{title}
``` 

`YYYY`, `MMM`, `DD` are respectively: year, month and day of publication as defined by the ISO 8601 standard.

### Contents
The first line of each article is rendered as the article title in the article template while the rest of the file as its body.

### Caching
When the server is started all the articles are parsed and stored in memory. These are reloaded in 2 cases:

* The `articles/` fs tree changes
* The cached entry expires (this happens each hour)