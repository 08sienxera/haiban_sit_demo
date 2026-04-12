/* ************************************************************************* */
/* 業務共通関数群 */
/* ************************************************************************* */
var submitFlg = false;
//2重サブミット防止
function ck_submitting(){
    if(submitFlg){
        alert("送信中です。\nしばらくお待ちください。");
        setTimeout("reset_submitting()", 60000);
        return false;
    }else{
        submitFlg = true;
        return true;
    }
}
function reset_submitting(){
    submitFlg = false;
}
//一覧表の全チェックボックスのＯＮ・ＯＦＦ
function ck_box_all(cellObj){
    var ckecked;
    if(cellObj.tag == "ON"){
        cellObj.tag = "OFF";
        ckecked = false;
    }else{
        cellObj.tag = "ON";
        ckecked = true;
    }
    fobj = document.list;
    for(i=0;i<fobj.elements.length;i++){
        if(fobj.elements[i].type=="checkbox" && fobj.elements[i].disabled == false){
            fobj.elements[i].checked = ckecked;
        }
    }
}
//一覧表のチェックボックスのＯＮ・ＯＦＦ
function ck_box(rowObj){
    iObjects = rowObj.getElementsByTagName("input")
    if(iObjects){
        for(wi=0;wi<iObjects.length;wi++){
            iObj = iObjects[wi];
            if(iObj.type=="checkbox" && iObj.name.substring(0,2) == "ck"){
                if(checked == iObj){
                    checked = null;
                }else{
                    iObj.checked = !iObj.checked;
                }
                try{if(btnControlle){btnControlle();}
                }catch(e){}
                break;
            }
        }
    }
}
var checked = null;
function ck_my_box(myObj){
    checked = myObj;
}
//選択リストのデータセット
function setselectList(obj,arrayText,arrayData){
	dellselectList(obj);
	for(i=0;i<arrayData.length;i++){
		obj.options[i] = new Option(arrayText[i],arrayData[i]);
	}
}
//選択リストのデータクリア
function dellselectList(obj){
	for(i=obj.options.length;i>-1;i--){
		obj.options[i]=null;
	}
}
//選択リストのデータ存在チェック
function indexOfselectList(obj,value){
    for(i=0;i<obj.length;i++){
        if(obj.options[i].value == value){
            return i
        }
    }
    return -1;
}
//選択リストの全選択/全解除
function setAllSelectList(robj,selected){
    if(robj){for(var wi=0;wi<robj.options.length;wi++){robj.options[wi].selected=selected;}}
}
//選択リストの全選択/全解除
function ckAllSelectList(cellObj,robj){
    var selected;
    if(cellObj.tag === "ON"){
        cellObj.tag = "OFF";
        selected = false;
    }else{
        cellObj.tag = "ON";
        selected = true;
    }
    setAllSelectList(robj,selected);
}

//消費税の取得
function get_Consumer_tax(){
	return 0.05;
}
//ラジオボタンの選択している値を返す
//	targetobj:対象のInputオブジェクト(EX:document.myform.data)
function getRadioVal(targetobj){
    var i;
    if(targetobj.length){
        for(i=0;i<targetobj.length;i++){
            if(targetobj[i].checked){return targetobj[i].value;}}
    }else{
        if(targetobj.type=="radio"){
            if(targetobj.checked){return targetobj.value;}
        }else{
            return targetobj.value;
        }
    }
    return "";
}
//ラジオボタンの値を選択する
//	targetobj:対象のInputオブジェクト(EX:document.myform.data)
function setRadioVal(targetobj,val){
    var i;
    if(targetobj.length){
        for(i=0;i<targetobj.length;i++){
            if(targetobj[i].value == val){targetobj[i].checked = true;return;}}
    }
}
//
//入力項目のクリア
//INPUT	obj:対象のフォームオブジェクト(EX:document.myform
//OUTPUT:無し
function common_AllClr(obj){
    for(var i=0;i<obj.elements.length;i++){
        clear_input(obj.elements[i]);
    }
}
//値のクリア（個別）
function clear_input(robj){
    if(robj){
        switch(robj.type){
            case "text" :
            case "textarea" : if(robj.readOnly==false){robj.value = "";} break;
            case "select-one" : robj.selectedIndex = -1 ;break;
            default :
                if(robj.length){
                    for(var wk=0;wk<robj.length;wk++){robj[wk].checked = false;}
                }else{
                    robj.checked = false;
                }
                break;
        }
    }
}

//カレンダー小窓の表示
//	targetobj:対象のButtonオブジェク
function popup_cal(tobj){
	tname=tobj.name;
	tname=tname.substring(0,tname.lastIndexOf('_col'));
	fname=tobj.form.name;
	URL="/public/calendar.php?tname="+tname+"&fname="+fname
	Win=window.open(URL,'cal','width=200,height=170,scrollbars=yes,status=yes');
}
//ファイルパスより拡張子を取得
function getExtention(fileName) {
	var ret="";
	if (!fileName) {
		return ret;
	}
	var fileTypes = fileName.split(".");
	var len = fileTypes.length;
	if (len === 0) {
		return ret;
	}
	ret = fileTypes[len - 1];
	return ret;
}
//値の入れ替え
function shunting_input(robj , tobj){
    if(robj && tobj){
        var tmp,wk;
        switch(robj.type){
            case "text" :
            case "textarea" :
                tmp = robj.value;robj.value = tobj.value;tobj.value = tmp;
                break;
            case "select-one" :
                tmp = robj.selectedIndex;robj.selectedIndex = tobj.selectedIndex;tobj.selectedIndex = tmp;
                break;
            default :
                if(robj.length){
                    if(robj[0].type == "radio"){
                        var ckRval = getRadioVal(robj);
                        var ckTval = getRadioVal(tobj);
                        setRadioVal(tobj,ckRval);
                        setRadioVal(robj,ckTval);
                    }else{
                        for(wk=0;wk<robj.length;wk++){
                            tmp = robj[wk].checked;
                            robj[wk].checked = tobj[wk].checked;
                            tobj[wk].checked = tmp;
                        }
                    }
                }else{
                    tmp = robj.checked;robj.checked = tobj.checked;tobj.checked = tmp;
                }
                break;
        }
    }
}
//日付の加減算
function dateAdd(strDay,addDay){
    var date = new Date(strDay);
    if(date == "Invalid Date"){
        return "";
    }else{
        var retDayTime = date.getTime()
        retDayTime += (addDay*86400000);
        date.setTime(retDayTime);
        var year = date.getYear();
        if (year < 2000) {year += 1900;}
        var month = date.getMonth() + 1;
        if(month<10){month = "0"+month;}
        var day = date.getDate();
        if(day<10){day = "0"+day;}
        return year+"/"+month+"/"+day;
    }
}


/* ************************************************************************* */
/* 入力フォーマット関数群 */
/* ************************************************************************* */
//エラー/正常時の背景色セット
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		Flg:"ON"=色をセットする,"OFF"=色を戻す
//OUTPUT:なし
function setError(targetobj,Flg){
    if(Flg=="ON"){
        setStyle(targetobj,"#FFDDDD","error");
    }else{
        if(targetobj.readOnly){
            setStyle(targetobj,"#DDDDDD","");
        }else{
            setStyle(targetobj,"","");
        }
    }
}
//入力項目の背景色をＳｅｔ
function setStyle(targetobj,strcolor,strtag){
	switch(targetobj.type){
	case "select-one":
		targetobj.style.backgroundColor=strcolor;
		break;
	case "radio":
	case "checkbox":
		targetobj.parentNode.style.backgroundColor=strcolor;
		break;
	default:
		if(targetobj.length){
			for(i=0;i<targetobj.length;i++){
				setStyle(targetobj[i],strcolor,strtag);
			}
		}else{
			targetobj.style.backgroundColor=strcolor;
		}
	}
	targetobj.tag=strtag;
}
//エラーが発生している最初のオブジェクトをフォーカスする
function setErrFocus(fobj){
    if(fobj){for(wi=0;wi<fobj.elements.length;wi++){if(hasErr(fobj.elements[wi])){fobj.elements[wi].focus();break;}}}
}
//エラーが発生しているかどうか
function hasErr(tObj){
    return (tObj.tag === "error")
}
//画面上の入力項目の不活性化
//optarget：入力項目以外で不活性化させたい項目のID
function SetDisable() {
	for(i=0;i<document.all.length;i++){
		if (document.all[i].type == "text") {
			document.all[i].setAttribute("readOnly", "true");	//不活性に
			document.all[i].setAttribute("className", "Ro");		//不活性色に
		} else if (document.all[i].type == "textarea") {
			document.all[i].readOnly=true;
			document.all[i].setAttribute("className", "Ro");		//不活性色に
		} else if (document.all[i].type == "select-one" || document.all[i].type == "checkbox" || document.all[i].type == "file") {
			document.all[i].disabled = true;
			document.all[i].setAttribute("className", "Ro"); //不活性色に
		}
	}
	if (arguments.length > 0) {
		for (j=0;j<arguments.length; j++) {
			document.all[arguments[j]].disabled = true;
			document.all[arguments[j]].setAttribute("className", "Ro"); //不活性色に
		}
	}

}
//日付入力時にフォーマットを調整
function set_date(targetobj){
	var tmp = targetobj.value;
	var retstr = "";
	if(tmp.match(/^(\d*)[\/-](\d*)[\/-](\d*)$/)){
		yy = RegExp.$1 - 0;
		if(yy<100){yy+=2000;}
		retstr = yy + "/" + ("00"+RegExp.$2).slice(-2)+ "/" + ("00"+RegExp.$3).slice(-2);
	}else if(tmp.match(/^(\d{1,2})[\/-](\d{1,2})$/)){
		dd = new Date();
		yy = dd.getFullYear();
		retstr = yy + "/" + ("00"+RegExp.$1).slice(-2)+ "/" + ("00"+RegExp.$2).slice(-2);
	}else{
		switch(tmp.length){
		case  0 :
			break;
		case  1 :
			if(tmp=="0"){tmp = (new Date()).getDate();}
		case  2 :
			dd = new Date();
			yy = dd.getFullYear();
			if (yy < 2000) { yy += 1900; }
			retstr = yy+"/"+("0"+ (dd.getMonth() + 1)).slice(-2)+"/"+("0"+tmp).slice(-2);
			break;
		case  4 :
			dd = new Date();
			yy = dd.getFullYear();
			if (yy < 2000) { yy += 1900; }
			retstr = yy+"/"+tmp.slice(0,2)+"/"+tmp.slice(-2);
			break;
		case  6 :
			retstr = "20"+tmp.slice(0,2)+"/"+tmp.slice(2,4)+"/"+tmp.slice(-2);
			break;
		case  8 :
			retstr = tmp.slice(0,4)+"/"+tmp.slice(4,6)+"/"+tmp.slice(-2);
			break;
		case 10 :
			retstr = tmp.slice(0,4)+"/"+tmp.slice(5,7)+"/"+tmp.slice(-2);
			break;
		default :
			retstr = tmp;
			break;
		}
	}
	targetobj.value = retstr;
}
//時間入力時にフォーマットを調整
function set_time(targetobj){
	var tmp = targetobj.value;
        if(tmp == ""){return false;}
	var retstr = "";
	if(tmp.match(/^(\d*):(\d*)$/)){
		retstr = ("00"+RegExp.$1).slice(-2) + ":" + ("00"+RegExp.$2).slice(-2);
	}else{
		switch(tmp.length){
		case  0 :
			retstr = "00:00";
			break;
		case  1 :
			retstr = "0"+tmp+":00";
			break;
		case  2 :
			retstr = tmp+":00";
			break;
		case  4 :
			retstr = tmp.slice(0,2)+":"+tmp.slice(-2);
			break;
		default:
			retstr = tmp;
			break;
		}
	}
	targetobj.value = retstr;
}
//日付時間入力時にフォーマットを調整
function set_datetiem(targetobj,defTime){
	var tmpObj = new Object();
	var tmpA = targetobj.value.split(" ");
	var retstr = "";
	tmpObj.value = tmpA[0];
	set_date(tmpObj);
	retstr= tmpObj.value;
	if(tmpA.length>1){
		tmpObj.value = tmpA[1];
		set_time(tmpObj);
		retstr += " "+tmpObj.value;
	}else if(retstr!=""){
		if(defTime){retstr += " "+defTime;}
		else{retstr += " 00:00";}
	}
	targetobj.value = retstr;
}
//時間期間入力時にフォーマットを調整
function set_timeTerm(targetobj){
	var tmpObj = new Object();
	var tmpA = targetobj.value.split(" ");
	var retstr = "";
	tmpObj.value = tmpA[0];
	set_time(tmpObj);
	retstr= tmpObj.value;
	if(tmpA.length>1){
		tmpObj.value = tmpA[1];
		set_time(tmpObj);
		retstr += "-"+tmpObj.value;
	}
	targetobj.value = retstr;
}

//* ****************************************************************** */
//            <<金額等の整数系カンマ付与編集>>
//* ****************************************************************** */
function addComma(obj){
	var obj = delComma(obj);
	if((obj == "")||(isNaN(obj))){
		return(obj);
	}
	var rtn = obj.indexOf("0x");
	if(rtn != -1){
		return(obj);
	}
	var wk = obj.split('.');
	if(wk.length > 1){
		if (wk[0] == '')
			w_obj = '0';
		else
			w_obj = wk[0];
	} else {
		w_obj = obj;
	}
	var w_obj = String(Number(w_obj));
	var flg = 0;
	var w_o;
	obj = w_obj;

	if((!isNaN(w_obj))&&(w_obj.length > 0)){
		var num_obj = Number(w_obj);
		w_obj = String(num_obj);
		if(num_obj < 0){
			flg = 1;
			w_obj = String(Math.abs(num_obj));
		}
		var wk = w_obj.split('.');
		obj = wk[0];
		var cnt = 0;
		w_o = "";
		len = obj.length;
		for(i = 0; i < obj.length; i++){
			t = obj.substring(i,i+1);
			w_o = w_o + t;
			cnt = cnt + 1;
			if(obj.length - cnt == 12 || obj.length - cnt == 9 || obj.length - cnt == 6 || obj.length - cnt == 3){
				w_o = w_o + ",";
			}
		}
		if(flg == 1){
			w_o = '-' + w_o;
		}
	} else {
		w_o = w_obj;
	}
	return(w_o);
}
//********************************************************************/
//            <<カンマ除去ロジック>>
//********************************************************************/
function delComma(obj){
//20090706 SIT Mitsuno Add Start
	if (obj) {
//20090706 SIT Mitsuno Add End
		var work1 = String(obj).split(",");
		var work2 = work1.join("");
		return(work2);
//20090706 SIT Mitsuno Add Start
	} else {
		return obj;
	}
//20090706 SIT Mitsuno Add End

}
//********************************************************************/
//全角カナを半角カナに
function jsCheckHanKataArray(c) {
	var res;
	var code;
	var ZenKataArray = new Array(
		"。","「","」","、","・","ヲ","ァ","ィ","ゥ","ェ","ォ","ャ","ュ","ョ","ッ","ー",
		"ア","イ","ウ","エ","オ","カ","キ","ク","ケ","コ","サ","シ","ス","セ","ソ","タ",
		"チ","ツ","テ","ト","ナ","ニ","ヌ","ネ","ノ","ハ","ヒ","フ","ヘ","ホ","マ","ミ",
		"ム","メ","モ","ヤ","ユ","ヨ","ラ","リ","ル","レ","ロ","ワ","ン","゛","゜"
	);
	var Dakuon1Array = new Array("ガ","ギ","グ","ゲ","ゴ","ザ","ジ","ズ","ゼ","ゾ","ダ","ヂ","ヅ","デ","ド");
	var Dakuon2Array = new Array("バ","ビ","ブ","ベ","ボ");
	var HandakuArray = new Array("パ","ピ","プ","ペ","ポ");
	c = c.replace("　"," ");	//全角スペースにも対応してやる
	c = c.replace("－","-");	//全角―にも対応してやる
	res = c;
	code = 0;

	for (i in ZenKataArray) {
		if (c == ZenKataArray[i]) {
			code = i - ( - 0xFF61 );
			res = String.fromCharCode(code);
			break;
		}
	}
	if (code == 0) {
		for (i in Dakuon1Array) {
			if (c == Dakuon1Array[i]) {
				code = i - ( - 0xFF76 );
				res = String.fromCharCode(code, 0xFF9E);
				break;
			}
		}
	}
	if (code == 0) {
		for (i in Dakuon2Array) {
			if (c == Dakuon2Array[i]) {
				code = i - ( - 0xFF8A );
				res = String.fromCharCode(code, 0xFF9E);
				break;
			}
		}
	}
	if (code == 0) {
		for (i in HandakuArray) {
			if (c == HandakuArray[i]) {
				code = i - ( - 0xFF8A );
				res = String.fromCharCode(code, 0xFF9F);
				break;
			}
		}
	}
	return res;
}
//********************************************************************/
//全角数字を半角数字に
function Fulltohalf(data){
	var char1 = new Array("１","２","３","４","５","６","７","８","９","０");	//全角数字配列
	var char2 = new Array(1,2,3,4,5,6,7,8,9,0);	//半角数字配列
	var count;
	while(data.match(/[０-９]/)){	//入力データに全角数字がある場合
		for(count = 0; count < char1.length; count++){
			data = data.replace(char1[count], char2[count]);	//入力データを全角数字から半角数字に置換する
		}
	}
	return data;	//半角数字に置換したデータを設定
}
//********************************************************************/
//全角カナを半角カナに
function set_HKn(tobj){
	set_Kn(tobj);
	tobj.value = jsZenToHan(tobj.value);
}
//全角カナを半角カナに
function jsZenToHan(src) {
	var pos = 0;
	var len = src.length;
	var res = '';
	while (pos < len) {
		res += jsCheckHanKataArray(src.charAt(pos));
		pos++;
	}
	res = Fulltohalf(res);
	return (res);
}
//全角かなを全角カナに
function set_Kn(tobj){
    var val = tobj.value;
    var i, c, a = [];
    for(i=val.length-1;0<=i;i--){
        c = val.charCodeAt(i);
        if(c == 32){    //半角スペース→全角スペースに
            a[i] = 12288;
        }else{
            a[i] = (0x3041 <= c && c <= 0x3096) ? c + 0x0060 : c;
        }
    }
    tobj.value = String.fromCharCode.apply(null, a);
}
//前後の空白を除去
function trim(str){
    return str.replace(/(^[\s　]+)|([\s　]+$)/g, "");
}
/* ************************************************************************* */
/* 入力チェック関数群 */
/* ************************************************************************* */
var null_NG_Flg = true;
//必須のみチェック
function check_ess(targetobj,targetName){
    var retmessage="";
    if(targetobj.tag==""){
      switch(targetobj.type){
        case "text":
        case "textarea":
            if(targetobj.value==""){
                switch(locale){
                case "ja":
                    retmessage = targetName + "を入力してください。\n";break;
                case "en":
                    retmessage = "Please enter " + targetName + ".\n";break;
                }
            }
            break;
        case "select-one":
            if(targetobj.value==""){
                switch(locale){
                case "ja":
                    retmessage = targetName + "を選択してください。\n";break;
                case "en":
                    retmessage = "Please select " + targetName + ".\n";break;
                }
            }
            break;
        case "radio":
            if(!targetobj.checked){
                switch(locale){
                case "ja":
                    retmessage = targetName + "を選択してください。\n";break;
                case "en":
                    retmessage = "Please select " + targetName + ".\n";break;
                }
            }
            break;
        case "hidden":
            break;
        default :
            if(targetobj.length){
                var ck = false;
                for(var wi=0;wi<targetobj.length;wi++){ck = (ck || targetobj[wi].checked);}
                if(!ck){
                    switch(locale){
                    case "ja":
                        retmessage = targetName + "を選択してください。\n";break;
                    case "en":
                        retmessage = "Please select " + targetName + ".\n";break;
                    }
                }
            }else{
                retmessage = targetobj.type + ":" + targetobj.name;
            }
            break;
      }
      if(retmessage!=""){setError(targetobj,"ON");}
      else{setError(targetobj,"OFF");}
    }
    return retmessage;
}
//一覧表のチェックボックスのチェック
function iListCheck(obj){
	ret = new Array();
	ret["count"]=0;
	ret["key"]="";
	ret["rowIndex"]="";
        rowIndex=0;
	for(i=0;i<obj.elements.length;i++){
		if(obj.elements[i].type=="checkbox"){
                        rowIndex++;
			if(obj.elements[i].checked){
				ret["count"]++;
				ret["key"] += obj.elements[i].name+"\t";
                                ret["rowIndex"] += rowIndex+"\t";
			}
		}
	}
	return ret;
}
//数字チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//		minlength:最小文字数
//		maxlength:最大文字数
//OUTPUT:エラーメッセージ
function check_Num(targetobj,NullFlg,targetName,minlength,maxlength){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                    switch(locale){
                    case "ja":
                        retmessage = targetName + "を入力してください。\n";break;
                    case "en":
                        retmessage = "Please enter " + targetName + ".\n";break;
                    }
                    setError(targetobj,"ON");
                    return retmessage;
		}
	}
	if(targetobj.value.match( /[^0-9-]+/ )){
                switch(locale){
                case "ja":
                    retmessage = targetName + "に半角数字とハイフン（-）以外が入力されています。\n";break;
                case "en":
                    retmessage = "A character other than single-byte numbers and hyphens (-) is entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
    }else if(minlength!=="" || maxlength!=="" ){
        var min = minlength - 0;
        var max = maxlength - 0;
        if(min === max && min > 0 && targetobj.value.length !==min){
             switch(locale){
             case "ja": retmessage = targetName + "は" + min + "文字を入力してください。\n";break;
             case "en": retmessage = "Please enter " + min + " characters for " + targetName + ".\n";break;
             }
             setError(targetobj,"ON");
        }else if(targetobj.value.length < min && min > 0 && NullFlg!=1 && targetobj.value.length>0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + min + "文字以上を入力してください。\n";break;
            case "en": retmessage = "Please enter more than " + min + " characters for " + targetName + ". \n";break;
            }
            setError(targetobj,"ON");
        }else if(targetobj.value.length > max && max > 0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + max + "文字以下を入力してください。\n";break;
            case "en": retmessage = "Please enter a " + targetName + " of " + max + " or less.\n";break;
            }            
            setError(targetobj,"ON");
        }
    }
    if(retmessage===""){setError(targetobj,"OFF");}
    return retmessage;
}
//数字のみチェック（マイナス可）
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_NumOnly(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if (!targetobj.value.match(/^[-]?[0-9]+$|^$/)){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角数字以外が入力されています。\n";break;
                case "en":
                    retmessage="A non-numeric character is entered in "+targetName+".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//数字のみチェック（小数可）
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_NumOnlyF(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if (!targetobj.value.match(/^(0|-?[1-9]\d*|-?(0|[1-9]\d*)\.\d+|^)$/)){
                switch(locale){
                case "ja":
                    retmessage = targetName + "に正しくない数字が入力されています。\n";break;
                case "en":
                    retmessage="Incorrect number entered for "+targetName+".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//数字チェック(小数点を許可)
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_Dec(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage="Please enter " + targetName + ".\n";break;
                        }
                        setError(targetobj,"ON");
                        return retmessage;
		}
	}
	if (!targetobj.value.match(/^[-]?[0-9.]+$|^$/)){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角数字と小数点（.）、マイナス記号（-）以外が入力されています。\n";break;
                case "en":
                    retmessage="A character other than a single-byte number, decimal point (.), Or minus sign (-) is entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
	}else if(targetobj.value!=""){
		tmpA=targetobj.value.split(".");
		if(tmpA.length>2){
                        switch(locale){
                        case "ja":
                            retmessage=targetName+"小数点（.）が2個以上入力されています。\n";break;
                        case "en":
                            retmessage="Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
		}else{
			if(tmpA[0]==""){
				targetobj.value="0"+targetobj.value;
			}else if(tmpA[1]==""){
				targetobj.value=tmpA[0];
			}
		}
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}

//数字のみチェック（マイナス不可）
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//		minlength:最小文字数
//		maxlength:最大文字数
//OUTPUT:エラーメッセージ
function check_NumOnlyP(targetobj,NullFlg,targetName,minlength,maxlength){
	retmessage="";
	if(targetName.length==0){
		targetName="数値入力域";
	}
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage="Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if (!targetobj.value.match(/^[0-9]+$|^$/)){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角数字以外が入力されています。\n";break;
                case "en":
                    retmessage="A character other than a single-byte number is entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
    }else if(minlength!=="" || maxlength!=="" ){
        var min = minlength - 0;
        var max = maxlength - 0;
        if(min === max && min > 0 && targetobj.value.length !==min){
			switch(locale){
			case "ja": retmessage = targetName + "は" + min + "桁で入力してください。\n";break;
			case "en": retmessage = "Please enter " + min + " digits for " + targetName + ".\n";break;
			}
			setError(targetobj,"ON");
        }else if(targetobj.value.length < min && min > 0  && NullFlg!=1 && targetobj.value.length>0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + min + "桁以上を入力してください。\n";break;
            case "en": retmessage = "Please enter more than " + min + " digits for " + targetName + ". \n";break;
            }
            setError(targetobj,"ON");
        }else if(targetobj.value.length > max && max > 0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + max + "桁以下を入力してください。\n";break;
            case "en": retmessage = "Please enter a " + targetName + " of " + max + " or less.\n";break;
            }
            setError(targetobj,"ON");
        }
    }
    if(retmessage===""){setError(targetobj,"OFF");}
    return retmessage;
}
//数字のみチェック（マイナス不可）+最大、最小チェック
function check_NumOnlyP_MM(targetobj,NullFlg,targetName,min,max){
    var retmessage=check_NumOnlyP(targetobj,NullFlg,targetName);
    if(retmessage=="" && targetobj.value!=""){
        var val = targetobj.value-0;
        if(val < (min-0)){
                switch(locale){
                case "ja":
                    retmessage = targetName + "は" + min + "以上を入力してください。\n";break;
                case "en":
                    retmessage = "Please enter more than " + min + " for " + targetName + ".\n";break;
                }
        }else if(val > (max-0)){
                switch(locale){
                case "ja":
                    retmessage = targetName + "は" + max + "以下を入力してください。\n";break;
                case "en":
                    retmessage = "Please enter a " + targetName + " of " + max + " or less.\n";break;
                }
        }
	if(retmessage!=""){setError(targetobj,"ON");}
    }
    return retmessage;
}
//
//
//半角英字チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_AA(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^A-Za-z]+/ )){
                switch(locale){
                case "ja":
                    retmessage = targetName+"に半角英字以外の文字が入力されています。\n";break;
                case "en":
                    retmessage = "A character other than single-byte alphabetic characters is entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//
//半角英数字チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_Alp(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }            
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^0-9A-Z]+/ )){
                switch(locale){
                case "ja":
                    retmessage = targetName + "を入力してください。\n";break;
                case "en":
                    retmessage = "Please enter " + targetName + ".\n";break;
                }
		// retmessage=targetName+"に半角英数大字以外の文字が入力されています。\n";
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//半角英数字チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//		minlength:最小文字数
//		maxlength:最大文字数
//OUTPUT:エラーメッセージ
function check_Alp2(targetobj,NullFlg,targetName,minlength,maxlength){
    var retmessage="";
    if(NullFlg===1 && null_NG_Flg){
        if(targetobj.value===""){
            switch(locale){
            case "ja": retmessage = targetName + "を入力してください。\n";break;
            case "en": retmessage = "Please enter " + targetName + ".\n";break;
            }
            setError(targetobj,"ON");
            return retmessage;
        }
    }
    if (targetobj.value.match(/[^0-9A-Za-z ]+/)) {
        switch (locale) {
        case "ja": retmessage = targetName + "に半角英数字以外の文字が入力されています。\n"; break;
        case "en": retmessage = targetName + " must be alphanumeric.\n"; break;
        }
        setError(targetobj,"ON");
    }else if(minlength!=="" || maxlength!=="" ){
        var min = minlength - 0;
        var max = maxlength - 0;
        if(min === max && min > 0 && targetobj.value.length !==min){
			switch(locale){
			case "ja": retmessage = targetName + "は" + min + "文字を入力してください。\n";break;
			case "en": retmessage = "Please enter " + min + " characters for " + targetName + ".\n";break;
			}
			setError(targetobj,"ON");
        }else if(targetobj.value.length < min && min > 0 && NullFlg!=1 && targetobj.value.length>0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + min + "文字以上を入力してください。\n";break;
            case "en": retmessage = "Please enter more than " + min + " characters for " + targetName + ". \n";break;
            }
            setError(targetobj,"ON");
        }else if(targetobj.value.length > max && max > 0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + max + "文字以下を入力してください。\n";break;
            case "en": retmessage = "Please enter a " + targetName + " of " + max + " or less.\n";break;
            }
            setError(targetobj,"ON");
        }
    }
    if(retmessage===""){setError(targetobj,"OFF");}
    return retmessage;
}
//半角英数字＋チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_AlpP(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^0-9A-Za-z-_.~:@\/]+/ )){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角英数字とハイフン（-）,アンダーバー（_）\nアットマーク（@）,ドット（.）,以外の文字が入力されています。\n";break;
                case "en":
                    retmessage="Characters other than single-byte alphanumeric characters, hyphens (-), underscores (_) \ nat symbols (@), and dots (.) Are entered in"+targetName+".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//半角英数字＋チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_AlpX(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^0-9A-Za-z-_.~:@\/\*]+/ )){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角英数字とハイフン（-）,アンダーバー（_）\nアットマーク（@）,ドット（.）,アスタリスク（*）以外の文字が入力されています。\n";break;
                case "en":
                    retmessage="Characters other than single-byte alphanumeric characters, hyphens (-), underscores (_) \ nat symbols (@),dots (.), and asterisk(*) Are entered in"+targetName+".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//半角英数字＋チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_Color(targetobj,NullFlg,targetName){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^0-9A-Za-z#]+/ )){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角英数字とシャープ（#）以外の文字が入力されています。\n";break;
                case "en":
                    retmessage = "Characters other than single-byte alphanumeric characters and sharp (#) are entered in " + targetName + ".\n";break;
                }
		// retmessage=targetName+"に半角英数字とシャープ（#）以外の文字が入力されています。\n";
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}

//文字入力チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//		minlength:最小文字数
//		maxlength:最大文字数
//OUTPUT:エラーメッセージ
function check_Txt(targetobj,NullFlg,targetName,minlength,maxlength){
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
			return retmessage;
		}
	}
	if(targetobj.value.match( /[<>"]+/ )){
                switch(locale){
                case "ja":
                    retmessage=targetName+"に半角記号(<,>,\\,\")は入力できません。\n";break;
                case "en":
                    retmessage = "Single-byte symbols (<,>,\\,\") cannot be entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
    }else if(minlength!=="" || maxlength!=="" ){
        var min = minlength - 0;
        var max = maxlength - 0;
        if(min === max && min > 0 && targetobj.value.length !==min){
			switch(locale){
			case "ja": retmessage = targetName + "は" + min + "文字を入力してください。\n";break;
			case "en": retmessage = "Please enter " + min + " characters for " + targetName + ".\n";break;
			}
			setError(targetobj,"ON");
        }else if(targetobj.value.length < min && min > 0 && NullFlg!=1 && targetobj.value.length>0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + min + "文字以上を入力してください。\n";break;
            case "en": retmessage = "Please enter more than " + min + " characters for " + targetName + ". \n";break;
            }
            setError(targetobj,"ON");
        }else if(targetobj.value.length > max && max > 0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + max + "文字以下を入力してください。\n";break;
            case "en": retmessage = "Please enter a " + targetName + " of " + max + " or less.\n";break;
            }
            setError(targetobj,"ON");
        }
    }
    if(retmessage===""){setError(targetobj,"OFF");}
    return retmessage;
}
//日付入力チェック
//INPUT	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//		NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//		targetName:項目名
//OUTPUT:エラーメッセージ
function check_Day(targetobj,NullFlg,targetName){
	var retmessage="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
		}
	}else{
		daystring = targetobj.value.replace(/-/g,"/");
		datedevide = daystring.split("/");
		if(datedevide.length!=3){
                        switch(locale){
                        case "ja":
                            retmessage = targetName+"のフォーマットが正しくありません。（YYYY/MM/DD）\n";break;
                        case "en":
                            retmessage = "The format of " + targetName + " is incorrect.（YYYY/MM/DD）\n";break;
                        }
			setError(targetobj,"ON");
		}else{
			if(!ckDate(datedevide[0], datedevide[1], datedevide[2])){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"が正しくありません。\n";break;
                                case "en":
                                    retmessage = targetName + " is not correct.\n";break;
                                }
				// retmessage = targetName+"が正しくありません。\n";
				setError(targetobj,"ON");
			}else{
				setError(targetobj,"OFF");
				if(datedevide[1].length==1){
					datedevide[1]="0"+datedevide[1];
				}
				if(datedevide[2].length==1){
					datedevide[2]="0"+datedevide[2];
				}
				targetobj.value=datedevide.join("/");
			}
		}
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}

//日付のチェック
//INPUT	YY,mm,dd
//OUTPUT:正：true,不正：false
function ckDate(yy,mm,dd) {
	if(!yy.match(/^\d{4}$/)){
		var vYear = (yy - 0) + 1988;//和暦（平成）→西暦
	}else{
		var vYear = (yy - 0);
	}
	var vMonth = (mm - 0) - 1; // Javascriptは、0-11で表現
	var vDay = (dd - 0);
	// 月,日の妥当性チェック
	if(vMonth >= 0 && vMonth <= 11 && vDay >= 1 && vDay <= 31){
		var vDt = new Date(vYear, vMonth, vDay);
		if(isNaN(vDt)){
			return false;
		}else if(vDt.getFullYear() == vYear && vDt.getMonth() == vMonth && vDt.getDate() == vDay){
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
}
//日付のチェック（年月日が別々のコントロール用）
//INPUT	objYY,objMM,objDD,essFlg,targetName
//OUTPUT:正："",不正：エラーメッセージ
function ckDateSplit(objYY,objMM,objDD,essFlg,targetName) {
	var yy,mm,dd;
	yy = objYY.value;
	mm = objMM.value;
	dd = objDD.value;

	//未入力チェック
	if (yy + mm + dd + "" == "") {
		if (essFlg=="1" && null_NG_Flg) {
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
		} else {
			retmessage = "";
		}
	} else if(yy<1){
                switch(locale){
                case "ja":
                    retmessage = targetName + "が不正です。\n";break;
                case "en":
                    retmessage = targetName + " is not correct.\n";break;
                }
	} else {
		if(!yy.match(/^\d{4}$/)){
			var vYear = (yy - 0) + 1988;//和暦（平成）→西暦
		}else{
			var vYear = (yy - 0);
		}
		var vMonth = (mm - 0) - 1; // Javascriptは、0-11で表現
		var vDay = (dd - 0);
		// 月,日の妥当性チェック
		if(vMonth >= 0 && vMonth <= 11 && vDay >= 1 && vDay <= 31){
			var vDt = new Date(vYear, vMonth, vDay);
			if(isNaN(vDt)){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"のフォーマットが正しくありません。\n";break;
                                case "en":
                                    retmessage = "The format of " + targetName + " is incorrect.\n";break;
                                }
			}else if(vDt.getFullYear() == vYear && vDt.getMonth() == vMonth && vDt.getDate() == vDay){
				retmessage = "";
			}else{
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"のフォーマットが正しくありません。\n";break;
                                case "en":
                                    retmessage = "The format of " + targetName + " is incorrect.\n";break;
                                }
			}
		}else{
                        switch(locale){
                        case "ja":
                            retmessage = targetName+"のフォーマットが正しくありません。\n";break;
                        case "en":
                            retmessage = "The format of " + targetName + " is incorrect.\n";break;
                        }
		}
	}

	if (retmessage != "") {
		setError(objYY,"ON");
		setError(objMM,"ON");
		setError(objDD,"ON");
		return retmessage;
	} else {
		if(mm.length == 1){
			objMM.value = "0" + mm;
		}
		if(dd.length == 1){
			objDD.value = "0" + dd;
		}
		setError(objYY,"OFF");
		setError(objMM,"OFF");
		setError(objDD,"OFF");
		return "";
	}
}

//年月のチェック（年月が別々のコントロール用）
//INPUT	objYY,objMM,objDD,essFlg,targetName
//OUTPUT:正："",不正：エラーメッセージ
function ckYYMMSplit(objYY,objMM,objDD,essFlg,targetName) {
	if (objYY.value=="" && objMM.value==""){
		objDD.value="";
	} else {
		objDD.value="01";
	}
	return ckDateSplit(objYY,objMM,objDD,essFlg,targetName);
}
//日付の大小チェック1
//Input :startYYYY,startMM,startDD,endYYYY,endMM,endDD
//OUTPUT:正："",不正：エラーメッセージ
function CheckDateTerm1(start,end,targetName){
	var retmessage="";
	//どちらかの日付が入っていない場合は検証外
	if(start.value=="" || end.value==""){
	}else{
		var startDate = new Date(start.value);
		var endDate   = new Date(end.value);
		if(startDate.getTime() > endDate.getTime()){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "の日付の順序が正しくありません。\n";break;
                        case "en":
                            retmessage = "The " + targetName + " date order is incorrect.\n";break;
                        }
		}
	}
	if(retmessage==""){
	}else{
		setError(start,"ON");
		setError(end,"ON");
	}
	return retmessage;
}
//日付の大小チェック2
//Input :startYYYY,startMM,startDD
//OUTPUT:正："",不正：エラーメッセージ
function CheckDateTerm2(start_date,targetName){
	var retmessage="";
	var startDate = new Date();
	var endDate   = new Date(start_date.value);
	//日付が入っていない場合は検証外
	if(start_date.value==""){
	}else{
		if(startDate.getTime() > endDate.getTime()){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "は本日以降を指定してください。\n";break;
                        case "en":
                            retmessage = "Please specify " + targetName + " after this date.\n";break;
                        }
		}
	}
	if(retmessage==""){
	}else{
		setError(start_date,"ON");
	}
	return retmessage;
}

//リストの大小チェック1
//Input :start,end,targetName
//OUTPUT:正："",不正：エラーメッセージ
function CheckListTerm1(start,end,targetName){
	var retmessage="";
	if(start.selectedIndex > end.selectedIndex){
                switch(locale){
                case "ja":
                    retmessage = targetName + "の順序が正しくありません。\n";break;
                case "en":
                    retmessage = targetName + " order is incorrect.\n";break;
                }
		// retmessage=targetName+"の順序が正しくありません。\n";
	}
	if(retmessage==""){
		setError(start,"OFF");
		setError(end,"OFF");
	}else{
		setError(start,"ON");
		setError(end,"ON");
	}
	return retmessage;
}
//時間のチェック
function check_Time(targetobj,NullFlg,targetName){
	var retmessage="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
		}
	}else{
		daystring = targetobj.value;
		datedevide = daystring.split(":");
		if(!daystring.match(/^([01]?[0-9]|2[0-3]):([0-5][0-9])$/)){
                        switch(locale){
                        case "ja":
                            retmessage = targetName+"のフォーマットが正しくありません。（HH:ii）\n";break;
                        case "en":
                            retmessage = "The format of " + targetName + " is incorrect.（HH:ii）\n";break;
                        }
			setError(targetobj,"ON");
		}else if(datedevide.length!=2){
                        switch(locale){
                        case "ja":
                            retmessage = targetName+"のフォーマットが正しくありません。（HH:ii）\n";break;
                        case "en":
                            retmessage = "The format of " + targetName + " is incorrect.（HH:ii）\n";break;
                        }
			setError(targetobj,"ON");
		}else{
			if(datedevide[0]<0 || datedevide[0]>23){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"のフォーマットが正しくありません。\n";break;
                                case "en":
                                    retmessage = "The format of " + targetName + " is incorrect.\n";break;
                                }
				setError(targetobj,"ON");
			}else if(datedevide[1]<0 || datedevide[1]>59){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"のフォーマットが正しくありません。\n";break;
                                case "en":
                                    retmessage = "The format of " + targetName + " is incorrect.\n";break;
                                }
				setError(targetobj,"ON");
			}else{
				setError(targetobj,"OFF");
				if(datedevide[0].length==1){
					datedevide[0]="0"+datedevide[0];
				}
				if(datedevide[1].length==1){
					datedevide[1]="0"+datedevide[1];
				}
				targetobj.value=datedevide.join(":");
			}
		}
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//時間の大小チェック1
//Input :
//OUTPUT:正："",不正：エラーメッセージ
function CheckTimeTerm1(start,end,targetName){
	var retmessage="";
	//どちらかの日付が入っていない場合は検証外
	if(start.value=="" || end.value==""){
	}else{
		s=start.value.replace(":");
		e=end.value.replace(":");
		if(s > e){
                        switch(locale){
                        case "ja":
                            retmessage = targetName+"の時間の順序が正しくありません。\n";break;
                        case "en":
                            retmessage = targetName + " time order is incorrect.\n";break;
                        }
		}
	}
	if(retmessage==""){
	}else{
		setError(start,"ON");
		setError(end,"ON");
	}
	return retmessage;
}
//日時のチェック
function check_DayTiem(targetobj,NullFlg,targetName){
	var retmessage="";
	var valstr = targetobj.value;
	var valA = "";
	if(valstr==""){
		if(NullFlg==1 && null_NG_Flg){
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			setError(targetobj,"ON");
		}else{
			valA = new Array();
		}
	}else{
		valA = valstr.split(" ");

		daystring = valA[0].replace(/-/g,"/");
		datedevide = daystring.split("/");
		if(datedevide.length!=3){
                        switch(locale){
                        case "ja":
                            retmessage = targetName+"のフォーマットが正しくありません。（YYYY/MM/DD HH:ii）\n";break;
                        case "en":
                            retmessage = "The format of " + targetName + " is incorrect.（YYYY/MM/DD HH:ii）\n";break;
                        }
			setError(targetobj,"ON");
		}else{
			if(!ckDate(datedevide[0], datedevide[1], datedevide[2])){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"の日付が正しくありません。\n";break;
                                case "en":
                                    retmessage = targetName + " date is incorrect.\n";break;
                                }
				setError(targetobj,"ON");
			}else{
				if(datedevide[1].length==1){
					datedevide[1]="0"+datedevide[1];
				}
				if(datedevide[2].length==1){
					datedevide[2]="0"+datedevide[2];
				}
				valA[0]=datedevide.join("/");
			}
		}
		if(valA.length>1){
			daystring = valA[1];
			datedevide = daystring.split(":");
			if(!daystring.match(/^([01]?[0-9]|2[0-3]):([0-5][0-9])$/)){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"のフォーマットが正しくありません。（YYYY/MM/DD HH:ii）\n";break;
                                case "en":
                                    retmessage = "The format of " + targetName + " is incorrect.（YYYY/MM/DD HH:ii）\n";break;
                                }
				setError(targetobj,"ON");
			}else if(datedevide.length!=2){
                                switch(locale){
                                case "ja":
                                    retmessage = targetName+"のフォーマットが正しくありません。（YYYY/MM/DD HH:ii）\n";break;
                                case "en":
                                    retmessage = "The format of " + targetName + " is incorrect.（YYYY/MM/DD HH:ii）\n";break;
                                }
				setError(targetobj,"ON");
			}else{
				if(datedevide[0]<0 || datedevide[0]>23){
                                        switch(locale){
                                        case "ja":
                                            retmessage = targetName + "の時間が正しくありません。\n";break;
                                        case "en":
                                            retmessage = targetName + "Time is incorrect.\n";break;
                                        }
					setError(targetobj,"ON");
				}else if(datedevide[1]<0 || datedevide[1]>59){
                                        switch(locale){
                                        case "ja":
                                            retmessage = targetName + "の時間が正しくありません。\n";break;
                                        case "en":
                                            retmessage = targetName + "Time is incorrect.\n";break;
                                        }
					setError(targetobj,"ON");
				}else{
					if(datedevide[0].length==1){
						datedevide[0]="0"+datedevide[0];
					}
					if(datedevide[1].length==1){
						datedevide[1]="0"+datedevide[1];
					}
					valA[1]=datedevide.join(":");
				}
			}
		}else{
			if(targetobj.name.match(/_e\]?$/)){
				valA[1]="23:59"
			}else{
				valA[1]="00:00"
			}
		}
	}
	if(retmessage==""){

		targetobj.value = valA.join(" ");
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//********************************************************************/
//半角カナ&半角英数チェック
function check_Kana(targetobj,NullFlg,targetName) {
        var retmessage = "";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			return retmessage;
		}
	}

	//全角カナは半角カナに変換してやる
	str = jsZenToHan(targetobj.value);
	targetobj.value = str;

	kana = " -_｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ";

	for(i=0; i<str.length; i++) {
		if(kana.indexOf(str.charAt(i),0) < 0) {
			if (str.charAt(i).match( /[^0-9a-zA-Z]+/ )) {
				setError(targetobj,"ON");
                                switch(locale){
                                case "ja":
                                    retmessage = targetName + "に半角カナ以外が入力されています。\n";break;
                                case "en":
                                    retmessage = targetName + " other than half-width kana is entered.\n";break;
                                }
				return retmessage;
			}
		}
	}
	setError(targetobj,"OFF");
	return "";
}
//********************************************************************/
//全角角カナチェック
function check_ZKana(targetobj,NullFlg,targetName,minlength,maxlength) {
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^ァ-ヶ０-９Ａ-Ｚａ-ｚー　（）]+/ )){
                switch(locale){
                case "ja":
                    retmessage = targetName + "に全角カナ以外の文字が入力されています。\n";break;
                case "en":
                    retmessage = targetName + " other than full-width kana is entered.\n";break;
                }
		setError(targetobj,"ON");
    }else if(minlength!=="" || maxlength!=="" ){
        var min = minlength - 0;
        var max = maxlength - 0;
        if(min === max && min > 0 && targetobj.value.length !==min){
			switch(locale){
			case "ja": retmessage = targetName + "は" + min + "文字を入力してください。\n";break;
			case "en": retmessage = "Please enter " + min + " characters for " + targetName + ".\n";break;
			}
			setError(targetobj,"ON");
        }else if(targetobj.value.length < min && min > 0 && NullFlg!=1 && targetobj.value.length>0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + min + "文字以上を入力してください。\n";break;
            case "en": retmessage = "Please enter more than " + min + " characters for " + targetName + ". \n";break;
            }
            setError(targetobj,"ON");
        }else if(targetobj.value.length > max && max > 0){
            switch(locale){
            case "ja": retmessage = targetName + "は" + max + "文字以下を入力してください。\n";break;
            case "en": retmessage = "Please enter a " + targetName + " of " + max + " or less.\n";break;
            }
            setError(targetobj,"ON");
        }
    }
    if(retmessage===""){setError(targetobj,"OFF");}
    return retmessage;
}

//********************************************************************/
//URLチェック
function check_URL(targetobj,NullFlg,targetName) {
	var retmessage="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を入力してください。\n";break;
                        case "en":
                            retmessage = "Please enter " + targetName + ".\n";break;
                        }
			return retmessage;
		}
	}
	if(targetobj.value.match( /[^-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+/ )){
                switch(locale){
                case "ja":
                    retmessage = targetName + "にURLに使用できる文字以外の文字が入力されています。\n";break;
                case "en":
                    retmessage = "Characters other than those that can be used in URL are entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmessage==""){
		setError(targetobj,"OFF");
	}
	return retmessage;
}
//********************************************************************/
//テキストエリアチェック
//	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//	NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//	targetName:項目名
//	len:最大バイト長
//OUTPUT:エラーメッセージ
function check_TxtArea(targetobj,NullFlg,targetName,len){
	var retmessage="";
	var i;
	//まずは入力文字チェック
	retmessage = check_Txt(targetobj,NullFlg,targetName);

	//入力バイト長チェック
	if (len > 0) {	//最大長が未設定の場合はチェック対象外
		var text = targetobj.value;
		var count = 0;
		for (i=0; i<text.length; i++)
		{
			var n = escape(text.charAt(i));
			if (n.length < 4) count++; else count+=2;
		}
		if (count > len) {
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "の入力が長すぎます。（最大 " + len + "バイト、入力 " + count + "バイト）\n";break;
                        case "en":
                            retmessage = "The input for " + targetName + " is too long.(Maximum "+ len + " bytes, input "+ count +" bytes)\n";break;
                        }
		} else {
			retmessage = retmessage + "";
		}
	}

	//チェック結果の反映
	if (retmessage == "") {
		setError(targetobj,"OFF");
		return retmessage;
	} else {
		setError(targetobj,"ON");
		return retmessage;
	}
}
//チェックボックスのチェック
//	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//	NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//	targetName:項目名
//OUTPUT:エラーメッセージ
function check_Checkbox(targetobj,NullFlg,targetName){
        var retmessage = "";
	if(NullFlg==1 && null_NG_Flg){
		var count=0;
		var i;
		if(targetobj.length){
			for(i=0;i<targetobj.length;i++){
				if(targetobj[i].checked){
					count++;
				}
			}
		}else{
			if(targetobj.checked){count++;}
		}
		if(count==0){
        		if(targetobj.length){
                            for(i=0;i<targetobj.length;i++){
                                    setError(targetobj[i],"ON");
                            }
                            switch(locale){
                            case "ja":
                                retmessage = targetName + "を一つ以上選択してください。\n";break;
                            case "en":
                                retmessage = "Please select one or more " + targetName + ".\n";break;
                            }
                            return retmessage;
                        }else{
                            setError(targetobj,"ON");
                             switch(locale){
                            case "ja":
                                retmessage = targetName + "をチェックしてください。\n";break;
                            case "en":
                                retmessage = "Check " + targetName + ".\n";break;
                            }
                           return retmessage;
                        }
		}else{
        		if(targetobj.length){
                            for(i=0;i<targetobj.length;i++){
                                    setError(targetobj[i],"OFF");
                            }
                        }else{
                                    setError(targetobj,"OFF");
                        }
			return "";
		}
	}else{
		return "";
	}
}
//ラジオボタンのチェック
//	targetobj:対象のInputオブジェクト(EX:document.myform.data)
//	NullFlg:Nullチェックフラグ(0=チェックしない,1=チェックする)
//	targetName:項目名
//OUTPUT:エラーメッセージ
function check_Checkradio(targetobj,NullFlg,targetName){
	if(NullFlg==1 && null_NG_Flg){
		var count=0;
		var i;
		if(targetobj.length){
			for(i=0;i<targetobj.length;i++){
				if(targetobj[i].checked){
					count++;
				}
			}
		}else{
			if(targetobj.type=="radio"){
				if(targetobj.checked){count++;}
			}else{
				if(targetobj.value.length>0){count++;}
			}
		}
		if(count==0){
			if(targetobj.length){
				for(i=0;i<targetobj.length;i++){
					setError(targetobj[i],"ON");
				}
			}else{
				setError(targetobj,"ON");
			}
                        switch(locale){
                        case "ja":
                            retmessage = targetName + "を一つ以上選択してください。\n";break;
                        case "en":
                            retmessage = "Please select one or more " + targetName + ".\n";break;
                        }
                        return retmessage;
		}else{
			if(targetobj.length){
				for(i=0;i<targetobj.length;i++){
					setError(targetobj[i],"OFF");
				}
			}else{
				setError(targetobj,"OFF");
			}
			return "";
		}
	}else{
		return "";
	}
}
//アップロード可能拡張子の制御
function check_Extension(obj){
	if (obj == undefined || obj == null || obj.value.length == 0) {
		return true;
	} else {
		//アップロード可能拡張子
		var target_ext = new Array("jpg","jpeg","png","gif");

		var fileTypes = new Array();
		fileTypes = obj.value.split(".");
		var fileType = fileTypes[fileTypes.length - 1].toLowerCase();
		var ret = false;
		for (i=0; i<target_ext.length; i++) {
			if (fileType == target_ext[i]) {
				ret = true;
			}
		}
		if (ret == false) {
                        var msg = "";
                        switch(locale){
                        case "ja":
                            alertmsg = "アップロードできるファイル形式は" + target_ext.join(", ") + " のみです。";break;
                        case "en":
                            alertmsg = "The only file format that can be uploaded is " + target_ext.join(", ");break;
                        }
			alert(alertmsg);
			//input type=file の value は操作出来ないので工夫
			document.getElementById(obj.name+"_innerHTML").innerHTML = document.getElementById(obj.name+"_innerHTML").innerHTML;
		}
                return ret;
	}
}
//********************************************************************
//セレクトリストチェック
function check_Select_List(targetobj,NullFlg,targetName) {
    if(targetobj){
	var retmsg="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==''){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を選択してください。\n";break;
                        case "en":
                            retmsg = "Please select " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
    }else{ return "";}
}
//全角角カナチェック
function check_Zen_Kana(targetobj,NullFlg,targetName) {
	var retmsg="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}
	if (!targetobj.value.match(/^[ァ-ヶ　 ]*$/)){
                switch(locale){
                case "ja":
                    retmsg = targetName + "に全角カナ以外が入力されています。\n";break;
                case "en":
                    retmsg = targetName + " other than double-byte kana is entered.\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}
//********************************************************************
//半角カナ
function check_Han_Kana(targetobj,NullFlg,targetName) {
	var retmsg="";
	if(NullFlg==1 && null_NG_Flg){
		if(targetobj.value==""){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}
	if (!targetobj.value.match(/^[ｱ-ﾝｧ-ｮｯｰﾟﾞ･ ()0-9A-Za-z-_.\[\]]*$/)){
                switch(locale){
                case "ja":
                    retmsg = targetName + "に半角ｶﾅ以外が入力されています。\n";break;
                case "en":
                    retmsg = "A value other than half-width k is entered in " + targetName + ".\n";break;
                }
		setError(targetobj,"ON");
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}

//********************************************************************
//郵便番号チェック
function check_Zip(targetobj,NullFlg,targetName) {
	var retmsg="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}else{
		if (!targetobj.value.match(/\d{3}-\d{4}/)){
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "の形式が指定の形式（999-9999）と異なります。\n";break;
                        case "en":
                            retmsg = "The format of " + targetName + " is different from the specified format (999-9999).\n";break;
                        }
			setError(targetobj,"ON");
		}
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}
//********************************************************************
//電話番号チェック
function check_Phon(targetobj,NullFlg,targetName) {
	var retmsg="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}else{
		if (!targetobj.value.match(/\d{2,5}-\d{1,4}-\d{4}/)){
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "の形式が指定の形式（999-9999-9999等）と異なります。\n";break;
                        case "en":
                            retmsg = "The format of " + targetName + " is different from the specified format (999-9999).\n";break;
                        }
			setError(targetobj,"ON");
		}
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}
//********************************************************************
//固定電話番号チェック
function check_Phon_Fixed(targetobj,NullFlg,targetName) {
	var retmsg="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}else{
		if (!targetobj.value.match(/\d{3}-\d{3}-\d{4}/)
                        && !targetobj.value.match(/\d{2}-\d{4}-\d{4}/)){
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "の形式が固定電話の形式（99-9999-9999又は999-999-9999）と異なります。\n";break;
                        case "en":
                            retmsg = "The " + targetName + " format is different from the fixed telephone format (99-9999-9999 or 999-999-9999).\n";break;
                        }
			setError(targetobj,"ON");
		}
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}
//********************************************************************
//メールアドレスチェック
function check_Mail(targetobj,NullFlg,targetName,minlength,maxlength) {
    var retmsg="";
    if(targetobj.value==""){
        if(NullFlg==1 && null_NG_Flg){
            setError(targetobj,"ON");
            switch(locale){
            case "ja": retmsg = targetName + "を入力してください。\n";break;
            case "en": retmsg = "Please enter " + targetName + ".\n";break;
            }
            return retmsg;
        }
    }
    if (targetobj.value!="" && !targetobj.value.match(/^[a-zA-Z0-9@\._\-]+$/)){
        switch(locale){
        case "ja": retmsg = targetName + "にメールアドレスで使用できない文字が含まれています。\n";break;
        case "en": retmsg = targetName + " contains characters that cannot be used in email addresses.\n";break;
        }
        setError(targetobj,"ON");
    }else if(minlength!=="" || maxlength!=="" ){
        var min = minlength - 0;
        var max = maxlength - 0;
        if(min === max && min > 0 && targetobj.value.length !==min){
			switch(locale){
			case "ja": retmsg = targetName + "は" + min + "文字を入力してください。\n";break;
			case "en": retmsg = "Please enter " + min + " characters for " + targetName + ".\n";break;
			}
			setError(targetobj,"ON");
        }else if(targetobj.value.length < min && min > 0 && NullFlg!=1 && targetobj.value.length>0){
            switch(locale){
            case "ja": retmsg = targetName + "は" + min + "文字以上を入力してください。\n";break;
            case "en": retmsg = "Please enter more than " + min + " characters for " + targetName + ". \n";break;
            }
            setError(targetobj,"ON");
        }else if(targetobj.value.length > max && max > 0){
            switch(locale){
            case "ja": retmsg = targetName + "は" + max + "文字以下を入力してください。\n";break;
            case "en": retmsg = "Please enter a " + targetName + " of " + max + " or less.\n";break;
            }
            setError(targetobj,"ON");
        }
    }
    if(retmsg===""){setError(targetobj,"OFF");}
    return retmsg;
}
//********************************************************************
//ファイルチェック
function check_file(targetobj,NullFlg,targetName,ext) {
	var retmsg="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
			var delck = targetobj.form.elements[targetobj.name.match(/\[(.*)\]/)[1]  + "_delck"];
			if(delck){
				if(delck.checked == false){return retmsg;}	//削除チェックボックスがある（データ有）でチェックが無い場合OK
			}
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}else if(ext != ""){
		strExt=getExtention(targetobj.value);
		var extlist = ext.toUpperCase().split(",");
		//if(!extlist.includes(strExt.toUpperCase())){
		if(extlist.indexOf(strExt.toUpperCase())<0){
                        switch(locale){
                        case "ja":
                            retmsg = targetName+"は拡張子「"+ext+"」のファイルを指定してください。\n";break;
                        case "en":
                            retmsg = "For " + targetName + ", specify a file with the extension '" + "'.\n";break;
                        }
			setError(targetobj,"ON");
		}
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}

//ファイルチェック（multiple対応
function check_files(targetNodeList,NullFlg,targetName,ext) {
	var retmsg="";
	let targetobj = null
	if(targetNodeList instanceof RadioNodeList){
		targetobj = targetNodeList[1]
	}else if(targetNodeList.tagName=='INPUT'){
		targetobj = targetNodeList
	}
	if(targetobj.files.length==0){
		if(NullFlg==1 && null_NG_Flg){
			var delck = targetobj.form.elements[targetobj.name.match(/\[(.*)\]/)[1]  + "_delck"];
			if(delck){
				if(delck.checked == false){return retmsg;}	//削除チェックボックスがある（データ有）でチェックが無い場合OK
			}
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}else if(ext != ""){
		var extlist = ext.toUpperCase().split(",");
		//== ファイルループ　拡張子チェック
		for(let f of targetobj.files){
			strExt=getExtention(f.name)			
			if(extlist.indexOf(strExt.toUpperCase())<0){
				switch(locale){
					case "ja":
						retmsg = targetName+"は拡張子「"+ext+"」のファイルを指定してください。\n";break;
					case "en":
						retmsg = "For " + targetName + ", specify a file with the extension '" + "'.\n";break;
				}
				setError(targetobj,"ON");
			}
		}
		//==
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}


//********************************************************************
//時間期間チェック
function check_TimeTerm(targetobj,NullFlg,targetName) {
	var retmsg="";
	if(targetobj.value==""){
		if(NullFlg==1 && null_NG_Flg){
			setError(targetobj,"ON");
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "を入力してください。\n";break;
                        case "en":
                            retmsg = "Please enter " + targetName + ".\n";break;
                        }
			return retmsg;
		}
	}else{
		if (!targetobj.value.match(/\d{2}:\d{2}-\d{2}:\d{2}/)){
                        switch(locale){
                        case "ja":
                            retmsg = targetName + "の形式が指定の形式（hh:mm-hh:mm）と異なります。\n";break;
                        case "en":
                            retmsg = targetName + " format is different from the specified format (hh: mm-hh: mm).\n";break;
                        }
			setError(targetobj,"ON");
		}
	}
	if(retmsg==""){
		setError(targetobj,"OFF");
	}
	return retmsg;
}
//********************************************************************
//一致チェック
function check_same(targetobj1,targetName1,targetobj2,targetName2){
    var retmsg = "";
    if(targetobj1.value!=targetobj2.value){
        switch(locale){
        case "ja":
            retmsg = targetName1 + "が" + targetName2 + "と一致しません。\n";break;
        case "en":
            retmsg = targetName1 + " and " + targetName2 + " do not match.\n";break;
        }
        setError(targetobj1,"ON");
        setError(targetobj2,"ON");
    }
    return retmsg;
}
