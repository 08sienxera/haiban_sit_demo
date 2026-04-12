/* ************************************************************************* */
/* 業務固有 */
/* ************************************************************************* */
//locale情報
var locale = "ja";

//入力チェック
function goInput(){
    var fobj=document.inform;if(iCheck(fobj)){fobj.submit();}}
//検索実行
function doSerch(){
    var fobj=document.serch;if(SiCheck(fobj)){fobj.submit();}}
//削除
function goDelete(){
    var retMsg = ""
    switch(locale){
    case "ja":
        retMsg = "削除します。よろしいですか？";break;
    case "en":
        retMsg = "Delete. Is it OK?";break;
    }
    if(confirm(retMsg)){document.delform.submit();}}

//POPUPWindow
function popWin(url,name,w,h){
    var option = "";
    option += "width="+w+","
    option += "height="+h+","
    option += "menubar=1,toolbar=1,scrollbars=2,resizable=1,top=1,left=1";
    subWin=window.open(url,name,option);
    subWin.focus();
    return subWin;
}

//オブジェクトの横幅を取得
function getObjectWidth(id) {
    var ret = 0;
    var obj = document.getElementById(id);
    if(obj){ret = obj.clientWidth;}
    if(ret === undefined){ret = 0;}
    return ret;
}
//オブジェクトの高さを取得
function getObjectHeight(id) {
    var ret = 0;
    var obj = document.getElementById(id);
    if(obj){ret = obj.clientHeight;}
    if(ret === undefined){ret = 0;}
    return ret;
}
//オブジェクトの縦位置を取得
function getPageY() {
    if(window.pageYOffset){return window.pageYOffset;}
    else{return (document.documentElement || document.body.parentNode || document.body).scrollTop;}
}
//オブジェクトの縦位置を取得
function getPageX() {
    if(window.pageXOffset){return window.pageXOffset;}
    else{return (document.documentElement || document.body.parentNode || document.body).scrollLeft;}
}
//オブジェクトの縦位置を取得
function offsetTop(e){
    var t = 0;
    t += e.offsetTop;
    if(e.offsetParent){t += offsetTop(e.offsetParent);}
    return t;
}
//オブジェクトの横位置を取得
function offsetLeft(e){
    var l = 0;
    l += e.offsetLeft;
    if(e.offsetParent){l += offsetLeft(e.offsetParent);}
    return l;
}
//現在日時の取得
function getNowStr(){
    var now = new Date();
    var year = now.getYear();
    if (year < 2000) {year += 1900;}
    var month = now.getMonth() + 1;
    if(month<10){month = "0"+month;}
    var day = now.getDate();
    if(day<10){day = "0"+day;}
    var hour = now.getHours();
    if(hour<10){hour = "0"+hour;}
    var minute = now.getMinutes();
    if(minute<10){minute = "0"+minute;}
    return year+"/"+month+"/"+day+" "+hour+":"+minute;
}
//ダブルクリックの制御
var nowLoading = false;
function ckLoadring(){
    if(nowLoading){alert("\u66ab\u304f\u304a\u5f85\u3061\u304f\u3060\u3055\u3044\u3002");return false;}
    else{nowLoading = true;return true;}
}
function unlockLoadring(){
    nowLoading = false;
}
//子ノードのコピー
function cpNods(boxObjR,boxObjTo){
    if(boxObjR && boxObjTo){
        var childnodesR  = boxObjR.childNodes;
        var childnodesTo = boxObjTo.childNodes;
        for(var wi=0;wi<childnodesR.length;wi++){
            switch(childnodesR[wi].nodeName){
            case "#text":
            case "BR":
            case "LABEL":
                break;
            case "SPAN":
                childnodesTo[wi].innerHTML = childnodesR[wi].innerHTML;
                break;
            case "INPUT":
            case "SELECT":
                childnodesTo[wi].value = childnodesR[wi].value;
                childnodesTo[wi].disabled = childnodesR[wi].disabled;
                break;
            case "TABLE":
            case "THEAD":
            case "TBODY":
            case "TFOOT":
            case "TR":
            case "TD":
                cpNods(childnodesR[wi],childnodesTo[wi]);
                break;
            default:
                alert("IN cpNods " + childnodesR[wi].nodeName);
                break;
            }
        }
    }
}
//緯度経度検索
var mapObj,geoObj;
var sMarker,vMarker;
function serchMap(gname,key,flg){
    var mapDiv = document.getElementById("map");
    if(mapDiv){
        if(mapDiv.style.display !== "block"){serchMapInit(mapDiv);}
        var fObj = document.inform;
        var reqStr = "";
        var iObj;
        if(flg==="s"){
            iObj = fObj.prefecture_id;
            if(iObj){reqStr += iObj.options[iObj.selectedIndex].text;}
            var keys = new Array("address1","address2");
            for(var wi=0;wi<keys.length;wi++){
                iObj = fObj.elements[gname+"["+key+keys[wi]+"]"];
                if(iObj){reqStr += iObj.value;}
            }
        }else{
            iObj = fObj.elements[gname+"["+key+"latitude]"];
            if(iObj){reqStr += ""+iObj.value+",";}
            iObj = fObj.elements[gname+"["+key+"longitude]"];
            if(iObj){reqStr += iObj.value+"";}
        }
        if(reqStr !== ""){
            var req = {address: reqStr};
            geoObj.geocode(req, function(result, status){
                if (status !== google.maps.GeocoderStatus.OK) {
                    alert("見つかりませんでした。");return;}
            var latlng = result[0].geometry.location;
            mapObj.setCenter(latlng);
            if(flg==="s"){
                if(sMarker){
                    sMarker.setPosition(latlng);
                    sMarker.setTitle(latlng.toString());
                }else{
                    sMarker = new google.maps.Marker({position:latlng, map:mapObj,
                        title:latlng.toString(), draggable:true});
                    google.maps.event.addListener(sMarker, 'dragend', function(event){
                        sMarker.setTitle(event.latLng.toString());
                        });
                    google.maps.event.addListener(sMarker, 'click', function(event) {
                        var latlng = event.latLng.toString();
                        latlng = latlng.replace(/\(|\)/g,"");
                        var latlngA = latlng.split(",");
                        var fObj = document.inform;
                        iObj = fObj.elements[gname+"["+key+"longitude]"];
                        if(iObj){iObj.value=trim(latlngA[1]).substring(0,9);iObj.focus();}
                        var iObj = fObj.elements[gname+"["+key+"latitude]"];
                        if(iObj){iObj.value=trim(latlngA[0]).substring(0,9);iObj.focus();}
                        });
                    var infowindow = new google.maps.InfoWindow({
                        content: "<p>ドラック＆ドロップで位置を調整してください。<br />クリックで緯度・経度を反映します。</p>",
                        size: new google.maps.Size(200, 30)});
                    infowindow.open(mapObj,sMarker);
                }
            }else{
                if(!vMarker){
                    vMarker = new google.maps.Marker({position:latlng, map:mapObj,
                        icon: markerImgPath,
                        title:latlng.toString()});
                }
            }
            });
        }
    }
}
//Mapの初期化
function serchMapInit(mapDiv){
    mapDiv.style.height = "400px";
    mapDiv.style.width = getObjectWidth("field2")*0.9+"px";
    mapDiv.style.border = "1px solid black";
    mapDiv.style.margin = "10px auto";
    mapDiv.style.display = "block";
    // Google Mapで利用する初期設定用の変数
    var latlng = new google.maps.LatLng(33.5808223, 130.397999199);
    var opts = {zoom: 15,mapTypeId: google.maps.MapTypeId.ROADMAP,center: latlng};
    mapObj = new google.maps.Map(mapDiv, opts);
    // ジオコードリクエストを送信するGeocoderの作成
    geoObj = new google.maps.Geocoder();
}
//行の複製
function cpRow(nRow,rRow,replace_id){
    var nCell,rCell;
    var childs;
    var newElement;
    for(var wi=0;wi<rRow.cells.length;wi++){
        rCell = rRow.cells[wi];
        nCell = nRow.appendChild(document.createElement(rCell.tagName));
        //nCell = nRow.insertCell(-1);
        childs = rCell.childNodes;
        for(var wj=0;wj<childs.length;wj++){
            if(childs[wj].toString() === "[object HTMLTableElement]"){
                newElement = document.createElement('table');
                for(var r=0;r<childs[wj].rows.length;r++){
                    cpRow(newElement.insertRow(-1),childs[wj].rows[r],replace_id);
                }
                newElement.className = childs[wj].className ;
                newElement.id = childs[wj].id ;
            }else{
                if(childs[wj].toString() === "[object HTMLLabelElement]"){
                    newElement = document.createElement('label');
                    var sub_childs = childs[wj].childNodes;
                    for(var wk=0;wk<sub_childs.length;wk++){
                        newElement.appendChild(replaceObjctId(cloneNode(sub_childs[wk]),replace_id));
                    }
                }else{
                    newElement = replaceObjctId(cloneNode(childs[wj]),replace_id);
                    if(newElement.value){if(!newElement.readOnly){
                      if(newElement.type=="radio" || newElement.type=="checkbox"){newElement.checked = false;}
                      else{newElement.value = "";}}}
                }
           }
           nCell.appendChild(newElement);
        }
        nCell.colSpan = rCell.colSpan;
        nCell.rowSpan = rCell.rowSpan;
        nCell.className = rCell.className;
        nCell.vAlign = rCell.vAlign;
    }
}
//ノードのクローン作成
function cloneNode(rObj){
    var retObj;
    if(chckIEVersion7()){
        var wi;
        switch(rObj.type){
        case "text" :
            retObj = document.createElement('input');
            retObj.name = rObj.name;
            retObj.id = rObj.id;
            retObj.type = rObj.type;
            retObj.size = rObj.size;
            retObj.value = rObj.value;
            retObj.onchange = rObj.onchange;
            retObj.readOnly = rObj.readOnly;
            retObj.maxLength = rObj.maxLength;
            retObj.style.imeMode = rObj.style.imeMode;
            retObj.style.width = rObj.style.width;
            retObj.style.backgroundColor = rObj.style.backgroundColor;
            retObj.style.textAlign = rObj.style.textAlign;
            break;
        case "hidden" :
            retObj = document.createElement('input');
            retObj.name = rObj.name;
            retObj.id = rObj.id;
            retObj.type = rObj.type;
            break;
        case "radio" :
        case "checkbox" :
            retObj = document.createElement('input');
            retObj.name = rObj.name;
            retObj.id = rObj.id;
            retObj.type = rObj.type;
            retObj.checked = rObj.checked;
            retObj.value = rObj.value;
            break;
        case "select-one" :
            retObj = document.createElement('select');
            retObj.name = rObj.name;
            retObj.id = rObj.id;
            for(wi = 0;wi<rObj.options.length;wi++){
                retObj.options[wi] = new Option(rObj.options[wi].text,rObj.options[wi].value);
            }
            break;
        default :
            retObj = rObj.cloneNode(true);
            break;
        }
    }else{
        retObj = rObj.cloneNode(true);
        if(retObj.type=="radio" || retObj.type=="checkbox"){retObj.checked = false;}
    }
    return retObj;
}
//IEのバージョンを取得
var IE7Flg = -1;
function chckIEVersion7(){
    if(IE7Flg === -1){
        var msie=navigator.appVersion.toLowerCase();
        msie=(msie.indexOf('msie')>-1)?parseInt(msie.replace(/.*msie[ ]/,'').match(/^[0-9]+/)):0;
        IE7Flg = (msie!==0 && msie<10);
    }
    return IE7Flg;
}
//ID・nameのリプレイス
function replaceObjctId(tObj,replace_id){
    if(tObj.name){tObj.name = tObj.name.replace(replace_id[0],replace_id[1]);}
    if(tObj.id){tObj.id = tObj.id.replace(replace_id[0],replace_id[1]);}
    //if(tObj.href){tObj.href = tObj.href.replace(","+replace_row[0],","+replace_row[1]);}
    return tObj;
}
//Ajax用URLの取得
function getUrl(skey){
    var url = location.href;
    url = url.replace(/\?.*/,"");
    var urls = url.split("/");
    var key;
    while(urls.length>0){
        key = urls.pop();
        if(key === skey){break;}
    }
    return urls.join("/");
}
//
function Hash2Str(obj){
    var msg = "";
    for(var key in obj){
        msg += key + "=" + obj[key] + "\n";
    }
    return msg;
}
//配列から要素を検索、無い場合は-1をある場合は要素の位置を返す
function indexOfArray(tArray,tValue){
    if(typeof tArray.indexOf === "function"){
        return tArray.indexOf(tValue);
    }else{
        for(var i=0;i<tArray.length;i++){
            if(tArray[i] == tValue){
                return i;
            }
        }
        return -1;
    }
}
//指定日時点の年齢を誕生日から算出する
function get_age(tdate,birth){
    var dates = [tdate,birth];
    for(var i in dates){
        if(dates[i] == 'undefined' || dates[i] == null || dates[i] == ""){return "";}
        //「yyyy/mm/dd」または「yyyy-mm-dd」形式のみ許容する
        if(!dates[i].match(/^\d{4}\/\d{1,2}\/\d{1,2}$/) && !dates[i].match(/^\d{4}\-\d{1,2}\-\d{1,2}$/)){
            return "";
        }
    }
    //IE対応
    if (!String.prototype.padStart) {
        String.prototype.padStart = function padStart(targetLength,padString) {
            targetLength = targetLength>>0; //truncate if number or convert non-number to 0;
            padString = String((typeof padString !== 'undefined' ? padString : ' '));
            if (this.length > targetLength) {
                return String(this);
            }
            else {
                targetLength = targetLength-this.length;
                if (targetLength > padString.length) {
                    padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
                }
                return padString.slice(0,targetLength) + String(this);
            }
        };
    }
    //誕生日
    dBirth = new Date(birth);
    var y2 = dBirth.getFullYear().toString().padStart(4, '0');
    var m2 = (dBirth.getMonth() + 1).toString().padStart(2, '0');
    var d2 = dBirth.getDate().toString().padStart(2, '0');
    //基準日
    dTdate = new Date(tdate);
    var y1 = dTdate.getFullYear().toString().padStart(4, '0');
    var m1 = (dTdate.getMonth() + 1).toString().padStart(2, '0');
    var d1 = dTdate.getDate().toString().padStart(2, '0');
    //引き算
    const age = Math.floor((Number(y1 + m1 + d1) - Number(y2 + m2 + d2)) / 10000);
    return age;
}
//時間文字列（HH:MM）の00:00からの経過時間(分)を算出する
function strHHMMtoMinutes(strHHMM){
    if(tmpHHMM = strHHMM.match(/^([01]?[0-9]|2[0-3]):([0-5][0-9])$/)){
        return (tmpHHMM[1]-0)*60+(tmpHHMM[2]-0);
    }else{
        return 0;
    }
}
//00:00からの経過時間(分)を時間文字列（HH:MM）に変換する
function minutesToStrHHMM(minutes){
    return ("00"+Math.floor(minutes / 60)).slice(-2) +":"+ ("00"+(minutes % 60)).slice(-2);
}

//locale設定
function set_locale(locale){
    this.locale = locale;
}
//現在の言語のkey名取得
function get_locale_key(key){
    return get_locale_key(key,this.locale);
}
//指定の言語のkey名取得
function get_locale_key(key,locale){
    var ret = "";
    switch(locale){
        case "ja":
            ret = key;
            break;
        case "en":
            ret = key + "_eng";
            break;
        default:
            ret = key;
            break;
    }
    return ret;
}
//言語切り替え
function change_locale(key){
    var tmp = location.pathname.split("/");
    var ret = "";
    if(tmp){
        switch(tmp[1]){
        case "ja":
        case "en":
            tmp.splice(1,1,key);
            ret = tmp.join("/");
            break;
        case "app":
            tmp.splice(1,0,key);
            ret = tmp.join("/");
            break;
        default:
            ret = location.pathname;
        }
    }
    window.location.href = ret + location.search;
}
//指定の入力フォームを非表示(単一)
function setDisplayNone(id) {
    var tmpform = document.getElementById(id);
    if (tmpform){
        tmpform.style.display = "none";
        switch(tmpform.parentNode.tagName){
        case "TD":
            tmpform.parentNode.style.display = "none";
        }
    }
}
//指定の入力フォームを表示(単一)
function setDisplay(id) {
    var tmpform = document.getElementById(id);
    if (tmpform){
        tmpform.style.display = "block";
        switch(tmpform.parentNode.tagName){
        case "TD":
            tmpform.parentNode.style.display = "table-cell";
            //tmpform.parentNode.style.border = "0px #000000 solid";
        }
    }
}
//指定の入力フォームを非表示(複数キー,rowCountなし)
function setDisplayNones(gname,key) {
    for(var num in key){
        var id = gname ? gname + "_" + key[num] : key[num];
        setDisplayNone(id);
    }
}
//指定の入力フォームを表示(複数キー,rowCountなし)
function setDisplays(gname,key) {
    for(var num in key){
        var id = gname ? gname + "_" + key[num] : key[num];
        setDisplay(id);
    }
}
//指定の入力フォームを非表示(複数キー,rowCountあり)
function setDisplayNonesR(parentObjId,gname,key,rowCount) {
    var tmpId = parentObjId.replace(/_[0-9]+$/g,"");
    for(var wi = 1; wi <= Number(rowCount); wi++){
        var blockObj = document.getElementById(tmpId + "_" + wi);
        //複数行ある場合
        if(blockObj){
            var blockId = blockObj.rows.length;
            for(var wj = 1; wj <= Number(blockId); wj++){
                for(var num in key){
                    var id = gname ? (gname + "_" + key[num] + "_" + wi + "_" + wj) : (key[num] + "_" + wi + "_" + wj);
                    setDisplayNone(id);
                }
            }
        }else{
            for(var num in key){
                var id = gname ? (gname + "_" + key[num] + "_" + wi) : (key[num] + "_" + wi);
                setDisplayNone(id);
            }
        }
    }
}

//指定の入力フォームにパラメータを設定
function setFormParam(searchAttrKey,searchAttrValue,paramKey,value,force){
    // idで要素を取得
    iform = document.querySelector(`[${searchAttrKey}="${searchAttrValue}"]`)
    if(!iform){return}
    // 取得要素がフォームではない場合、処理終了
    if(iform.tagName!='FORM'){return}
    const existingInput = iform.querySelector(`[name="${paramKey}"]`)
    if(existingInput){
        if(force){existingInput.remove()}else{return iform}
    }

    newInput = document.createElement("input")
    newInput.type = 'hidden'
    newInput.name = paramKey
    if(Array.isArray(value) || typeof(value)==='object'){
        newInput.value = JSON.stringify(value);
    }else{
        newInput.value = value
    }

    iform.appendChild(newInput);
    return iform;

}

//指定の入力フォームの指定パラメータを除外
function unsetFormParam(searchAttrKey,searchAttrValue,paramKey){
    // idで要素を取得
    // 取得要素がフォームではない場合、処理終了
    // 指定paramKeyの要素が存在しない場合、処理終了
    // paramKeyの既存要素を削除
    // フォーム要素をリターンして終了
    // idで要素を取得
    iform = document.querySelector(`[${searchAttrKey}="${searchAttrValue}"]`)
    if(!iform){return}
    // 取得要素がフォームではない場合、処理終了
    if(iform.tagName.toLowerCase()!='form'){return}
    const existingInput = iform.querySelector(`[name="${paramKey}"]`)
    if(existingInput){
        existingInput.remove();
    }
    return iform

}
