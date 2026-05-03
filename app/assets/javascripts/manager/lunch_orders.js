/* 昼食集計画面用JS */
$(function(){
    lunchOrdersSelectTab(tab_key)
});

//タブ選択→集計表示切替
function lunchOrdersSelectTab(key){
    // $('#msg_box').css("display","none");
    $('a[id^="tab_"]').css("background-color","#6699CC").css("color","white");
    $("#tab_"+key).css("background-color","yellow").css("color","black");
    $('div[id^="close_btn_"]').css("display","none");
    $("#close_btn_"+key).css("display","block");
    $('div[id^="orderinfo_"]').css("display","none");
    $("#orderinfo_"+key).css("display","block");
}
