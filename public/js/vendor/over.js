////////////////////////////////////
// Over2 JS
// (c) Tomas Pollak
// MIT License.
//
// Usage:
// <div class="my_modal">
//   <a class="close" href="#close" title="Close">Close</a>
//   <div><h2>Hello world!</h2></div>
// </div>
//
// $('.my_modal').over().on('hidden', function() {
//   // do something
// });
//
// Options:
//   close_with: '.some-element'
//   escape: true|false
//
////////////////////////////////////

;(function($) {

  function render(body, css) {
    var css_class = css ? css : '';

    var html = '<aside class="over ' + css_class + '"><div>';
    html    += '<a class="close" href="#close" title="Close">Close</a>';
    // if (header) html += '<div class="modal-header">' + title + '</div>';
    if (html) html += body;
    html    += '</div></aside>';

    var popup = $(html);
    popup.appendTo('body').over();
    popup.on('hidden', function() {
      popup.remove();
    });
  }

  function open_iframe(src, title, css) {
    var html  = '<iframe style="background: #fff; width: 100%; height: 435px" src="' + src + '"></iframe>';
    if (title) html = title + html;
    return render(html, css);
  }

  $.over = function(el, opts) {
    if (el[0] || typeof el == 'string')
      return $(el).over(opts);

    if (el.iframe)
      open_iframe(el.iframe, el.title, el.css);
    else if (el.html)
      render(el.html, el.css);
  }

  $.fn.over = function(options) {

    var options       = options || {};
    var close_element = options.close_with || 'a[data-dismiss=modal]';
    var close_on_esc  = options.escape     || true;

    var el = this;
    var inner = el[0].children[0];

    function centerElement() {
      var el = $(this);
      var new_css = {};

      if (el.height() > window.innerHeight) { // over the top

        new_css['margin-top'] = 0
        new_css['top'] = 0

      } else {

      var left_pad    = parseInt(el.css('padding-left')),
          top_pad     = parseInt(el.css('padding-top')),
          margin_left = ((el.width()/2)+left_pad) * -1,
          margin_top  = ((el.height()/2)+top_pad) * -1;

        new_css['margin-top'] = margin_top;
        new_css['top'] = '50%'
      }

      el.css(new_css);
    }

    function activate() {
      $('body').addClass('noscroll');
      centerElement.call(inner)

      $(el)
        .addClass('active')
        .on('hide', function() {
          hide(el);
        })
        .find(close_element).on('click', function(e) {
          e.preventDefault();
          hide(el);
       });

      $(window).on('resize', centerElement.bind(inner))
    }

    function hide() {
      $(el).removeClass('active');
      $('body').removeClass('noscroll');

      $(window).off('resize', centerElement.bind(inner))
      $(el).trigger('hidden');
    };

    function grab_esc() {
      // close modal with ESC key. only works on modals opened via JS
      $(document).keyup(function(e) {
        if (e && e.keyCode == 27) hide(el);
      })
    };

    activate();

    if (close_on_esc)
      grab_esc();

    return this;
  };

})(window.jQuery);