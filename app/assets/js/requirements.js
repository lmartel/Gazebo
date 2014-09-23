var PATH_WRAPPER = '.path-wrapper';
var REQUIREMENT_ROW = '.path-row';
var REQUIREMENT_NAME_CLASS = "requirement-name"
var REQUIREMENT_NAME = "." + REQUIREMENT_NAME_CLASS

var FILLED_REQUIREMENT = '.path-cell.filled';
var UNFILLED_REQUIREMENT = '.path-cell.unfilled';
var FILLABLE = 'fillable';
var CAN_FILL = UNFILLED_REQUIREMENT + '.' + FILLABLE;
var UNASSIGNED_BOX = '.extra-cells-wrapper'

var CLOSE_BUTTON_CLASS = 'delete-enrollment';
var CLOSE_BUTTON = 'button.' + CLOSE_BUTTON_CLASS;

var REQUIREMENTS_MODAL = "#requirementsModal"
var REQUIREMENTS_MODAL_FADE = REQUIREMENTS_MODAL + ".modal.fade.in";
var REQUIREMENTS_DIALOG = REQUIREMENTS_MODAL_FADE + " .modal-dialog";
var MODAL_TITLE = ".modal-title";
var MODAL_BODY = ".modal-body";

var UPDATE_ENROLLMENT_URL = function(id) { return '/enrollments/' + id + '/requirement'; }
var DELETE_ENROLLMENT_URL = function(id) { return '/enrollments/' + id; }
var REQUIREMENT_URL = function(id) { return '/requirements.json/' + id; }

window.state = window.state || {}
state.requirements = {
    activeCell: null
}

function initRequirements(){
    $(document).on('mousedown', FILLED_REQUIREMENT, function(event){
        if(event.which !== 1) return; // ignore non-left clicks
        if($(event.target).hasClass(CLOSE_BUTTON_CLASS)) return; // forbid dragging by close button
        state.activeCell = this;
        initRequirementsDraggable();
    });

    // Other listeners

    // Close buttons
    $(document).on('click', CLOSE_BUTTON, function(event){
        deleteCell($(this).closest(FILLED_REQUIREMENT));
    });

    // Open requirement description modals
    $(document).on('click', UNFILLED_REQUIREMENT + "," + REQUIREMENT_NAME, function(event){
        var row;
        if($(event.target).hasClass(REQUIREMENT_NAME_CLASS)){
            title = $(this).text();
            row = $(this).next('dd').find(REQUIREMENT_ROW);
        } else {
            row = $(this).closest(REQUIREMENT_ROW);
        }
        var title = row.closest('dd').prev('dt').text()
        var modal = $(REQUIREMENTS_MODAL);
        var body = modal.find(MODAL_BODY);

        modal.find(MODAL_TITLE).text(title);
        body.text('Loading requirement details...');
        modal.modal({
            show: 1,
            hide: 1
        });

        $.get(REQUIREMENT_URL(row.data('requirement'))).done(function(data){
            body.text('');
            body.wrapInner('<ul class="requirements-list"></ul>');
            var list = body.find(".requirements-list");
            var courses = JSON.parse(data);
            for(var i = 0; i < courses.length; i++){
                $('<li></li>').html(courses[i]).appendTo(list);
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


    initRequirementsDraggable();
}

function initRequirementsDraggable(){
    $(FILLED_REQUIREMENT).draggable({
        revert: 'invalid',
        reverDuration: 400,
        snap: computeValidDroppables(state.activeCell),
        snapMode: 'inner',
        start: function() {
            $(UNFILLED_REQUIREMENT + ', ' + UNASSIGNED_BOX).addClass('drag-is-active');
            initRequirementsDroppable(state.activeCell);
            $(CAN_FILL).attr('data-content', $(this).text());

            $(this).find('button.close').hide()
        },
        stop: requirementsdragStop
    });

}

function computeValidDroppables(draggedCell){
    // $(CAN_FILL).removeClass(FILLABLE);
    var fillableRows = $(draggedCell).data('can-fill') || [];
    var fillableCells = $(REQUIREMENT_ROW).filter(function() {
        return fillableRows.indexOf($(this).data('requirement')) !== -1;
    }).toArray().reduce(function(rest, next){
        return rest.concat($(next).find(UNFILLED_REQUIREMENT).first().toArray()); // this is a flat_map from rows to their first fillable cell
    }, []);
    if(draggedCell) $(fillableCells).addClass(FILLABLE).width(draggedCell.offsetWidth);
    return '.' + FILLABLE;

}

function requirementsdragStop(){
    $(UNFILLED_REQUIREMENT + ', ' + UNASSIGNED_BOX).removeClass('drag-is-active');
    $(CAN_FILL).removeClass(FILLABLE).attr('data-content', 'TODO');
    $(this).find('button.close').show();
    state.activeCell = null;
    initRequirementsDraggable();
}

function initRequirementsDroppable(draggedCell){
    $(CAN_FILL).droppable({
        drop: function(e, ui){
            var dest = $(this).clone();
            var src = ui.draggable.css('position', 'initial').css('left', 0).css('top', 0);
            var movedTo = $(this).closest(REQUIREMENT_ROW).data('requirement');

            $(this).replaceWith(src.clone());
            if(src.closest(REQUIREMENT_ROW).length) {
                ui.draggable.replaceWith(dest)
                src.replaceWith('<span id=' + src.attr('id') + ' class="path-cell unfilled" data-content="TODO"></span>');
            } else {
                src.closest('li').remove()
            }

            requirementsdragStop();

            var enrollment = $(src).data('enrollment');
            $.ajax({
                url: UPDATE_ENROLLMENT_URL(enrollment),
                type: 'PUT',
                data: { requirement: movedTo, _csrf: window.state.csrf }
            }).fail(function(){
                // TODO handle failure?
            });
        }
    });

    $(UNASSIGNED_BOX).droppable({
        drop: function(e, ui){
            var src = ui.draggable.css('position', 'initial').css('left', 0).css('top', 0);
            var cpy = src.clone()
            cpy.not(':has(button)')
               .append('<button type="button" class="close delete-enrollment"></button>');

            cpy.appendTo($(this).find('ul')).wrap('<li></li>');
            if(src.closest(REQUIREMENT_ROW).length) {
                src.replaceWith('<span id=' + src.attr('id') + ' class="path-cell unfilled" data-content="TODO"></span>');
            } else {
                src.closest('li').remove()
            }
            requirementsdragStop();

            var enrollment = $(src).data('enrollment');
            $.ajax({
                url: UPDATE_ENROLLMENT_URL(enrollment),
                type: 'PUT',
                data: { requirement: null, _csrf: window.state.csrf }
            }).fail(function(){
                // TODO handle failure?
            });

        }
    });

}

function deleteCell(elem){
    $.ajax({
        url: DELETE_ENROLLMENT_URL(elem.data('enrollment')),
        type: 'DELETE',
        data: { _csrf: window.state.csrf }
    }).done(function(data){
        elem.closest('li').remove();
    }).fail(function(){
        // TODO handle failure?
    });
}
