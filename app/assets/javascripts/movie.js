function checkImage(url) {
    if (url) {
        $('.preview-image').attr('src', url);
        $('.preview-image').show();
        $('.glyphicon-eye-close').hide();
    } else {
        $('.glyphicon-eye-close').show();
        $('.preview-image').hide();
    }
}