
$(document).ready(function() {

  $('.move').hide();

  $('.move').click(function(){
    return false;
  });


  $('.edit-mode').toggle(
    function(){
      $('dl,hr').slideUp(400);
      $('.move').show();
      $('.wiki').hide();
      $(this).text("turn off edit mode")
      $(this).addClass("activated");
      $('#footer-wrapper').fadeIn(2000);
      return false;

  },
  function(){
    $('dl,hr').slideDown(400);
    $('.move').hide();
    $('.wiki').show();
    $(this).text("Edit sheet");
    $(this).removeClass("activated");
    $('#footer-wrapper').hide();
    return false;
  }
  );

  $('dd').hide();
   $('dt').click(function() {
     $(this).next('dd').toggle();
     $(this).toggleClass('active');
   });

  $(function(){

    // $('a.move').mousedown(function(){
    //    $(this).parents().find('dl').slideUp(400);
    // });
    // $('a.move').mouseup(function(){
    //    $(this).parents().find('dl').slideDown(400);
    // });

      // $('a.move').hover(
      //   function() {
      //     $(this).mousedown(function(){
      //        $(this).parents().find('dl').slideUp(400);
      //     });
      //     $(this).parents().find('dl').slideUp(400);
      //     $(this).parents().find('hr').hide(400);
      //
      //   },
      //   function() {
      //     $(this).parents().find('dl').show();
      //
      //   }
      //   );

  	$('#col1,#col2,#col3,#col4').sortable({
  		connectWith: '.col-3',
  		handle: '.move',
  		cursor: 'move',
  		placeholder: 'placeholder',
  		forcePlaceholderSize: true,
  		opacity: 0.4,
  		delay: 20,
  		start: function(event, ui) {
  		 $('dl').hide();
       $('.col-3').addClass("indent")
  	  },

  		stop: function(event, ui){
  		  $('.col-3').removeClass("indent")
  		  var cols = ['#col1','#col2','#col3','#col4'];
  		  var list = jQuery.map(cols, function(col, i){
  		    var els = $(col).sortable('toArray');
  		    var collist = jQuery.map(els, function(el, i){
  		      return el+col;
  		      $('dl').hide();
  		    });
  		    return collist;

  		  });
  		  setCookie(list);
		  }
  	})


  });

  $(function(){
    $('.move').click();
     return false;
  })

   });

    Cufon.replace('h1')('h2')('h3')('h4');
