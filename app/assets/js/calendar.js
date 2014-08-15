// Path display (calendar mode):

var PATH_CELL = ".path-cell";
var CALENDAR_CELL = ".calendar-cell";
var HIGHLIGHT_CLASS = "calendar-cell-highlight";

function UPDATE_TERM_URL(id) { return '/enrollments/' + id + '/term'; }

function initCalendar(){
    $(PATH_CELL).draggable({
        revert: "invalid",
        revertDuration: 400
    });

    $(CALENDAR_CELL).each(function(){
        var term = $(this).data('term');
        $(this).droppable({
            accept: PATH_CELL + "[data-offered*='" + term + "']",
            activeClass: HIGHLIGHT_CLASS,
            drop: function(e, ui){
                var elem = ui.draggable
                var year = $(this).closest('tr').data('year');
                var term = $(this).data('term');
                $.ajax({
                    url: UPDATE_TERM_URL(elem.data('enrollment')),
                    type: 'PUT',
                    data: { year: year, term: term, _csrf: window.state.csrf }
                }).done(function(data){
                    if(data.match(/future/)){
                        elem.addClass('future');
                    } else {
                        elem.removeClass('future');
                    }
                }).fail(function(){
                    // TODO handle failure?
                });

            }
        });
    });

}
