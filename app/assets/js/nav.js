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
