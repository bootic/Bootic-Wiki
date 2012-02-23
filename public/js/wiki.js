/* Search using Lunr.js
USAGE: WikiSearch.search('foo', function (results) {...})
-----------------------------------------------------------------*/
var WikiSearch = (function () {
  
  var index = Lunr('pages', function () {
    this.field('title', {multiplier: 10})
    this.field('description')
    this.field('keywords', {multiplier: 5})
    this.field('headings', {multiplier: 8})
    this.ref('id')
  })
  
  var pages = {},
      loaded = false;
  
  var load = function (callback) {
    if(loaded){ callback(); return }
    
    $.getJSON('/index.json', function (json) {

      $.each(json, function (i, page) {
        // add object to local cache
        pages[page.url] = page
        // add to Lunr index
        try {
	        index.add({
	          id: page.url,
	          description: (page.description || ''),
	          title: page.title,
	          headings: page.headings.join(' '),
	          keywords: (page.keywords ? page.keywords.replace(/,/gi, '') : ''),
	        })	          
        } catch(e) {
          console.log('error', e, page)
        }
      })

      loaded = true
      callback()
    })
  }
  
  var search = function (term, callback) {
    load(function () {
      var hits = [];
      $.each(index.search(term), function (i, url) {
        hits.push(pages[url])
      })
      if(callback != undefined) callback(hits)
      $(document).trigger('search:results', [hits]);
    })
  }
  
  return {
    load: load,
    search: search
  }
})()