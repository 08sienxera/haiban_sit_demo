/* ************************************************************************* */
/* メニュー画面用 JS */
/* ************************************************************************* */

//-- 読込時
$(function() {
/* 配番画面のマルチウィンドウの後処理がされていない場合に表示が崩れる対策 */
if(window.opener){window.opener=null};
loadThresholdInputValue();
});


/* -----時間外超過閾値 関連----- */
/* 読込処理 */
function loadThresholdInputValue(){
    const DEF_THRESHOLD = 45
    const inThreshold = document.getElementById("in_threshold");
    const storageDexpiry = window.localStorage.getItem("thresholdDexpiry");
    const today = new Date();
    if (new Date(storageDexpiry) <= today) { window.localStorage.removeItem("thresholdValue") };
    const storageValue = window.localStorage.getItem("thresholdValue");
    inThreshold.value = storageValue || DEF_THRESHOLD
}

/* 保存処理 */
function saveThresholdInputValue(inObj){
    window.localStorage.setItem('thresholdValue', inObj.value);
    let today = new Date;
    yyyy = today.getFullYear(); mm = today.getMonth(); dd = today.getDay();
    let dexpiryDate = new Date(yyyy,mm+1,16).toLocaleDateString();
    window.localStorage.setItem('thresholdDexpiry', dexpiryDate);
}


/* -----帳票ダウンロードリクエスト----- */
function dlFile(fobj,mord){
    if(validateInput(fobj,mord)){
        fobj.mord.value = mord;
        fobj.submit();
    }
}


function validateInput(fobj,mord){
    const ckFunc = getCkFunc(fobj.name)
    const msgs = ckFunc(fobj,mord);
    if(msgs.length>0){
        window.alert(msgs.join("\n"));
        return false;
    }
    return true;
}


function getCkFunc(name){
    const ckFuntions = {
        f1: ckFormF1,
        f2: ckFormF2,
        f3: ckFormF3,
        f4: ckFormF4,
    }
    return ckFuntions[name] ?? (()=>{return []})
}

function ckFormF1(form,mord){
    const msgs = [];
    const inTdate = form.querySelector("input[name='t_date']");
    const inThreshold = form.querySelector("input[name='threshold']");

    if(!ckDate(inTdate.value)){
        msgs.push("「対象日」が無効な日付形式です");
    }
    if(inTdate.value==""){
        msgs.push("「対象日」を入力してください");
    }
    if(inThreshold.value=="" && mord=='MANAGER_WOW.PDF'){
        msgs.push("「時間外超過閾値」を入力してください");
    }
    return msgs;
}

function ckFormF2(form,mord){
    const msgs = [];
    const inTdate = form.querySelector("input[name='t_date']");
    if(!ckDate(inTdate.value)){
        msgs.push("「対象日」が無効な日付形式です");
    }
    if(inTdate.value==""){
        msgs.push("「対象日」を入力してください");
    }
    return msgs;
}

function ckFormF3(form,mord){
    const msgs = [];
    const inStart = form.querySelector("input[name='t_s_date']");
    const inEnd   = form.querySelector("input[name='t_e_date']");

    if(inStart.value==""||inEnd.value==""){
        msgs.push("「対象期間」を入力してください");
        return msgs;
    }
    if(!ckDate(inStart.value)){
        msgs.push("「対象日」(開始)が無効な日付形式です");
    }
    if(!ckDate(inEnd.value)){
        msgs.push("「対象日」(終了)が無効な日付形式です");
    }
    if(msgs.length>0){
        return msgs;
    }

    const startDate = new Date(inStart.value);
    const endDate   = new Date(inEnd.value);
    if(startDate>endDate){
        msgs.push("「対象期間」は集計開始日～集計終了日を指定してください");
        return msgs;
    }

    if(mord=="TAX_FREE_MACHINES_PDF"){
        if(startDate.getFullYear()!=endDate.getFullYear() || startDate.getMonth()!=endDate.getMonth()){
            msgs.push("「免税軽油稼働実績表」の出力では\n対象期間に同じ年月を指定してください");
        }
    }
    return msgs;
}

function ckFormF4(form,mord){
    const msgs = [];
    const inYear  = form.querySelector("input[name='m_yyyy']");
    const inMonth = form.querySelector("input[name='m_mm']");
    if(inYear.value==""||inMonth.value==""){
        msgs.push("「対象月」を入力してください")
    }
    if(!inYear.value.match(/^\d{4}$/)){
        msgs.push("対象年は半角数字4桁を入力してください")
    }
    if(!inMonth.value.match(/^\d{1,2}$/)){
        msgs.push("対象月は半角数字1～2桁を入力してください")
    }
    if(msgs.length==0 && (Number(inMonth.value)<1 || Number(inMonth.value)>12)){
        msgs.push("対象月は1～12の範囲で入力してください")
    }
    return msgs;
}

function ckDate(inValue){
    const dateObj = new Date(inValue);
    return !Number.isNaN(dateObj.getTime());
}
