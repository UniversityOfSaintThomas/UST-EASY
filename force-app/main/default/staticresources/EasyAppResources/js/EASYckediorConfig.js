CKEDITOR.editorConfig = function (a) {
    a.toolbarCanCollapse = !1;
    a.resize_enabled = !1;
    a.enterMode = CKEDITOR.ENTER_BR;
    a.shiftEnterMode = CKEDITOR.ENTER_P;
    a.forcePasteAsPlainText = !1;
    a.forceSimpleAmpersand = !0;
    a.pasteFromWordRemoveFontStyles = !1;
    a.pasteFromWordRemoveStyles = !1;
    a.imageUploadAllowedExtensions = ".(jpg|gif|jpeg|png|bmp|jfif|jpe|pjpeg)$";
    a.imageUploadDeniedExtensions = "";
    var b = [];
    b.push("div{*}(*); span{*}(*); p{*}(*); br{*}(*); hr{*}(*);");
    b.push("h1{*}(*); h2{*}(*); h3{*}(*); h4{*}(*); h5{*}(*); h6{*}(*);");
    b.push("a[*]{*}(*);");
    b.push("img[!src,alt,width,height,border]{*}(*);");
    b.push("font[face,size,color];");
    b.push("strike; s; b; em; strong; i; big; small; sub; sup; blockquote; ins; kbd; pre{*}(*); tt;");
    b.push("abbr; acronym; address; bdo; caption; cite; code; col; colgroup;");
    b.push("dd; del; dfn; dl; dt; q; samp; var;");
    b.push("table{*}(*)[align,border,cellpadding,cellspacing,summary];");
    b.push("caption{*}(*); tbody{*}(*); thead{*}(*); tfoot{*}(*);");
    b.push("th{*}(*)[scope,colspan,rowspan,align,valign]; tr{*}(*)[align,valign]; td{*}(*)[scope,colspan,rowspan,align,valign];");
    a.extraAllowedContent = b.join(" ");
    a.coreStyles_strike = {element: "strike"};
    a.coreStyles_bold = {element: "b"};
    a.coreStyles_italic = {element: "i"};
    a.removePlugins = "elementspath,maximize,resize,image,liststyle,tabletools,contextmenu";
    a.extraPlugins = "sfdcImage,sfdcMediaEmbed,sfdcSmartLink,sfdcCodeBlock,sfdcTable,sfdcVfAjax4J,sfdcLineHeight";
    a.removeDialogTabs = "link:advanced;table:advanced;tableProperties:advanced";
    a.toolbar_SalesforceBasic = [["Undo", "Redo"], ["Bold", "Italic", "Underline", "Strike"], ["-", "Link",
        "sfdcImage"], ["-", "JustifyLeft", "JustifyCenter", "JustifyRight"], ["-", "BulletedList", "NumberedList"], ["Indent", "Outdent"]];
    a.toolbar_SalesforceLight = [["Bold", "Italic"], ["Link"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList"], ["FontSize"]];
    a.toolbar_EmailMultiFormat = [["SfdcSwitchToText"], ["RemoveFormat", "TextColor", "BGColor"], ["Bold", "Italic", "Underline", "Strike"], ["sfdcImage"], ["Link", "Unlink", "Anchor"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent",
        "Outdent"], ["Font", "FontSize", "Format"]];
    a.toolbar_Email = [["RemoveFormat", "TextColor", "BGColor"], ["Bold", "Italic", "Underline", "Strike"], ["sfdcImage"], ["Link", "Unlink", "Anchor"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Font", "FontSize", "Format"]];
    a.toolbar_EmailWithQT = [["RemoveFormat", "TextColor", "BGColor"], ["Bold", "Italic", "Underline", "Strike"], ["sfdcImage"], ["Link", "Unlink", "Anchor"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList",
        "NumberedList", "Indent", "Outdent"], ["Font", "FontSize", "Format"], ["sfdcQuickText"]];
    a.toolbar_CaseLightningEmail = [["RemoveFormat", "TextColor", "BGColor"], ["Bold", "Italic", "Underline", "Strike"], ["sfdcImageMenu", "sfdcCodeBlock"], ["Link", "Unlink", "Anchor"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Font", "FontSize", "Format"]];
    a.toolbar_CaseLightningEmailWithQT = [["RemoveFormat", "TextColor", "BGColor"], ["Bold", "Italic", "Underline", "Strike"], ["sfdcImageMenu",
        "sfdcCodeBlock"], ["Link", "Unlink", "Anchor"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Font", "FontSize", "Format"], ["sfdcQuickText"]];
    a.toolbar_Knowledge = [["Source"], ["Undo", "Redo"], "Bold Italic Underline Strike - RemoveFormat".split(" "), ["Table", "sfdcCodeBlock"], ["sfdcSmartLink", "Link", "Unlink", "Anchor"], ["sfdcImage"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Format", "Font", "FontSize",
        "TextColor", "BGColor"]];
    a.toolbar_KnowledgeLightning = [["Source"], ["Undo", "Redo"], "Bold Italic Underline Strike - RemoveFormat".split(" "), ["Table", "sfdcCodeBlock"], ["Link", "Unlink", "sfdcSmartLink", "Anchor"], ["sfdcImage", "sfdcMediaEmbed"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Format", "Font", "FontSize", "TextColor", "BGColor"]];
    a.toolbar_KnowledgeLightningWithQT = [["Source"], ["Undo", "Redo"], "Bold Italic Underline Strike - RemoveFormat".split(" "),
        ["Table", "sfdcCodeBlock"], ["Link", "Unlink", "sfdcSmartLink", "Anchor"], ["sfdcImage", "sfdcMediaEmbed"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Format", "Font", "FontSize", "TextColor", "BGColor"], ["sfdcQuickText"]];
    a.toolbar_KnowledgeWithIframes = [["Source"], ["Undo", "Redo"], "Bold Italic Underline Strike - RemoveFormat".split(" "), ["Table", "sfdcCodeBlock"], ["sfdcSmartLink", "Link", "Unlink", "Anchor"], ["sfdcImage", "sfdcMediaEmbed"], ["JustifyLeft", "JustifyCenter",
        "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"], ["Format", "Font", "FontSize", "TextColor", "BGColor"]];
    a.toolbar_Visualforce = [["Undo", "Redo"], ["Bold", "Italic", "Underline", "Strike"], ["Link", "sfdcImage"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"]];
    a.toolbar_HomePageComponent = [["Undo", "Redo"], ["Bold", "Italic", "Underline", "Strike"], ["Table"], ["Link", "sfdcImage"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList",
        "Indent", "Outdent"], ["Font", "FontSize", "TextColor", "BGColor"]];
    a.toolbar_ServiceCommunity = [["Undo", "Redo"], ["Bold", "Italic", "Underline", "Strike"], ["Link", "sfdcImage", "sfdcCodeBlock"], ["JustifyLeft", "JustifyCenter", "JustifyRight"], ["BulletedList", "NumberedList", "Indent", "Outdent"]];
    a.toolbar_SfxEmail = [["Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], ["sfdcImageMenu"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["Link"]];
    a.toolbar_SfxEmailWithQT =
        [["Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], ["sfdcImageMenu"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["Link"], ["sfdcQuickText"]];
    a.toolbar_SfxPardotEmail = [["Source"], ["Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["Link"]];
    a.toolbar_LightningAppBuilder = ["Bold Italic Underline Strike - RemoveFormat".split(" "), ["Link"], ["JustifyLeft", "JustifyCenter",
        "JustifyRight", "Indent", "Outdent"], ["BulletedList", "NumberedList"], ["Font", "FontSize", "TextColor"]];
    a.toolbar_EnhancedEmailTemplate = [["Source"], ["Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["Link"]];
    a.toolbar_EmailTemplate = [["Source"], ["Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["Link"], ["sfdcImageMenu"]];
    a.toolbar_ContentBuilder = [["Format", "Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["sfdcLineHeight"], ["Link", "-", "sfdcContentBuilderImageMenu"], ["Source"]];
    a.toolbar_EnhancedLetterhead = [["Source"], ["Font", "FontSize"], ["Bold", "Italic", "Underline", "-", "TextColor"], "NumberedList BulletedList - JustifyLeft JustifyCenter JustifyRight".split(" "), ["Link"], ["sfdcImageMenu"]];
    a.plugins = "about,a11yhelp,basicstyles,bidi,blockquote,clipboard,colorbutton,colordialog,copyformatting,contextmenu,dialogadvtab,div,elementspath,enterkey,entities,filebrowser,find,flash,floatingspace,font,format,forms,horizontalrule,htmlwriter,image,iframe,indentlist,indentblock,justify,language,link,list,liststyle,magicline,maximize,newpage,pagebreak,pastefromgdocs,pastefromlibreoffice,pastefromword,pastetext,preview,print,removeformat,resize,save,selectall,showblocks,showborders,smiley,sourcearea,specialchar,stylescombo,tab,table,tabletools,templates,toolbar,undo,wysiwygarea";
    var c = this.config;
    setTimeout(function () {
        if (!document.getElementById("sfdc-ckeditor4-css-override")) {
            var a = document.getElementsByTagName("head")[0], b = document.createElement("link");
            b.id = "sfdc-ckeditor4-css-override";
            b.rel = "stylesheet";
            b.type = "text/css";
            b.href = c.baseHref + "/sfdc-css-override.css";
            b.media = "all";
            a.appendChild(b)
        }
    }, 0)
};