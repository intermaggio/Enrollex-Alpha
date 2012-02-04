/******************************************************************************************************************
 * @name: bPopup
 * @type: jQuery
 * @author: (c) Bjoern Klinggaard (http://dinbror.dk/bpopup)
 * @version: 0.6.0
 * @requires jQuery 1.3
 * todo: no appending, refactoring
 *******************************************************************************************************************/
;(function($) {
    $.fn.bPopup = function(options, callback) {
        if ($.isFunction(options)) {
            callback = options;
            options = null;
        }
        o = $.extend({}, $.fn.bPopup.defaults, options);
        //HIDE SCROLLBAR?  
        if (!o.scrollBar)
            $('html').css('overflow', 'hidden');
        
        var $selector = this,
        d = $(document),
        w = $(window),
        popups = (!w.data('bPopup') ? 1 : w.data('bPopup')+1),
        id = 'bPopup' + popups,
        inside = isInside(),
        $modal = $('<div class="bModal '+id+'"></div>'),
        cp = getCenterPosition($selector, o.amsl),
        fixedVPos = o.position[0] != 'auto',
        fixedHPos = o.position[1] != 'auto',
        vPos = fixedVPos ? o.position[0] : cp[0],
        hPos = fixedHPos ? o.position[1] : cp[1];

        //PUBLIC FUNCTION - call it: $(element).bPopup().close();
        this.close = function() {
            o = $selector.data('bPopup');
            close();
        }

        return this.each(function() {
            if ($selector.data('bPopup')) return; //POPUP already exists?
            // MODAL OVERLAY
            if (o.modal) {
                $modal
                .css({'background-color': o.modalColor, 'height': '100%', 'left': 0, 'opacity': 0, 'position': 'fixed', 'top': 0, 'width': '100%', 'z-index': o.zIndex + popups})
                .appendTo(o.appendTo)
                .animate({ 'opacity': o.opacity }, o.fadeSpeed);
            }
            $selector.data('bPopup', o).data('id',id);
            // CREATE POPUP  
            create();
        });

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // HELP FUNCTIONS - PRIVATE
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        function create() {
            $selector
            .css({ 'left': (!o.follow[1] && fixedHPos || o.follow[2]) ? hPos : d.scrollLeft() + hPos, 'position': (o.follow[2])? 'fixed':'absolute', 'top': (!o.follow[0] && fixedVPos || o.follow[2]) ? vPos : d.scrollTop() + vPos, 'z-index': o.zIndex + popups + 1 })
            .appendTo(o.appendTo)
            .hide(1, function() {
                $.isFunction(o.onOpen) && o.onOpen.call($selector);
                if (o.loadUrl != null)
                    createContent();
            })
            .fadeIn(o.fadeSpeed, function() {
                // Triggering the callback if set    
                $.isFunction(callback) && callback();
            });
            //BIND EVENTS
            bindEvents();
        }
        function close() {
            if (o.modal) {
                $('.bModal.'+$selector.data('id'))
                .fadeOut(o.fadeSpeed, function() {
                    $(this).remove();
                });
            }
            $selector.fadeOut(o.fadeSpeed, function() {
                if (o.loadUrl != null) {
                    o.contentContainer.empty();
                }
            });
            unbindEvents();
            if ($.isFunction(o.onClose)) {
                setTimeout(function() {
                    o.onClose.call($selector);
                }, o.fadeSpeed);
            }
            return false;
        }
        function createContent() {
            o.contentContainer = o.contentContainer == null ? $selector : $(o.contentContainer);
            switch (o.content) {
                case ('iframe'):
                    $('<iframe scrolling="no" frameborder="0"></iframe>').attr('src', o.loadUrl).appendTo(o.contentContainer);
                    break;
                default:
                    o.contentContainer.load(o.loadUrl);
                    break;
            }
        }
        function bindEvents() {
            w.data('bPopup', popups);
            $('.' + o.closeClass).live('click.'+id, close);
            if (o.modalClose) {
                $('.bModal.'+id).live('click', close).css('cursor', 'pointer');
            }

            if (!o.follow[2] && (o.follow[0] || o.follow[1])) {
                w.bind('scroll.'+id, function() {
                    if(inside){
                       $selector
                          .stop()
                          .animate({ 'left': o.follow[1] ? d.scrollLeft() + hPos : hPos, 'top': o.follow[0] ? d.scrollTop() + vPos : vPos }, o.followSpeed);
                    }  
                })
               .bind('resize.'+id, function() {
                   // POPUP
                   inside = isInside();
                   if(inside){
                       cp = getCenterPosition($selector, o.amsl);
                       if (o.follow[0]) { vPos = (fixedVPos ? vPos : cp[0]); }
                       if (o.follow[1]) { hPos = (fixedHPos ? hPos : cp[1]);}
                       $selector
                          .stop()
                           .animate({ 'left': fixedHPos ? hPos : hPos + d.scrollLeft(), 'top': fixedVPos ? vPos : vPos + d.scrollTop() }, o.followSpeed);
                   }
                });
            }
            if (o.escClose) {
                d.bind('keydown.'+id, function(e) {
                    if (e.which == 27) {  //escape
                        close();
                    }
                });
            }
        }
        function unbindEvents() {
            w.data('bPopup', null);
            if (!o.scrollBar) {
                $('html').css('overflow', 'auto');
            }
            $('.' + o.closeClass).die('click.'+id);
            $('.bModal.'+id).die('click');
            d.unbind('keydown.'+id);
            w.unbind('.'+id);
            $selector.data('bPopup', null);
        }
        function getDocumentDimensions() {
            return [d.height(), d.width()];
        }
        function getDistanceToBodyFromLeft() {
            return (w.width() < $('body').width()) ? 0 : ($('body').width() - w.width()) / 2;
        }
        function getCenterPosition(s, a) {
            var vertical = ((w.height() - s.outerHeight(true)) / 2) - a;
            var horizontal = ((w.width() - s.outerWidth(true)) / 2) + getDistanceToBodyFromLeft();
            return [vertical < 20 ? 20 : vertical, horizontal];
        }
        function isInside(){
            return (w.height() > $selector.outerHeight(true)+20);
        }
    };
    $.fn.bPopup.defaults = {
        amsl: 50,
        appendTo: 'body',
        closeClass: 'bClose',
        content: 'ajax',
        contentContainer: null,
        escClose: true,
        fadeSpeed: 250,
        follow: [true, true, false],
        followSpeed: 500,
        loadUrl: null,
        modal: true,
        modalClose: true,
        modalColor: '#000',
        onClose: null,
        onOpen: null,
        opacity: 0.7,
        position: ['auto', 'auto'],
        scrollBar: true,
        zIndex: 9999
    };
})(jQuery);