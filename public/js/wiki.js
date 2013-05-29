/* Search using Lunr.js
USAGE: WikiSearch.search('foo', function (results) {...})
-----------------------------------------------------------------*/
(function ($) {
  var Search = function (url, $container) {
    if(!url.match(document.location.host) && !url.match(/\?callback=/)) {// remote host. Add jsonp callback
      url += '?callback=?'
    }

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
      
      $.getJSON(url, function (json) {

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

    this.search = function (term, callback) {
      load(function () {
        var hits = [];
        $.each(index.search(term), function (i, url) {
          hits.push(pages[url])
        })
        if(callback != undefined) callback(hits)
        $container.trigger('search:results', [hits]);
      })
    }
  }

  $.fn.booticDocSearch = function (url) {
    var engine = new Search(url, $(this))
    return $(this).bind('search:results', function () {
      if($(this).val().trim() == '') $(this).trigger('search:clear')
    }).keyup(function (e) {
      if(e.keyCode != 38 && e.keyCode != 40) engine.search($(this).val())
      return false;
    })
  }
})(jQuery);



/* jQuery behaviours
------------------------------------------*/
// Search results view
;(function () {

  var $template = $('<li><a class="result_link"><span class="result_title"></span></a><p class="result_desc"></p></li>')
  $('#search').bind('search:results', function (evt, pages) {
    $('#results').html('')
    $('#content_wrapper').hide()
    $.each(pages, function (i, page) {
      $template.clone()
        .find('.result_link').attr('href', page.href).end()
        .find('.result_title').html(page.title).end()
        .find('.result_desc').html(page.description).end()
        .appendTo('#results')
    })
    $('#search_box .term').text($('#search').val())
    $('#search_box').show()
  }).bind('search:clear', function () {
    $('#results').html('')
    $('#search_box').hide()
    $('#content_wrapper').show()
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
    if(row.length > 0) document.location.href = row.find('.result_link').attr('href')
    return false
  })

  // Sticky search bar
  /*
  $('#search_form').sticky({ topSpacing:0 }).bind('sticky:on', function () {
    $('body').addClass('sticky_search')
  }).bind('sticky:off', function () {
    $('body').removeClass('sticky_search')
  })
  */

  // Lunr search
  $('#search').booticDocSearch('/index.json')

  // Fancybox
  $(".js_fancy_box_vimeo").live('click', function() {

    $.fancybox({
      'padding'   : 0,
      'autoScale'   : false,
      'transitionIn'  : 'none',
      'transitionOut' : 'none',
      'title'     : this.title,
      'width'     : 701,
      'height'    : 438,
      'href'      : this.href.replace(new RegExp("([0-9])","i"),'moogaloop.swf?clip_id=$1'),
      'type'      : 'swf'
    });
    return false;

  });

  $('a[rel=fancybox]').fancybox();


})()
