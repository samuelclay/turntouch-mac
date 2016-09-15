var loadImages = function() {
    
    $('.NB-story img').each(function () {
        setImage(this);
    });

    $('.NB-story img').bind('load', function () {
        setImage(this);
    });

};

var resizeWindow = function(width) {
    width = width || $("body").width();
    var style = "<style>.NB-ipad-narrow .NB-story img.NB-large-image {max-width: "+width+"px;margin-left: -30px !important;width: "+width+"px !important;}</style>"
    console.log(['resizeWindow', width, style]);
    $("html > head").append(style);
}

var adjustFontSize = function(size) {
    $("body").removeClass("NB-xs")
             .removeClass("NB-small")
             .removeClass("NB-medium")
             .removeClass("NB-large")
             .removeClass("NB-xl")
             .addClass("NB-" + size);
}

var fitVideos = function() {
   $(".NB-story").fitVids({
        customSelector: "iframe[src*='youtu.be'],iframe[src*='flickr.com'],iframe[src*='vimeo.com']"
   });
};

var linkAt = function(x, y, attribute) {
    var el = document.elementFromPoint(x, y);
    return el && el[attribute];
};

function setImage(img) {
    var $img = $(img);
    var width = $(img).width();
    var height = $(img).height();
//    console.log("img load", img.src, width, height);
    if ($img.attr('src').indexOf('feedburner') != - 1) {
        $img.attr('class', 'NB-feedburner');
    } else if (width >= (320-24) && height >= 50) {
        $img.attr('class', 'NB-large-image');
        if ($img.parent().attr('href')) {
            $img.parent().addClass('NB-contains-image')
        }
    } else if (width > 30 && height > 30) {
        $img.attr('class', 'NB-medium-image');
        if ($img.parent().attr('href')) {
            $img.parent().addClass('NB-contains-image')
        }
    } else {
        $img.attr('class', 'NB-small-image');
    }
}

          
function findPos(obj) {
    var curtop = 0; 
    if (obj.offsetParent) {
        do {
            curtop += obj.offsetTop;
        } while (obj = obj.offsetParent);
        return [curtop];
    }
}

loadImages();
resizeWindow();
fitVideos();
