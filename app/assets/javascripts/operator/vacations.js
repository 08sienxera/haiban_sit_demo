/* ************************************************************************* */
/* 休暇カレンダー用JS */
/* ************************************************************************* */

const VACTYPES={2:"早遅",3:"",6:"公休",7:"振休",8:"年休",9:"特休",10:"夏休",11:"産休",12:"忌引",13:"病欠",14:"公傷",15:"組休",16:"結婚",17:"代休",18:"明休",19:"出停",20:"通災",21:"特年",22:"欠勤",23:"看護",24:"介護",25:"育休",31:"看Ａ",32:"看Ｐ",33:"介Ａ",34:"介Ｐ",41:"年Ａ",42:"年Ｐ","":"",0:""}
let changedData = {}
let tItem = null
let visibleGroup = ""
let targetWindow = null
let parentElement = null
let selectFormWrapper = null
let hol_wk_flg = false
let preSelectBaseNo = ""

function getToday(){
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}


function hundleClick(target,locked){
    if(locked){
        if(target.dataset.baseNo=="6"){
            toggleAtWork(target)
        }else{
            showSelectForm(target,"0")
}
    }else{
        OnOffBase6(target)
    }
}

function checkCanSet(item){
    return null;
}

async function postData(dstUrl,method,params,reload=true){
    if(params==undefined){return;}
    requestBody = JSON.stringify(params)
    try {
        const data = await fetch(postUrl, {
            method: method,
            headers: {'Content-Type': 'application/json'},
            body: requestBody
        })
        if (!data.ok) {
            throw new Error(`response.status = ${data.status}, response.statusText = ${data.statusText}`);
        } 
        respJson = await data.json(); // レスポンスをJSONとしてパース
        let resultMessage = []
        Object.entries(respJson).forEach(([key,value])=>{
            if(value["sts"]!="200"){
                resultMessage.push(`・${key}の休暇登録に失敗しました`)
                resultMessage.push(`　→「${value["msg"]}」`)
            }
        })
        if(resultMessage.length>0){
            reload = true;
            alert(resultMessage.join("\n"));
        }
        if(reload) location.reload();
    } catch (err) {
        alert(`予期しないエラーが発生しました。リロードします。\n${err}`)
        location.reload();
    }
}

function doPost(url,method,reload=true){
    postData(url,method,changedData,reload);
    changedData = {};
}

// 変更リストに追加
const stockData = (item,reload=true)=>{
    const vacationDayStr = item.dataset.vacationDay

    changedData[vacationDayStr] = {
        user : null,
        vacation_day : vacationDayStr,
        base_no : item.dataset.baseNo,
        at_work : item.dataset.atWork,
        //  yyyy/mm/dd　-> yyyymmdd
        origin_date : item.dataset.originDate==''?'' : ([[0,4],[5,7],[8,10]].map(([bigin,end])=>{return item.dataset.originDate.substring(bigin,end)}).join('')),
        end_date: item.dataset.endDate,
        arriv_time: item.dataset.arrivTime,
        leav_time: item.dataset.leavTime,
        hol_wk : item.dataset.holWkFlg
        
    }
    doPost('http://192.168.33.106:3931/operator/vacations','POST',reload);
}

// 対象セルおよび影響セルのロック状態を更新
const updateCellLock = (item)=>{
    const checkFunc = getCkFunc(item);
    if(!checkFunc) return;

    const result = checkFunc(item);
    if(result){
        // OK
        unlockCell(item);
    }else{
        // NG
        lockCell(item);
    }
}
// チェック用関数を返却
const getCkFunc = (item)=>{
    const monthly = item.dataset.monthly;
    const match = monthly.match(/\d{4}(\d{1,2})/);
    if(match){
        const month = match[1];
        return ckMonthlyLock(month) ? ckCurVac : ckNexVac
    };
    return null;
}


const getDate = (dateStrYYYYMMDD) => {return new Date(...[[0,4,0],[4,6,1],[6,8,0]].map(([bigin,end,minus])=>{return Number(dateStrYYYYMMDD.substring(bigin,end))-minus}))}
const getDateInYYYYMMDD = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}${month}${day}`;
}
const updateProperty = (element,property,value)=>{
    const update = (e,p,v)=>{
        e[p]=v;return;
        const tElement = e
        let tProperty = null
        if(Array.isArray(p)){
            tProperty = tElement[p]
            p.forEach((tmp)=>{
                if(tProperty){return}
                tProperty = tProperty[tmp]
            })
        }else{
            tProperty = tElement[p]
        }
        if(!tProperty){
            return
        }      
        tProperty=v
    }
    if(element instanceof HTMLCollection){
        Array.from(element).forEach((e)=>{update(e,property,value)})
        return;
    }
    if(Array.isArray(element)){
        element.forEach((e)=>{update(e,property,value)})
        return;
    }
    update(element,property,value);
}
const r = (str,size) => {return str.substring(str.length-size)}
const l = (str,size) => {return str.substring(0,size)}
const onDisplay = (element,type,bgColor="") =>{element.style.display = type;if(bgColor!=""){element.style.backgroundColor = bgColor;}}
const ofDisplay = (element) =>{element.style.display = "none"}

const lockCell = (cell)=>{cell.dataset.lockFlg=1}
const unlockCell = (cell)=>{cell.dataset.lockFlg=0}
const getCell = (originCell,offset = [0,0]) => {
    const getPos = (gridPosStr)=>{return Number(gridPosStr.substring(0,gridPosStr.indexOf("/")).trim())}
    const formatGridPosStr = (posNum) => {return `${posNum} / ${posNum+1}`}
    originX = getPos(originCell.style.gridColumn)
    originY = getPos(originCell.style.gridRow)
    foundX = originX+offset[0]
    foundY = originY+offset[1]
    let vacCells = document.getElementsByClassName('vac')
    let foundCell = Array.from(vacCells).find(
        (cell)=>{
            return cell.style.gridColumn==formatGridPosStr(originX+offset[0]) && cell.style.gridRow==formatGridPosStr(originY+offset[1])
        }
    )
    return foundCell;
}

const updateAcquirableDays = ()=>{
    onDisplay(document.getElementById("vac-counter"),"block")
    if(acquirableVacationDays==-1 || acquirableVacationDays<=reservedVacationDays){
        ofDisplay(document.getElementById("vac-counter"))
        return;
    }
    document.getElementById('requireSetDay').innerHTML = acquirableVacationDays-reservedVacationDays;
}
const recountAdjacentVacationDays = () => {
    // whFlgListからwh_flgが1の休暇を取得
    let cnt =0
    let wh1lists = Object.keys(whFlgList).filter((key)=>{return whFlgList[key]==1})
    let nex_month_wh1_cells = Array.from(document.getElementsByClassName('vac')).filter((cell)=>cell.style.gridColumn==('7 / 8')).filter((cell)=>wh1lists.includes(r(cell.id,8)))
    nex_month_wh1_cells.forEach((cell)=>{
        const upperCell = getCell(cell,[0,-1])
        if(upperCell!=undefined && upperCell.dataset.baseNo=="6" && whFlgList[r(upperCell.id,8)]==0){cnt = cnt +1;}
        const underCell = getCell(cell,[0,1])
        if(underCell!=undefined && underCell.dataset.baseNo=="6" && whFlgList[r(underCell.id,8)]==0){cnt = cnt +1;}
    })
    adjacentVacationDays = cnt
} 

// チェック用関数(当月列セル)
const ckCurVac = (targetCell) => {
    const targetDate = getDate(r(targetCell.id,8));
    const today = getToday()
    let ckResult = true;
    // 対象セル
    if(ckResult && targetCell.dataset.sts==5){
        ckResult = false
    }
    if(ckResult && targetDate<=today){
        ckResult = false;
    }
    // if(ckResult && includesBaseno6Nglist(r(targetCell.id,8)) || targetDate<today){
    //     ckResult = false;
    // }

    return ckResult;

}

// チェック用関数(当月・公休日列セル)
const ckCurVacL = (targetCell) => {
    targetDate = getDate(r(targetCell.id,8))
    today = getToday()
    rightCell = getCell(targetCell,[1,0]);
    [targetCell,rightCell].forEach(cell=>unlockCell(cell))
    // 対象セル
    if(includesBaseno6Nglist(r(targetCell.id,8))){
        lockCell(targetCell)
    }
    if(targetDate<today || !["0","6"].includes(rightCell.dataset.baseNo)){
        lockCell(targetCell)
    }
    // 右のその他セル
    if(targetDate<today || targetCell.dataset.baseNo==6){
        lockCell(rightCell)
    }
}
// チェック用関数(当月・その他列セル)
const ckCurVacR = (targetCell) => {
    targetDate = getDate(r(targetCell.id,8))
    today = getToday()
    leftCell = getCell(targetCell,[-1,0]);
    [targetCell,leftCell].forEach(cell=>unlockCell(cell))
    // 対象セル
    if(targetDate<today || leftCell.dataset.baseNo==6){
        lockCell(targetCell)
    }
    // 左の公休セル
    if(targetDate<today || !["0","6"].includes(targetCell.dataset.baseNo)){
        lockCell(leftCell)
    }
    if(includesBaseno6Nglist(r(leftCell.id,8))){
        lockCell(leftCell)
    }

}

// 法定休日前後の法定休日チェック
const ckSandwich = (targetCell)=>{
    const upperCell = getCell(targetCell,[0,-1])
    const underCell = getCell(targetCell,[0,1])
    if(!upperCell || !underCell){
        return sandwich[r(targetCell.id,8)]
    }
    const cells = [
        { cell: upperCell, dir: -1 },
        { cell: underCell, dir: 1 }
    ];
    for (let { cell, dir } of cells) {
        if(whFlgList[r(cell.id,8)]==1 && cell.dataset.baseNo=="6"){
            cnt = 1
            offset = dir * cnt
            offsetCell = getCell(cell,[0,offset])
            while(offsetCell && (whFlgList[r(offsetCell.id,8)]==1 && offsetCell.dataset.baseNo=="6")){
                cnt += 1
                offset = dir * cnt
                offsetCell = getCell(upperCell,[0,offset])
            }
            if(!offsetCell){
                return sandwich[r(targetCell.id,8)]
            }
            if(whFlgList[r(offsetCell.id,8)]==0 && offsetCell.dataset.baseNo=="6"){
                return true;
            }
        }
    }
    return false
}

// 公休日　日曜連動　取得可否チェック
const ckContinuesDay = (targetCell)=>{
    const wday = targetCell.dataset.wday;
    if(!(wday=="1" || wday=="6")) return false;

    const selectorMonthly = "[data-monthly='" + targetCell.dataset.monthly +"']";
    const selectorBaseNo = "[data-base-no='6']";
    const monVacs = document.querySelectorAll("div.grid-item[data-wday='1']" + selectorMonthly + selectorBaseNo);
    const satVacs = document.querySelectorAll("div.grid-item[data-wday='6']" + selectorMonthly + selectorBaseNo);

    return (monVacs.length + satVacs.length) >= SundayContinuedHolidayLimit;
}


// 公休日　月曜日1回、土曜日1回　チェック
const ckWday = (targetCell)=>{
    wday = targetCell.dataset.wday
    if(!(wday=="1" || wday=="6")){return false}
    wday_vacations = Array.from(document.querySelectorAll(`.nmonth[data-wday='${wday}'][data-base-no='6']`))
    hvacations = wday_vacations.filter((vac)=>{return whFlgList[vac.dataset.vacationDay]==0})
    return hvacations.length>0
    
}

// チェック用関数(翌月セル)
const ckNexVac = (targetCell) => {
    let ckResult = true;
    // 法定休日が未設定の場合、ロック
    if(lHolUnsetFlg){
        ckResult = false; return ckResult;
    }
    if(targetCell.dataset.whflg==1){
        ckResult = false; return ckResult;
    }


    //休暇申請されていない　＆＆　(当月の公休取得上限に達していない)
    let targetDateStr = r(targetCell.id,8)
    let targetDate = getDate(targetDateStr)
    let nextDate = new Date(targetDate);
    nextDate.setDate(targetDate.getDate() + 1);
    let preDate = new Date(targetDate);
    preDate.setDate(targetDate.getDate() - 1);

    if(includesBaseno6Nglist(r(targetCell.id,8))){
        ckResult = false;
        return ckResult;
    }
    
    switch(targetCell.dataset.baseNo){
        case "0":
            if([
            // 1休暇に隣接している && その他にも2か所で1休暇に隣接している休暇を設定している
                (whFlgList[getDateInYYYYMMDD(preDate)]==1 || whFlgList[getDateInYYYYMMDD(nextDate)]==1) && adjacentVacationDays == 2,
            // 法定休を指定公休でサンドイッチ
                ckSandwich(targetCell),
            // 日曜日連動休の取得可否チェック
                ckContinuesDay(targetCell)
            // 月曜日、土曜日の指定公休チェック
                // ckWday(targetCell)
            ].some((prop)=>prop===true)){
                ckResult = false;
            }
            break;
        case "6":
            //     公休がセットされている：
            //         判定：vacationのat_workが設定されている || wh_calendarのwh_flgが0である　→　ロックする
            if(targetCell.dataset.atWork!="0" || whFlgList[r(targetCell.id,8)]==1){
                ckResult = false;
            }
            break;
        default:
            //     公休以外の休暇がセットされている：
            if(!["0","6"].includes(targetCell.dataset.baseNo)){
                ckResult = false;
            }
            break;
        }

        return ckResult;

}
//公休日取得NGリストに含まれるか？
function includesBaseno6Nglist(tDateYYYYMMDD){
    return baseno6Nglist.map((v)=>{return v.replace("-","")}).includes(r(tDateYYYYMMDD,4))
}


// 当月　公休〇×セット
const toggleAtWork = (item) => {
    if(item.classList.contains("hol-wk")){
        showSelectForm(item,"1")
    return
    }
    updateAtwork(item);
}
const updateAtwork = (item)=>{
    if(item.dataset.lockFlg==1){return}
    if(item.dataset.baseNo != 6){return;}


    let atWork = Number(item.dataset.atWork)
    let atWorkAfter = (atWork+1)%3
    atWorkAfter = atWorkAfter!=0 ? atWorkAfter : 1

    item.dataset.atWork = atWorkAfter

    stockData(item,false);
    item.innerHTML = getViewStr(item)
    updateCellLock(item)
}

// 翌月　公休セット
const OnOffBase6 = (item)=>{
    if(item.dataset.lockFlg==1){return}
    // enableMusk();
    baseNo = item.dataset.baseNo
    try {
        if(baseNo==0){
            baseNoAfter = 6
            reservedVacationDays +=1
        }else{
            baseNoAfter = 0
            reservedVacationDays -=1
        }
        item.dataset.baseNo = baseNoAfter
        item.innerHTML = getViewStr(item)
        stockData(item);
        recountAdjacentVacationDays();
        updateAcquirableDays();
    } catch (error) {
        throw error;
    } finally {
        nextMonthCells = Array.from(document.getElementsByClassName('vac')).filter((cell)=>cell.style.gridColumn==('7 / 8'));
        nextMonthCells.forEach((item)=>{updateCellLock(item)});
        // disableMusk();
    }
    
    
}
const noscroll = (e)=>{
    e.preventDefault()
}
const scrollLock = (tWindow)=>{
    tWindow.document.addEventListener('wheel',noscroll, {passive: false})
    tWindow.document.addEventListener('touchmove',noscroll, {passive: false})
}
const scrollUnlock = (tWindow)=>{
    tWindow.document.removeEventListener('wheel',noscroll)
    tWindow.document.removeEventListener('touchmove',noscroll)
}

const scrollCenter = (window)=>{
    // ゆっくりスクロール
    let tBox = window.document.getElementById('vacationsBox');
    if(!tBox) tBox = window.document.getElementById('vacationBox');
    const yPos = tBox.getBoundingClientRect().top + window.scrollY
    window.scrollTo({top: yPos,left: 0,behavior: "smooth"})
}

const setBase6List = (monthly)=>{
    $("#d_origin_date>select").html("");
    unusedVacationsStr[monthly].forEach(([str,value])=>{
        $("#d_origin_date>select").append(
            $("<option>",{text: str,value: value})
        );
    });

}

//休暇選択フォーム
// 状態変化：フォーム表示
const showSelectForm = (item,group)=>{
    setBase6List(item.dataset.monthly);

    // 公出日のセルを選択かつ「代休」を選択の場合、data属性origin_dateに選択セルの日付をセットする
    const appOriginDateValue = (baseNo)=>{
        if(baseNo!=item.dataset.baseNo){
            return ""
        }
        if(baseNo=="17" && item.classList.contains("hol-wk")){
            item.dataset.originDate =  formatDate(r(item.id,8))
        }
        return item.dataset.originDate=="0" ? "" : item.dataset.originDate
    }
    
    // 公休出または、data属性vacation_dayと選択セルのidが異なる場合
    // data属性vacation_dayのyyyymmd文字列をDate型で返す
    const comVacationDayValue = ()=>{
        let ret = "";
        if(item.classList.contains("hol-wk")){
            if(item.dataset.vacationDay==r(item.id,8)){
                return "";
            }
            return formatDateS(item.dataset.vacationDay)
        }
        return ret;
    }

    const dataMapping = {
        "#d_vacation_day" : formatDate(item.id.substring(item.id.length-8)),
        "#i_leav_time" : item.dataset.leavTime,
        "#i_arriv_time" : item.dataset.arrivTime,
        "#i_origin_date" : item.dataset.originDate,
        "#i_origin_date2" : item.dataset.originDate,
        "#i_end_date" : item.dataset.endDate,
        "#d_app_origin_date" : appOriginDateValue("7"),
        "#d_app_origin_date2" : appOriginDateValue("17"),
        "#i_com_vacation_day" : comVacationDayValue(),
        "span#def_base_no" : item.dataset.baseNo,
        "span#preselect_base_no" : item.dataset.baseNo,
    }

    // 画面スクロール調整 : iframe上から操作⇒フォームを中央表示
    let targetWindow = null;
    if(window.self!==window.parent){
        targetWindow = window.parent
        scrollCenter(targetWindow);
    }else{
        targetWindow = window
    }


    const holWork = item.classList.contains('hol-wk');
    const baseNo = item.dataset.baseNo

    // フォーム要素表示
    const selectFormWrapper = document.getElementById('select-form-wrapper');
    onDisplay(selectFormWrapper,"block")
    const form = document.getElementById('select-form');
    onDisplay(form,"block")
    scrollLock(targetWindow)

    // inputに選択セルの値をセット
    Object.keys(dataMapping).forEach((key)=>{
        const el = document.querySelector(key);
        if(el.tagName=="INPUT" || el.tagName=="SELECT"){
            updateProperty(el,"value",dataMapping[key]);
        }else{
            updateProperty(el,"innerText",dataMapping[key]);
        }
    })


    // 警告メッセージを設定（CSS
    switch (baseNo) {
        case '7': //振休
            document.getElementById('d_app_origin_date').classList.add('active_msg');
            document.getElementById('d_app_origin_date2').classList.remove('active_msg');
            document.getElementById('d_app_origin_date2').classList.remove('future');
        break;
        case '17': //代休
            document.getElementById('d_app_origin_date').classList.remove('active_msg');
            document.getElementById('d_app_origin_date2').classList.add('active_msg');

            // 休暇日が未来日の場合、警告メッセージに「変更の場合は、取消後に再申請してください」を表示
            const match = item.dataset.vacationDay.match(/(\d{4})(\d{2})(\d{2})/);
            if(match){
                const vacationDay = getDate(match[1] + match[2] + match[3]);
                if(vacationDay > getToday()){document.getElementById('d_app_origin_date2').classList.add('future')};
            }
        break;
    }


    // 代休(base_no==17)の場合は変更および削除不可
    removeButton = document.getElementById('removeButton')
    ofDisplay(removeButton)
    if(baseNo!="0" && item.dataset.lockFlg=="0"){
    // if(baseNo!="0" && baseNo!="17" && item.dataset.lockFlg=="0"){
        onDisplay(removeButton,"inline-block")
    }

    // 選択グループ切替
    $('div#select-form tr').each(function(i,el){
        const td = $(el).find('td');
        const vgroup = td.data("vgroup");
        if(vgroup==undefined){
            $(el).removeClass("hiddenRow")
        }else{
            const vgroupArr = String(vgroup).split(",");
            if(td.data("vgroup")==undefined || vgroupArr.includes(group)){
                $(el).removeClass("hiddenRow")
            }else{
                $(el).addClass("hiddenRow")
            }
        }
    });

    // origin_date表示切替
    $("#d_origin_date,#d_origin_date2").each(function(i,e){
        const tr = $(e).parent();
        if(tr.hasClass("hiddenRow")) return true;
        if(item.dataset.originDate==="" || item.dataset.originDate==="0"){
            tr.removeClass("hiddenRow")
        }else{
            tr.addClass("hiddenRow")
        }
    })
    $("#d_app_origin_date,#d_app_origin_date2").each(function(i,e){
        const tr = $(e).parent();
        if(tr.hasClass("hiddenRow")) return true;
        if(item.dataset.originDate==="" || item.dataset.originDate==="0"){
            tr.addClass("hiddenRow")
        }else{
            tr.removeClass("hiddenRow")
        }
    })


    selectChange(baseNo,holWork,true)

    if(item.dataset.lockFlg==1 || baseNo=="17"){
        if(baseNo=="17"){
            const match = item.dataset.vacationDay.match(/(\d{4})(\d{2})(\d{2})/);
            if(match){
                const vacationDay = getDate(match[1] + match[2] + match[3]);
                if(vacationDay < getToday()){
                    unlockForm();
                    lockForm({columns: true,radioButton:true,submitButton:true,cancelButton:true});
                }else{
                    unlockForm();
                    lockForm({columns: true,radioButton:true,submitButton:true});
                }
            }
        }else{
            unlockForm();
            lockForm({columns: true,radioButton:true,submitButton:true,cancelButton:true});
        }
    }else{
        // 登録ボタン活性制御、削除ボタン表示制御
        if(baseNo=="7"){
            const match = item.dataset.originDate.match(/(\d{4}).(\d{2}).(\d{2})/);
            if(match){
                const originDate = getDate(match[1] + match[2] + match[3]);
                if(originDate < getToday()){// 振替元が過去日の場合、変更削除を禁止
                    unlockForm();
                    lockForm({columns: true,radioButton:true,submitButton:true,cancelButton:true});
                }else{// 今日以降の場合、削除を許可、別休暇種別を選択可能
                    unlockForm();
                    lockForm({submitButton:true});

                }
            }
        }else{
            unlockForm();
        }
    }

}


// 状態変化：フォーム非表示
const closeForm = ()=>{
    let targetWindow = null;
    if(window.self!==window.parent){
        targetWindow = window.parent
    }else{
        targetWindow = window
    }

    scrollUnlock(targetWindow)
    const form = document.getElementById('select-form');
    ofDisplay(form)
    const selectFormWrapper = document.getElementById('select-form-wrapper');
    ofDisplay(selectFormWrapper)

}
// 状態変化：項目ロック
const lockForm = (params = {})=>{
    const form = document.getElementById('select-form');
    if(params.columns){
        const elementsToUpdate = [
            { id: "i_leav_time", property: "disabled", value: true },
            { id: "i_arriv_time", property: "disabled", value: true },
            { id: "i_origin_date", property: "disabled", value: true },
            { id: "i_origin_date2", property: "disabled", value: true },
            { id: "i_end_date", property: "disabled", value: true }
        ];
        elementsToUpdate.forEach((element)=>{
            updateProperty(document.getElementById(element.id),element.property,element.value)
        })
    }
    if(params.radioButton){
        updateProperty(document.getElementsByClassName('radiobutton'),"disabled",true)
    }
    if(params.submitButton){
        $("button.submit-btn").prop("disabled",true);
    }
    if(params.cancelButton){
        $("button.cancel-btn").prop("disabled",true);
        $("button.cancel-btn").css("display","none");
    }
    // updateProperty(document.getElementsByClassName('radiobutton'),"disabled",true)
    // $("button.submit-btn").prop("disabled",true);
    // $("button.cancel-btn").prop("disabled",true);
    // $("button.cancel-btn").css("display","none");

}
// 状態変化：項目アンロック
const unlockForm = ()=>{
    const form = document.getElementById('select-form');
    const elementsToUpdate = [
        { id: "i_leav_time", property: "disabled", value: false },
        { id: "i_arriv_time", property: "disabled", value: false },
        { id: "i_origin_date", property: "disabled", value: false },
        { id: "i_origin_date2", property: "disabled", value: false },
        { id: "i_end_date", property: "disabled", value: false }
    ];
    elementsToUpdate.forEach((element)=>{
        updateProperty(document.getElementById(element.id),element.property,element.value)
    })
    
    updateProperty(document.getElementsByClassName('radiobutton'),"disabled",false)
    $("button.submit-btn").prop("disabled",false);
    $("button.cancel-btn").prop("disabled",false);
    $("button.cancel-btn").css("display","inline-block");

}

// 状態変化：ラジオボタン選択時の強調表示
const selectChange = (baseNo,holWork=false,init=false)=>{
    // 直前の選択と同じ種別を選択した場合、未選択にする
    if(!init && $("span#preselect_base_no").text()==baseNo){baseNo="0"}
    // 公休⇒代休取得のため代休設定画面を表示
    if(holWork) baseNo="17";

    const defBaseNo = $("span#def_base_no");
    if(defBaseNo){
        if(baseNo=='7' && baseNo == defBaseNo.text() || baseNo=='17' && baseNo == defBaseNo.text()){
            $("button.submit-btn").prop('disabled',true);
        }else{
            $("button.submit-btn").prop('disabled',false);
        }
    };

    // ラジオボタン選択
    const radioButtons = document.getElementsByClassName('radiobutton')
    Array.from(radioButtons).forEach((button)=>{button.checked = button.value == baseNo})

    // フォーム項目制御
    $('div#select-form tr').each(function(i,el){
        $(el).css("display","");
        if(!$(el).hasClass("hiddenRow")){
            const td = $(el).find('td');
            const rel = td.data("rel");
            if(rel==undefined || String(rel).split("_").includes(baseNo)){
                $(el).css("display","table-row")
            }else{
                $(el).css("display","none")
            }
        };
    });

    $("span#preselect_base_no").text(baseNo)
}

// 入力した値を反映、変更リストに追加
const setValue = ()=>{
    errMsg = ckEss();// 必須入力チェック
    if(errMsg.length>0){
        alert(errMsg.join('\n'));
        return;
    }

    const form = document.getElementById("select-form");
    const match = $(form).find("#d_vacation_day").text().match(/(\d{4}).(\d{1,2}).(\d{1,2})/);
    if(!match) return;
    const yyyymmdd = match[1]+match[2]+match[3];
    let tItem = $("#vac_" + yyyymmdd);
    if(tItem.length==0) return;

    tItem = tItem.get(0);
    if(tItem.classList.contains('hol-wk')){
        let inputVacationDay = document.getElementById('i_com_vacation_day').value
        let vacationDayYYYYMMDD = [[0,4],[5,7],[8,10]].map(([bigin,end])=>{return inputVacationDay.substring(bigin,end)}).join('')
        // 更新データに同日の登録データある場合は既存データを削除
        if(changedData[tItem.dataset.vacationDay]){
            delete changedData[tItem.dataset.vacationDay]
        }
        tItem.dataset.vacationDay = vacationDayYYYYMMDD
        let baseNo = document.querySelector("input[type='radio']:checked").value
        tItem.dataset.baseNo = baseNo
        tItem.dataset.arrivTime = document.getElementById('i_arriv_time').value
        tItem.dataset.leavTime = document.getElementById('i_leav_time').value
        tItem.dataset.originDate = formatDate(r(tItem.id,8))
        tItem.dataset.endDate = document.getElementById('i_end_date').value
        tItem.dataset.holWkFlg = hol_wk_flg
    }else{
        let checkedItem = document.querySelector("input[type='radio']:checked")
        let selectBaseNo
        if(checkedItem){
            selectBaseNo = checkedItem.value    
        }else{
            selectBaseNo = "2"
        }
        tItem.dataset.baseNo = selectBaseNo
        tItem.dataset.arrivTime = document.getElementById('i_arriv_time').value
        tItem.dataset.leavTime = document.getElementById('i_leav_time').value
        if(selectBaseNo=="7"){
            tItem.dataset.originDate = document.getElementById('i_origin_date').value
        }else if(selectBaseNo=="17"){
            tItem.dataset.originDate = document.getElementById('i_origin_date2').value
        }else{
            tItem.dataset.originDate = ""
        }
        tItem.dataset.endDate = document.getElementById('i_end_date').value
        tItem.innerHTML = getViewStr(tItem)
    }
    updateCellLock(tItem);
    stockData(tItem)
    tItem = null;
    closeForm();

}

// 入力した値をクリア、変更リストに追加
const unsetValue = ()=>{
    const form = document.getElementById("select-form");
    const match = $(form).find("#d_vacation_day").text().match(/(\d{4}).(\d{1,2}).(\d{1,2})/);
    if(!match) return;
    const yyyymmdd = match[1]+match[2]+match[3];
    let tItem = $("#vac_" + yyyymmdd);
    if(tItem.length==0) return;
    tItem = tItem.get(0);



    tItem.dataset.baseNo = "0"
    tItem.dataset.leavTime = ""
    tItem.dataset.arrivTime = ""
    tItem.dataset.originDate = ""
    tItem.dataset.endDate = ""
    tItem.innerHTML = getViewStr(tItem)
    updateCellLock(tItem);
    stockData(tItem)
    tItem = null;
    closeForm();
}


// 必須項目の入力チェック
const ckEss = ()=>{

    // 2024-12-27 
    // 休暇種別未選択時⇒出勤希望、退勤希望のいずれかは選択が必須
    let selectedBtn = document.querySelector('input[name="vacation_type"]:checked')
    if(!selectedBtn && !$('#i_arriv_time').val() && !$('#i_leav_time').val()){
        alert("かならず「出勤希望時刻」か「退勤希望時刻」の時刻を指定してください")
        $('#i_arriv_time').get(0).parentElement.style.backgroundColor = "pink";
        $('#i_leav_time').get(0).parentElement.style.backgroundColor = "pink";
        return
    }


    // --
    // 入力ボックスは必須チェック
    // ラジオボタンはいずれか一つでも選択されているか？
    let retMsg = []
    // クラス名にessを持つ、かつ表示状態の要素
    let essItemHeaders = Array.from(document.getElementsByClassName('ess'))
        .filter((h)=>{
            return !(h.parentElement.classList.contains("hiddenRow") || h.parentElement.style.display=="none")
        });
    let essItemCells = Array.from(essItemHeaders).map((h)=>{return document.getElementById("d"+ h.id.substring(h.id.indexOf("_")))});
    const isFill = (element)=>{
        result = false
        Array.from(element.children).forEach((cld)=>{
            switch(cld.tagName.toLowerCase()){
                case 'input':
                case 'select':
                    if(cld.value!=''){result=true}
                    break;
            }
        })
        return result;
    }

    let vacationTypeElements = []
    let vacationTypeSelectedFlg = -1
    for(let i=0; i<essItemHeaders.length; i++){

        t_element = essItemCells[i]
        t_element.parentElement.style.backgroundColor = "white";
        if(t_element.id.indexOf("vacation_type")>0){
            vacationTypeElements.push(t_element)
            if(vacationTypeSelectedFlg!=1){vacationTypeSelectedFlg = 0}
            radiobuttons = t_element.querySelectorAll('.radiobutton')
            if(Array.from(radiobuttons).some((radio) =>{return radio.checked})){
                vacationTypeSelectedFlg = 1;
            }
        }else{
            if(!isFill(t_element)){
                retMsg.push(`「${essItemHeaders[i].innerHTML}」は必須項目です。`)
                t_element.parentElement.style.backgroundColor = "pink";
            }
        }
    }
    if(vacationTypeSelectedFlg==0){
        retMsg.unshift(`「休暇種別」または「半休」のいずれかひとつを選択してください。`)
        vacationTypeElements.forEach((ele)=>{
            ele.parentElement.style.backgroundColor = "pink";
        })
    }
    return retMsg
}



//休暇文字列を返却
const getViewStr = (vacCell)=>{
    let vacStr = VACTYPES[vacCell.dataset.baseNo]
    let atWorkSymbol = ["","〇","×"]
    atWork = Number(vacCell.dataset.atWork)
    if(vacCell.dataset.baseNo=="6"){
        vacStr += atWorkSymbol[vacCell.dataset.atWork]
    }
    if(vacCell.dataset.arrivTime || vacCell.dataset.leavTime){
        vacStr += "</br><span style='font-size:18px;padding:0px;'>("
        if(vacCell.dataset.arrivTime){vacStr += vacCell.dataset.arrivTime}
        vacStr += "~"
        if(vacCell.dataset.leavTime){vacStr += vacCell.dataset.leavTime}
        vacStr += ")</span>"
    }
    return vacStr
}

// return yyyy年mm月dd日
const formatDate = (dateString)=>{
    const year = dateString.substring(0, 4);
    const month = dateString.substring(4, 6);
    const day = dateString.substring(6, 8);
    return `${year}年${month}月${day}日`;
}
// return yyyy/mm/dd日
const formatDateS = (dateString)=>{
    const year = dateString.substring(0, 4);
    const month = dateString.substring(4, 6);
    const day = dateString.substring(6, 8);
    return `${year}/${month}/${day}`;
}



//読込み時の処理
$(function(){
    recountAdjacentVacationDays();
    updateAcquirableDays();

    // フォームのクリックイベントを無効化
    let form = document.getElementById('select-form')
    form.addEventListener('click',(e)=>{
        e.stopPropagation()
    })

    // base_noの値で表示される初期値を「配番用表記」に更新⇒セルのロックチェック
    let vacationItems = document.querySelectorAll("[id^='vac_']");
    Array.from(vacationItems).forEach((item)=>{
        item.innerHTML = getViewStr(item)
        updateCellLock(item)
    })

});




