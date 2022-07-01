$('ul li').on('click', function() {  
    $('ul li.active').removeClass('active');
    $(this).addClass('active');    
});
