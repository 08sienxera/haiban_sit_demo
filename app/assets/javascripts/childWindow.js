$(function(){
    if(window != window.parent){
        $("#header,#footer,#backHomeBtn,#link_box").css("display","none");
        $("a.showLink").attr("target","_parent");
        let div = document.querySelector('div#field2');
        let height = div.clientHeight+30;
        window.parent.setHeight("#boardsBox", height);
    };
});
