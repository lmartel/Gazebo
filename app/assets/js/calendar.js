// Path display (calendar mode):

var PATH_CELL = ".path-cell";
var CALENDAR_CELL = ".calendar-cell";
var HIGHLIGHT_CLASS = "calendar-cell-highlight";
var PAST = ".past";

function UPDATE_TERM_URL(id) { return '/enrollments/' + id + '/term'; }

function initCalendar(){
    $(PATH_CELL).draggable({
        revert: "invalid",
        revertDuration: 400,
        distance: 0,
        helper: "clone",
        appendTo: "body",
        start: function() { $(this).css({ opacity: 0.5 }); },
        stop: function() { $(this).css({ opacity: 1 }); }
    });

    $(CALENDAR_CELL).each(function(){
        var term = $(this).data('term');
        var accept = PATH_CELL;
        if(!$(this).hasClass("past")){
            accept += "[data-offered*='" + term + "']";
        }
        $(this).droppable({
            accept: accept,
            activeClass: HIGHLIGHT_CLASS,
            drop: function(e, ui){
                var elem = ui.draggable
                $(this).append(elem);
                var year = $(this).closest('tr').data('year');
                var term = $(this).data('term');
                $.ajax({
                    url: UPDATE_TERM_URL(elem.data('enrollment')),
                    type: 'PUT',
                    data: { year: year, term: term, _csrf: window.state.csrf }
                }).done(function(data){
                    elem.removeClass('past present future');
                    elem.addClass(data);
                }).fail(function(){
                    // TODO handle failure?
                });

            }
        });
    });

}
