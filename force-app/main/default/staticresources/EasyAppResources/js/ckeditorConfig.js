editor.on('instanceReady', function (e) {
    const newConfig = Object.assign({}, editor.config);
    newConfig.toolbar_EASY = [
        {name: 'clipboard', items: ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo']},
        {name: 'editing', items: ['Find', 'Replace', '-', 'SelectAll', '-', 'Scayt']},
        {
            name: 'basicstyles',
            items: ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'CopyFormatting', 'RemoveFormat']
        },
        {
            name: 'paragraph',
            items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl', 'Language']
        },
        {name: 'links', items: ['Link', 'Unlink', 'Anchor']},
        {name: 'insert', items: ['Image', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak']},
        '/',
        {name: 'styles', items: ['Styles', 'Format', 'Font', 'FontSize']},
        {name: 'colors', items: ['TextColor', 'BGColor']},
        {name: 'tools', items: ['Maximize', 'ShowBlocks']},
    ];
    newConfig.toolbar = 'EASY';
    newConfig.disableNativeSpellChecker = false;
    e.editor.destroy();
    CKEDITOR.replace(e.editor.name, newConfig).on('instanceReady', function (evt) {
        try {
            var id = evt.editor.name;
            CKiframe = document.getElementById('cke_' + id).querySelector('iframe');
            meta = document.createElement('meta');
            meta.setAttribute('name', 'referrer');
            meta.setAttribute('content', 'no-referrer');
            CKiframe.contentDocument.head.appendChild(meta);
        } catch (e) {
            console.log(JSON.stringify(e));
        }
    });
});