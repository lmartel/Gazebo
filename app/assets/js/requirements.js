// Path display (requirement mode):

var PATH_WRAPPER = '.path-wrapper';
var REQUIREMENT_ROW = '.path-row';

var FILLED_REQUIREMENT = '.path-cell.filled';
var UNFILLED_REQUIREMENT = '.path-cell.unfilled';
var CAN_FILL = UNFILLED_REQUIREMENT + '.fillable';
var UNASSIGNED_CELLS_CLASS = 'extra-cells';
var UNASSIGNED_CELLS = '.' + UNASSIGNED_CELLS_CLASS;

var CLOSE_BUTTON_CLASS = 'delete-enrollment';
var CLOSE_BUTTON = 'button.' + CLOSE_BUTTON_CLASS;

var REQUIREMENTS_MODAL = "#requirementsModal"
var REQUIREMENTS_MODAL_FADE = REQUIREMENTS_MODAL + ".modal.fade.in";
var REQUIREMENTS_DIALOG = REQUIREMENTS_MODAL_FADE + " .modal-dialog";
var MODAL_TITLE = ".modal-title";
var MODAL_BODY = ".modal-body";

var AUTOLAYOUT_BUTTON = "button.autolayout";

var CELL_UNASSIGNMENT_ANIMATION_SPEED = 400;

function UPDATE_ENROLLMENT_URL(id) { return '/enrollments/' + id; }
function REQUIREMENT_URL(id) { return '/requirements.json/' + id; }

window.state = window.state || {}
state.requirements = {
    original: null,
    replacement: null,
    isSnappingTo: null,
    clone: 1 // unique indentifier for ids of cloned cells
}

function fillableCells(draggedCell){
    var reqs = draggedCell.data('can-fill');
    var fillable = $(REQUIREMENT_ROW).filter(function(){
        return reqs.indexOf($(this).data('requirement')) !== -1;
    }).toArray().reduce(function(rest, next){
        return rest.concat($(next).find(UNFILLED_REQUIREMENT).first().toArray()); // this is a flat_map from rows to their first fillable cell
    }, []);
    return $(fillable);
}

function initDraggable(){
    $(FILLED_REQUIREMENT).draggable({
        snap: CAN_FILL,
        snapMode: 'corner',
        // snapTolerance: 20,
        zIndex: 5,
        revert: false,
        cancel: UNFILLED_REQUIREMENT + ',' + CLOSE_BUTTON,
        // refreshPositions: true,
        stop: function (event, ui) {
            var snapTo = ui.helper.data("ui-draggable").snapElements.filter(function(elem){
                return elem.snapping;
            });
            if(snapTo.length > 0){
                state.requirements.isSnappingTo = $(snapTo[0].item);
            }
        }
    });
}

function handleCellDragStart(elem){
    elem.find(CLOSE_BUTTON).remove();
    var draggingUnassignedCell = elem.closest('ul').hasClass(UNASSIGNED_CELLS_CLASS);

    if(!draggingUnassignedCell){ // create no placeholder if currently unassigned
        var replacement = elem.clone();
        replacement.removeClass('filled ui-draggable').addClass('unfilled fillable').attr('data-content', elem.text()).text('').css('margin-left', -elem.outerWidth() + 'px').attr('data-can-fill', '');
        elem.after(replacement);
        state.requirements.replacement = replacement;
    }
    fillableCells(elem).addClass('fillable').attr('data-content', elem.text());
    $(UNFILLED_REQUIREMENT).addClass('drag-is-active');

    state.requirements.original = elem;
}

function resetCellToEmpty(elem){
    elem.css({top: 0, left: 0}).removeClass('filled ui-draggable').addClass('unfilled').text('').attr('data-content', 'TODO').attr('data-enrollment', '');
}

function deleteCell(elem){
    $.ajax({
        url: UPDATE_ENROLLMENT_URL(elem.data('enrollment')),
        type: 'DELETE',
        data: { _csrf: window.state.csrf }
    }).done(function(data){
        elem.closest('li').remove();
    }).fail(function(){
        // TODO handle failure?
    });
}

function handleCellDragEnd(elem){
    var replacement = state.requirements.replacement;
    var isSnapping = state.requirements.isSnappingTo;

    var draggingUnassignedCell = elem.closest('ul').hasClass(UNASSIGNED_CELLS_CLASS);

    if(isSnapping){ // We remove the replacement, put the original element back, and change the text of both elements to complete the swap
        if(replacement) replacement.remove();
        if(isSnapping.attr('id') !== elem.attr('id')){
            isSnapping.removeClass('fillable unfilled').addClass('filled ui-draggable').text(elem.text()).attr('data-can-fill', '[' + elem.data('can-fill') + ']').attr('data-enrollment', elem.data('enrollment'));
            elem.css({'top': '', 'left': ''});
            if(draggingUnassignedCell){
                elem.closest('li').remove();
            } else {
                resetCellToEmpty(elem);
            }
        }

    } else {
        if(replacement) replacement.remove();

        elem.append('<button type="button" class="close delete-enrollment"></button>');
        if(draggingUnassignedCell){
            elem.animate({top: 0, left: 0}, CELL_UNASSIGNMENT_ANIMATION_SPEED);
        } else {
            var cloneId = 'clone' + state.requirements.clone++;
            elem.clone().attr('id', cloneId).css({top: 0, left: 0}).appendTo(UNASSIGNED_CELLS + ':visible'); // TODO: properly scope all selectors within path-wrappers via id
            var clone = $('#' + cloneId);
            var start = elem.position();
            var dest = clone.position();

            resetCellToEmpty(elem);
            clone.css({
                position: 'absolute',
                top: start.top, 
                left: start.left
            }).animate({
                top: dest.top,
                left: dest.left
            }, CELL_UNASSIGNMENT_ANIMATION_SPEED, function(){
                clone.css({
                    position: 'relative',
                    top: 0,
                    left: 0
                }).wrap('<li style="margin-right: 5px;"></li>'); // Margin compensates for missing 'implicit margin' list item thing
            });

        }
    }

    $(CAN_FILL).removeClass('fillable').attr('data-content', 'TODO');
    $(UNFILLED_REQUIREMENT).removeClass('drag-is-active');

    if(replacement) replacement.css('margin-left', '0');

    var enrollment = (replacement || elem).data('enrollment');
    var moved = false;
    var movedTo;
    if(isSnapping){
        movedTo = isSnapping.closest(REQUIREMENT_ROW).data('requirement');
        moved = !!movedTo;

    } else {
        movedTo = null;
        moved = !draggingUnassignedCell;
    }

    if(moved){
        $.ajax({
            url: UPDATE_ENROLLMENT_URL(enrollment),
            type: 'PUT',
            data: { requirement: movedTo, _csrf: window.state.csrf }
        }).fail(function(){
            // TODO handle failure?
        });
    }

    initDraggable();
    state.requirements.original = null;
    state.requirements.replacement = null;
    state.requirements.isSnappingTo = null;
}

function initPathDisplay(){
    // Drag has started
    $(document).on('mousedown', FILLED_REQUIREMENT + ':not(' + CLOSE_BUTTON + ')', function(event){
        if(event.which !== 1) return; // ignore non-left clicks
        if($(event.target).hasClass(CLOSE_BUTTON_CLASS)) return; // forbid dragging by close button
        handleCellDragStart($(this));
    });

    // Drag has ended
    $(document).on('mouseup', function(event){
        if(event.which !== 1) return; // ignore non-left clicks

        var elem = state.requirements.original;
        if(!elem) return; // ignore mouseups when not dragging an element

        setTimeout(function(){ // Ensure this happens AFTER the stop() callback in $.draggable is called
            handleCellDragEnd(elem);
        }, 1);
    });

    // Other listeners

    // Close buttons
    $(document).on('click', CLOSE_BUTTON, function(event){
        deleteCell($(this).closest(FILLED_REQUIREMENT));
    });

    // Open requirement description modals
    $(document).on('click', UNFILLED_REQUIREMENT, function(event){
        var row = $(this).closest(REQUIREMENT_ROW);
        var title = row.closest('dd').prev('dt').text()
        var modal = $(REQUIREMENTS_MODAL);
        var body = modal.find(MODAL_BODY);

        modal.find(MODAL_TITLE).text(title);
        body.text('Loading requirement details...');
        modal.modal();

        $.get(REQUIREMENT_URL(row.data('requirement'))).done(function(data){
            body.text('');
            body.wrapInner('<ul class="requirements-list"></ul>');
            var list = body.find(".requirements-list");
            var courses = JSON.parse(data);
            for(var i = 0; i < courses.length; i++){
                $('<li></li>').text(courses[i]).appendTo(list);
            }
        }).fail(function(){
            // TODO handle failure?
        });
    });

    // Close modal by clicking outside the dialog
    $(document).on('click', REQUIREMENTS_MODAL_FADE, function(event){
        if($(e.target).hasClass(REQUIREMENTS_DIALOG)) return;
        $(REQUIREMENTS_MODAL).modal('hide');
    });

    initDraggable();
    
}

initPathDisplay();