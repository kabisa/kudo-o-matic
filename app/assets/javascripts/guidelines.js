$(document).ready(function(){
    $('.col-md-7').hide();
    $('#transaction_amount').on('keyup', function(){
        $('.guidelines_static').hide();
        $('.col-md-7').fadeIn(1000);
        console.log('test', this.value);
        $('#amount_of_kudo_clone').html(this.value);
        $.get("/kudo_guidelines?kudo_amount=" + this.value, function(data){
            console.log("getting guidelines", data);
            $(".guidelines_container").html(data);
            $('.guidelines_container').each(function() {
               // debugger
                var $this = $(this);
                for (var i = 0; i < data.length; i++) {
                    console.log("datarow", data[i][0], data[i][1])
                    data[i] = wrap_activity_in_li(data[i])
                }
                $this.html($('<ul>').html(data));
            });
        })
    });
    function wrap_activity_in_li(activity){
       return activity = '<li>' + activity[0] + '<span>' +  activity[1] + '</span>' +'</li>';

    }

    $('#transaction_amount').keyup(function(){
        if (!this.value) {
            $('.col-md-7').hide();
            $('.guidelines_static').show();
        }
    });

    // $("input").focus(function() {    // $("input").focus(function() {
    //     console.log("focus test ")
    //     $("header, .bottomouterwrapper").css({
    //         filter: "blur(5px)",
    //         transition: "100ms -webkit-filter linear"
    //     });
    //     $(".col-md-5").css({
    //
    //     });
    //
    //     $(".topinnerwrapper").css({height:"400px;"});
    //
    //     $("input").focusout(function() {
    //         console.log("focus out test")
    //        // $("header, .bottomouterwrapper").end()
    //             cancelBlur();
    //         });
    //     });
    //
    // $(window).scroll(function() {
    //     if ($(this).scrollTop()>10)
    //     {
    //         cancelBlur();
    //     }
    // });
    //
    // function focusOut(){
    // }
    //
    // function cancelBlur() {
    //     $("header, .bottomouterwrapper").css({
    //         filter: "",
    //         transition: "100ms -webkit-filter linear"
    //     });
    // }
    //     console.log("focus test ")
    //     $("header, .bottomouterwrapper").css({
    //         filter: "blur(5px)",
    //         transition: "100ms -webkit-filter linear"
    //     });
    //     $(".col-md-5").css({
    //
    //     });
    //
    //     $(".topinnerwrapper").css({height:"400px;"});
    //
    //     $("input").focusout(function() {
    //         console.log("focus out test")
    //        // $("header, .bottomouterwrapper").end()
    //             cancelBlur();
    //         });
    //     });
    //
    // $(window).scroll(function() {
    //     if ($(this).scrollTop()>10)
    //     {
    //         cancelBlur();
    //     }
    // });
    //
    // function focusOut(){
    // }
    //
    // function cancelBlur() {
    //     $("header, .bottomouterwrapper").css({
    //         filter: "",
    //         transition: "100ms -webkit-filter linear"
    //     });
    // }
});







