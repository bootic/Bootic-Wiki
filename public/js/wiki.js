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

/* jQuery behaviours
------------------------------------------*/
// Search results view
;(function () {
  var $template = $('<li><a class="link"><span class="title"></span><span class="desc"></span></a></li>')
  $(document).bind('search:results', function (evt, pages) {
    $('#results').html('')
    $.each(pages, function (i, page) {
      $template.clone()
        .find('.link').attr('href', page.href).end()
        .find('.title').html(page.title).end()
        .find('.desc').html(page.description).end()
        .appendTo('#results')
    })
  })
  
  var current_idx = -1;
  function arrow (how_much) {
    var $lis = $('#results li')
    current_idx = current_idx + how_much
    if(current_idx > $lis.length -1) current_idx = 0
    if(current_idx < 0) current_idx = $lis.length -1
    
    var $row = $lis.eq(current_idx)
    $('#results li.hover').removeClass('hover')
    $row.addClass('hover')
  }
  
  $('#search').keydown(function (e) {
    if(e.keyCode == 38) { // up
      arrow(-1)
      return false
    } else if(e.keyCode == 40) { // down
      arrow(1)
      return false
    }
  })
  
  $('#search_form').submit(function () {
    var row = $('#results li.hover')
    console.log(row)
    if(row.length > 0) document.location.href = row.find('.link').attr('href')
    return false
  })
})()