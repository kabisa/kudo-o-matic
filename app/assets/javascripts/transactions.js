$(document).ready(function() {
    $('.input-amount').focus(function (e) {
        e.preventDefault()
    })

    $('.menu-option.filter').click(function () {
        $('.hidden-menu.filter').slideToggle("slow");
    });

    // Error container hide
    $('.close-message').click(function () {
        $('.message-container').addClass('hide-message');
    });

    // Dropdown meny toggle show/hide
    $('.general-menu').click(function () {
        $('.general.dropdown-content').slideToggle(250);
    });

    // Menu icons toggle
    $('.general-menu').click(function () {
        $(this).find('i').toggleClass('fa-bars fa-chevron-up')
    });

    // Characters left in activity input field
    var textMax = $('.character-count').attr('maxLength');
    $('.counter').html(textMax);

    $('.character-count').keyup(function() {
        $('.attachment-tooltip').css({ left: '2.5rem' });
        $('.counter').addClass('show-counter');
        var textLength = $('.character-count').val().length;
        var textRemaining = textMax - textLength;

        $('.counter').html(textRemaining);
    });

    // Submit on enter in transaction textarea
    $('.character-count').keypress(function(event) {
        if (event.keyCode == 13 || event.which == 13) {
            $('#send-kudos-button').click();
            event.preventDefault();
        }
    });

    $('.input-receiver, .input-amount').keydown(function(event){
        if(event.keyCode == 13) {
            event.preventDefault();
            return false;
        }
    });


});
