SR = {
        setup: function() {
            document.addEventListener("turbolinks:load", function() {
                $('#sourceRankingForm').css("display","block");
                $('#arrow1').click(SR.change_ranking)
                $('#arrow2').click(SR.change_ranking)
            })
        },
        change_ranking: function () {
            if($(this).is('#arrow1')){
                first=$('#ranking_first').val()
                second=$('#ranking_second').val()
                $('#ranking_first').val(second)
                $('#ranking_second').val(first)
                
            }
            else{
                first=$('#ranking_second').val()
                second=$('#ranking_third').val()
                $('#ranking_second').val(second)
                $('#ranking_third').val(first)
            };
        }
    }
    $(SR.setup);       // when document ready, run setup code