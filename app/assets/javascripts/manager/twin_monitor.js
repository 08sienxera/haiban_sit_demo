let mainWindow
let subWindow
let jq
let originValFunction

// 読み込み時の処理
$(function(){init();});

const init = ()=>{
}

// サブモニターを閉じる
const closeSubWindow = ()=>{
    subWindow.close()
}
// サブモニターを開く
// サブモニターの表示制御
const initLayout = (target,idList)=>{
    let wd
    if(target===mainWindow){
        wd = mainWindow
    }else if(target===subWindow){
        wd = subWindow
    }else{return}
    idList.forEach(id => {
        wd.document.getElementById(id).style.display='none'
    });
}


