// Path display (requirement mode):

var FILLED_REQUIREMENT = '.path-cell.filled';
var UNFILLED_REQUIREMENT = '.path-cell.unfilled';
var CAN_FILL = UNFILLED_REQUIREMENT + '.fillable';
var REQUIREMENT_ROW = '.path-row';
var UNASSIGNED_CELLS_CLASS = 'extra-cells'
var UNASSIGNED_CELLS = '.' + UNASSIGNED_CELLS_CLASS;
var CELL_UNASSIGNMENT_ANIMATION_SPEED = 400;

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
        cancel: UNFILLED_REQUIREMENT,
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

function handleCellDragEnd(elem){
    var replacement = state.requirements.replacement;
    var isSnapping = state.requirements.isSnappingTo;

    var draggingUnassignedCell = elem.closest('ul').hasClass(UNASSIGNED_CELLS_CLASS);

    if(isSnapping){ // We remove the replacement, put the original element back, and change the text of both elements to complete the swap
        if(replacement) replacement.remove();
        if(isSnapping.attr('id') !== elem.attr('id')){
            isSnapping.removeClass('fillable unfilled').addClass('filled ui-draggable').text(elem.text()).attr('data-can-fill', '[' + elem.data('can-fill') + ']');
            elem.css({'top': '', 'left': ''});
            if(draggingUnassignedCell){
                elem.closest('li').remove();
            } else {
                elem.css({'top': '', 'left': ''}).removeClass('filled ui-draggable').addClass('unfilled').text('').attr('data-content', 'TODO');
            }
        }

    } else {
        if(replacement) replacement.remove();
        
        if(draggingUnassignedCell){
            elem.animate({top: 0, left: 0}, CELL_UNASSIGNMENT_ANIMATION_SPEED);
        } else {
            var cloneId = 'clone' + state.requirements.clone++;
            elem.clone().attr('id', cloneId).css({top: 0, left: 0}).appendTo(UNASSIGNED_CELLS + ':visible'); // TODO: properly scope all selectors within path-wrappers via id
            var clone = $('#' + cloneId);
            var start = elem.position();
            var dest = clone.position();

            elem.css({top: 0, left: 0}).removeClass('filled ui-draggable').addClass('unfilled').text('').attr('data-content', 'TODO');
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

    initDraggable();
    state.requirements.original = null;
    state.requirements.replacement = null;
    state.requirements.isSnappingTo = null;

    // $.post('/update_path')
}

function initPathDisplay(){
    $(document).on('mousedown', FILLED_REQUIREMENT, function(event){
        if(event.which !== 1) return; // ignore non-left clicks
        handleCellDragStart($(this));

    });

    $(document).on('mouseup', function(event){
        if(event.which !== 1) return; // ignore non-left clicks

        var elem = state.requirements.original;
        if(!elem) return; // ignore mouseups when not dragging an element

        setTimeout(function(){ // Ensure this happens AFTER the stop() callback in $.draggable is called
            handleCellDragEnd(elem);
        }, 1);
    });
    initDraggable();
    
}

initPathDisplay();