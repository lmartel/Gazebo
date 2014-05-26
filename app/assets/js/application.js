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
        if(url.indexOf('select2') != -1 && message.indexOf("Cannot read property 'hasClass' of null") != -1){
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
    if($('input[name=addToAllTracks]:checked').val() === "1"){
        nodes = $(PATH_NAV_ITEM);
    } else {
        nodes = $(PATH_NAV_ITEM + ".active");
    };
    return nodes.map(function(i, e){

    })
}

initPaths();

// Path display (requirement mode):

var FILLED_REQUIREMENT = ".path-cell.filled";
var UNFILLED_REQUIREMENT = ".path-cell.unfilled";

function initPathDisplay(){
    $(FILLED_REQUIREMENT).draggable({
        snap: UNFILLED_REQUIREMENT
    });
}

initPathDisplay();