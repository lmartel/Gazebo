var SEARCH = '#course-search';
var INPUT = '.select2-input';
var INPUT_EVENT = 'keydown.local';
var SELECT_EVENT = 'select2-selecting.local';

var DEPARTMENTS_URL = '/departments.json';
var COURSES_URL = '/courses.json?department=';
var state = {
    selectedDepartment: null,   // Stores the selected department, if any
    departments: null           // Caches fetched list of departments
    // dept_abbr: [...]         // Also caches course lists for each department once fetched
};

$.fn.select2.defaults.width = 'resolve';

$(SEARCH).select2({
    data: []
});

function cachedGet(url, key){
    if(state[key]) return $.when(state[key]);
    return $.get(url).done(function(result){
        state[key] = JSON.parse(result);
    });
}

function loadDepartmentSearch(){
    cachedGet(DEPARTMENTS_URL, 'departments').done(function(){
        $(SEARCH).prop('placeholder', 'Browse departments and classes').prop('disabled', false).select2('val', '');
        $(SEARCH).select2({
            createSearchChoice: function() { return null; }, // Forbid custom tags
            matcher: function(term, text, opts) { return text.match('^' + term.toUpperCase()); }, // Force start-of-word matching
            tags: state.departments
        });

        bindEvents(false);
    });
};

function loadCourseSearchForDepartment(){
    cachedGet(COURSES_URL + state.selectedDepartment, state.selectedDepartment).done(function(){
        var placeholder = 'Browse ' + state.selectedDepartment + ' classes';

        $(SEARCH).prop('placeholder', placeholder).select2({
            data: state[state.selectedDepartment]
        }).select2('open');

        var deptNode = $('<span class="department-choice">' + state.selectedDepartment + '</span>').insertBefore(INPUT);
        $(INPUT).css('width', 'calc(100% - ' + deptNode.outerWidth(true) + 'px)');

        bindEvents(true);
    });
}

function courseChosen(e){
    e.preventDefault();
    var paths = getSelectedPaths();
    $('.course-selections').append('<li>(' + e.object.id + ') ' + e.object.text + '</li>');
    $(INPUT).val('');
    $(SEARCH).select2('close').select2('open');
}

function departmentChosen(e){
    e.preventDefault();
    state.selectedDepartment = e.object.text;
    $(SEARCH).select2({
        query: loadCourseSearchForDepartment
    }).select2('open'); // keep menu open while searching
}

function checkForDepartmentDeleted(e){
    var content = $(INPUT).val();
    if(e.which == 8 && content.length == 0){
        e.preventDefault();
        loadDepartmentSearch();
        $(SEARCH).select2('open');
        $(INPUT).val(content.slice(0, -1));
    }
}

function bindEvents(departmentSelected){

    if(departmentSelected){
        $(SEARCH).off(SELECT_EVENT).on(SELECT_EVENT, courseChosen);
        $(INPUT).off(INPUT_EVENT).on(INPUT_EVENT, checkForDepartmentDeleted);
    } else {
        $(SEARCH).off(SELECT_EVENT).on(SELECT_EVENT, departmentChosen);
        $(INPUT).off(INPUT_EVENT);
    }
}

function initSearch(){
    loadDepartmentSearch();

    // Blur input field when dropdown is closed. From http://stackoverflow.com/questions/21157181/blur-select2-input-after-close
    $(SEARCH).on('select2-close', function (){
        setTimeout(function() {
            $('.select2-container-active').removeClass('select2-container-active');
            $(':focus').blur();
        }, 1);
    });

    // A bug in Select2 throws type errors once in a while, but everything still works.
    // This suppresses them.
    window.onerror = function(message, url, lineNumber) {
        if(url.indexOf('select2') != -1 && message.indexOf('Cannot read property "hasClass" of null') != -1){
            console.log('Suppressed[' + message + ' (' + url + ':' + lineNumber + ')]');
            return true;
        }
        return false;
    };  
}

initSearch();

// Path nav:

var PATH_NAV_ITEM = '.path-nav-item';
var PATH_WRAPPER = '.path-wrapper';

function Path(id, name){
    this.id = id;
    this.name = name;
}

function initPaths(){
    $(PATH_NAV_ITEM).on('click', function(e){
        $(PATH_NAV_ITEM).removeClass('active');
        $(this).addClass('active');

        $(PATH_WRAPPER).removeClass('active');
        $(PATH_WRAPPER).eq($(this).index()).addClass('active');
    });

    window.paths = $(PATH_NAV_ITEM).map(function(i, e){
        return new Path($(e).attr('data-id'), $(e).attr('data-name'));
    })
}

function getSelectedPaths(){
    var nodes;
    if($('input[name=addToAllTracks]:checked').val() === '1'){
        nodes = $(PATH_NAV_ITEM);
    } else {
        nodes = $(PATH_NAV_ITEM + '.active');
    };
    return nodes.map(function(i, e){

    })
}

initPaths();

// Path display (requirement mode):

var FILLED_REQUIREMENT = '.path-cell.filled';
var UNFILLED_REQUIREMENT = '.path-cell.unfilled';
var CAN_FILL = UNFILLED_REQUIREMENT + '.fillable';
var REQUIREMENT_ROW = '.path-row';
var UNASSIGNED_CELLS_CLASS = 'extra-cells'
var UNASSIGNED_CELLS = '.' + UNASSIGNED_CELLS_CLASS;

function fillableCells(draggedCell){
    var reqs = draggedCell.data('can-fill');
    var fillable = $(REQUIREMENT_ROW).filter(function(){
        return reqs.indexOf($(this).data('requirement')) !== -1;
    }).toArray().reduce(function(rest, next){
        return rest.concat($(next).find(UNFILLED_REQUIREMENT).first().toArray()); // this is a flat_map from rows to their first fillable cell
    }, []);
    return $(fillable);
}


var replacement;
var isSnapping;

function initDraggable(){
    $(FILLED_REQUIREMENT).draggable({
        snap: CAN_FILL,
        snapMode: 'corner',
        zIndex: 5,
        revert: false,
        cancel: UNFILLED_REQUIREMENT,
        // refreshPositions: true,
        stop: function (event, ui) {
            console.log('watwat')
            var snapTo = ui.helper.data("ui-draggable").snapElements.filter(function(elem){
                return elem.snapping;
            });
            if(snapTo.length > 0){
                isSnapping = $(snapTo[0].item);
            } else {
                isSnapping = false;
            }

            
        }
    });
}

function initPathDisplay(){
    $(document).on('mousedown', FILLED_REQUIREMENT, function(event){
        if(event.which !== 1) return; // ignore non-left clicks
        var elem = $(this);
        var draggingUnassignedCell = elem.closest('ul').hasClass(UNASSIGNED_CELLS_CLASS);

        if(!draggingUnassignedCell){ // create no placeholder if currently unassigned
            replacement = elem.clone();
            replacement.removeClass('filled ui-draggable').addClass('unfilled fillable').attr('data-content', elem.text()).text('').css('margin-left', -elem.outerWidth() + 'px').attr('data-can-fill', '');
            elem.after(replacement);
        }
        fillableCells(elem).addClass('fillable').attr('data-content', elem.text())
    });

    $(document).on('mouseup', FILLED_REQUIREMENT, function(event){
        if(event.which !== 1) return; // ignore non-left clicks
        var elem = $(this);
        var draggingUnassignedCell = elem.closest('ul').hasClass(UNASSIGNED_CELLS_CLASS);

        setTimeout(function(){
            if(isSnapping){ // We remove the replacement, put the original element back, and change the text of both elements to complete the swap
                if(replacement) replacement.remove();
                if(isSnapping.attr('id') !== elem.attr('id')){
                    isSnapping.removeClass('fillable unfilled').addClass('filled ui-draggable').text(elem.text()).attr('data-can-fill', '[' + elem.data('can-fill') + ']');
                    console.log('snappin')
                    elem.css({'top': '', 'left': ''});
                    if(draggingUnassignedCell){
                        elem.closest('li').remove();
                    } else {
                        elem.css({'top': '', 'left': ''}).removeClass('filled ui-draggable').addClass('unfilled').text('').attr('data-content', 'TODO');
                    }
                }

            } else {
                if(replacement) replacement.remove();

                elem.css({'top': '', 'left': ''});
                if(!draggingUnassignedCell){
                    $('<li style="margin-right: 5px;">').append(elem.clone().attr('id', 'cloned' + elem.attr('id'))).append('</li>').appendTo(UNASSIGNED_CELLS); // Margin compensates for missing 'implicit margin' list item thing
                    elem.css({'top': '', 'left': ''}).removeClass('filled ui-draggable').addClass('unfilled').text('').attr('data-content', 'TODO');
                }
            }
            $(CAN_FILL).removeClass('fillable').attr('data-content', 'TODO');
            if(replacement) replacement.css('margin-left', '0');

            initDraggable();

            // $.post('/update_path')

        }, 1);
    });
    initDraggable();
    
}

initPathDisplay();