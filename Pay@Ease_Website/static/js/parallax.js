(function() {

	function check() {
		var current_scroll = $(this).scrollTop();

	    oVal = ($(window).scrollTop() / 3);
	    console.log(oVal, ' -0 ' + (10 + oVal) + '%')
		$(".parallax").css({
	        'background-position': ' -0 ' + (10 + oVal) + '%',
	    });
	}
	

    $(window).on('scroll', check);


})();
     