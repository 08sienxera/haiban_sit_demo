//Topのメニューを開く
function openSettingMenu(){
    $("nav.setting_menu").slideToggle();
}

function doSetMessage(msg,url){
    if(window != window.parent){
        window.parent.setMessage(msg,url);
    }
}
function doRemoveMessage(msg){
    if(window != window.parent){
        window.parent.removeMessage(msg);
    }
}

// ヘッダーフッター表示制御
function displayHeader(bool){
    $("#header").css("display",headerFooterDisplayValue(bool));
}
function displayFooter(bool){
    $("#footer,#backHomeBtn").css("display",headerFooterDisplayValue(bool));
}
function headerFooterDisplayValue(bool){
    displayProp = bool ? 'block' : 'none'
    return displayProp
}

// 親ウィンドウのiframeサイズ調整
function setParentWindowFrameSize(selector,offsetSize=30){
    if(window==window.parent){return}

    var targetFrame = window.parent.$(selector)
    if(!targetFrame){return}

    let body = document.querySelector('body');
    let height = body.offsetHeight+offsetSize;
    targetFrame.height(
        Math.min(height,window.parent.outerHeight)
    )
}


// 画面ロード時の処理
$(function(){
    if(window != window.parent){
        displayHeader(false);
        displayFooter(false);
    };
});

// 子ウィンドウの表示ページを親ウィンドウで表示
function syncChildWindowWithParent(){
    if(window==window.parent){return;}
    window.parent.location.href = window.location.href
}
