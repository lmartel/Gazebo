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

function initRightClick(){
    context.init({});
    $('.path-cell.filled').each(function(){
        $(this).on('contextmenu.prepare', function(e){
            e.preventDefault();
            var terms = $(this).data('offered').map(termAbbrFromNumber);
            if(terms.length === 0){
                terms = 'Not offered this year';
            } else {
                terms = 'Offered ' + terms.join(', ');
            }
            var course = $(this).text();

            context.attach('#' + $(this).attr('id'), [{
                header: course
            }, {
                text: terms
            }, {
                text: "Open description in new tab >>",
                target: '_blank',
                href: '/courses/' + course.replace(' ', '/')
            }/*, {
                divider: true
            }, {
                text: 'Disable this menu until refresh', 
                action: function(e){
                    e.preventDefault();
                    context.destroy('.path-cell.filled');
                    console.log("WAT")
                }
            }*/]);
            $(this).off('contextmenu.prepare');
            $(this).trigger('contextmenu');
        });
    });
}

function termAbbrFromNumber(n){
    switch(n){
        case 1: return 'AUT';
        case 2: return 'WIN';
        case 3: return 'SPR';
        case 4: return 'SUM';
    }
}

initPaths();
initRightClick();
