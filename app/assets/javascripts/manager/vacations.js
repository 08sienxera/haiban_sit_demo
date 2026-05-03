/* ************************************************************************* */
/* 休暇カレンダー用JS */
/* ************************************************************************* */
var subKeys = Array('hcalTitle','hcalData','hcalSum');
var popBoxRootObj;
//OnLoadイベント
$(function(){
    setHColDataCellSize();
    setHColSize();
    $(window).resize(function(){setHColSize();});
    $(window).on('orientationchange', function(e) {setHColSize();});
    for(var branche_cd in branches){
        if(def_branch_cd != branche_cd){
            hcaltableOpenBranche(branche_cd);
        }
    }
    //行のマウスオーバー
    $('div[id^="user_Group_"]').hover(
        function (){ // 要素にマウスを載せたときの処理
            $('div[id="'+$(this).attr("id")+'"]').css("background-color","yellow");
        },
        function () {// 要素からマウスをはなした
            $('div[id="'+$(this).attr("id")+'"]').css("background-color","")
        }
    );
    if(is_futurity){  //公休日設定チェック
      ckAllVacations();
    }
});
//画面表示制御
function setHColSize(){
    //console.log("setHColSize");
    var tmpW,tb2W;
    if($("#hcalTbl").length){
        var tblW = $("#hcalTbl").width();
        $("#hcalTbl").css("margin","0 auto");
        //横幅設定
        tmpW = Math.max($('#hcalTitle1 > .hcaltable > .hcalRow').width(),$('#hcalData1 > .hcaltable > .hcalRow').width(),$('#hcalSum1 > .hcaltable > .hcalRow').width());
        for(var wj=0;wj<subKeys.length;wj++){
            $('#'+subKeys[wj]+'1').css("width",tmpW+"px");
            $('#'+subKeys[wj]+'1 > .hcaltable').css("width",tmpW+"px");
        }
        tb2W = tblW - tmpW;
        tmpW = Math.max($('#hcalTitle3 > .hcaltable > .hcalRow').width(),$('#hcalData3 > .hcaltable > .hcalRow').width(),$('#hcalSum3 > .hcaltable > .hcalRow').width());
        for(var wj=0;wj<subKeys.length;wj++){
            $('#'+subKeys[wj]+'3').css("width",(tmpW+2)+"px");
            $('#'+subKeys[wj]+'3 > .hcaltable').css("width",tmpW+"px");
        }
        tb2W = tb2W - tmpW;
        if(tb2W < $('#hcalTitle2 > .hcaltable > .hcalRow').width()){
            for(var wj=0;wj<subKeys.length;wj++){
                if(wj == 1){
                    $('#'+subKeys[wj]+'1').css("overflow-x","hidden");
                    $('#'+subKeys[wj]+'2').css("overflow-x","scroll");
                    $('#'+subKeys[wj]+'3').css("overflow-x","hidden");
                }else{$('#'+subKeys[wj]+'2').css("overflow-x","hidden");}
                $('#'+subKeys[wj]+'2').css("width",tb2W+"px");
            }
        }
        //縦幅設定
        tblH=500;
        tmpH = 0;
        for(var wj=0;wj<subKeys.length;wj++){
            tmpH += $('#'+subKeys[wj]+'1').height();
        }
        if(tmpH > tblH){
            for(var wj=1;wj<4;wj++){
                $('#'+subKeys[1]+wj+'').css("height",tblH+"px");
                if(wj == 2){$('#'+subKeys[1]+wj+'').css("overflow-y","scroll");}
                else{$('#'+subKeys[1]+wj+'').css("overflow-y","hidden");}
            }
        }
    }
}
//データセルのサイズ調整
function setHColDataCellSize(){
    if($('#hcalTbl').length){
        //データセル設定
        tmpW=0;tmpH=0;
        for(var wj=0;wj<subKeys.length;wj++){
            $('#'+subKeys[wj]+'2 > .hcaltable > .hcalRow > .hcalVCell').each(function(){
                tmpW = Math.max(tmpW,$(this).width());
                tmpH = Math.max(tmpH,$(this).height());
            });
        }
        cellCount = $('#'+subKeys[0]+'2 > .hcaltable > .hcalRow:first > .hcalVCell').length+10;
        for(var wj=0;wj<subKeys.length;wj++){
            $('#'+subKeys[wj]+'2 > .hcaltable').width(tmpW*cellCount);
            $('#'+subKeys[wj]+'2 > .hcaltable > .hcalRow > .hcalVCell').width(tmpW);
            $('#'+subKeys[wj]+'3 > .hcaltable').width(tmpW*3);
            $('#'+subKeys[wj]+'3 > .hcaltable > .hcalRow > .hcalVCell').width(tmpW);

        }
        for(var wj=1;wj<4;wj++){
            $('#'+subKeys[1]+wj+' > .hcaltable > .hcalRow > .hcalVCell:first').css("height",tmpH+"px");
        }
    }
}
//データ部位スクロール時
function doHcalScroll(robj){
    $('#'+robj.id.replace("2","1")).scrollTop(robj.scrollTop);
    $('#'+robj.id.replace("2","3")).scrollTop(robj.scrollTop);
    $('#'+robj.id.replace("Data","Title")).scrollLeft(robj.scrollLeft);
    $('#'+robj.id.replace("Data","Sum")).scrollLeft(robj.scrollLeft);
    var popBox = $('#hcalInfoBox');
    if(popBox.length && popBox.css("display")=="block"){
      popVacationInfo(popBoxRootObj,'',popBox.text());
    }
    //popBox.css("top",popBox.css("top")-robj.scrollTop);
    $("div[id^='ErrorMsgBox']:visible").each(function(){
        var robj = document.getElementById("ErrorMsgBtn"+$(this).attr("id").replace("ErrorMsgBox",""));
        var oTop = offsetTop(robj)-30-$("#hcalData1").scrollTop();
        if(oTop < 30 || oTop > window.innerHeight){
            $(this).css("display","none");
        }else{
            $(this).css("top",oTop+"px");
        }
    });
}



function popVacationInfo(robj,vText){
    if(vText != ""){
        var tblObj = robj.parentNode.parentNode.parentNode;
        var oTop = offsetTop(robj)-30-tblObj.scrollTop;
        var oLeft = offsetLeft(robj)+35-tblObj.scrollLeft;
        // console.log(oTop+':'+oLeft);
        var popBox = document.getElementById('hcalInfoBox');
        if(!popBox){
            popBox =document.createElement('div');
            popBox.id = 'hcalInfoBox';
            popBox.className = 'hcalInfoBox';
            popBox.addEventListener('click',function(){$('#hcalInfoBox').css('display','none')});
            document.getElementById('hcalBox').appendChild(popBox);
        }
        popBox.style.top=oTop+'px';
        popBox.style.left=oLeft+'px';
        popBox.style.display='block';
        popBox.innerHTML = vText;
        popBoxRootObj = robj;
    }
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
//明細表示制御
function hcaltableOpenBranche(branch_cd){
    var link_obj = $("#BrancheSumRow_"+branch_cd+" > a");
    if(link_obj.length){
        if(link_obj.text()=="▼"){
            $("div.branchGroup_"+branch_cd).css("display","none");
            link_obj.text("▲");
        }else{
            $("div.branchGroup_"+branch_cd).css("display","table-row");
            link_obj.text("▼");
        }
    }
}

//操作権限チェック
function hasPermission(branch_cd){
  return AllowedBrancheList.includes(String(branch_cd));
}

//申請・承認へ
function goVacationsEdit(user_id,login_id,t_date,closed=true){
  const fobj = document.newform;
  const evt = event;
  const goToEdit = (user_id,t_date)=>{location.href=getUrl("vacations")+"/vacations/"+user_id+"/edit?t_date="+t_date;return;}

  // 公休出勤
  const hcell = document.getElementById("vc_cell_" + login_id + "_" + t_date).parentElement;
  const hwork = hcell.classList.contains("hcalAlertCell");

  if(closed || hwork || isShiftEvent(evt)){//〆後またはシフト同時押し->休暇代行登録画面
    goToEdit(user_id,t_date);
  }else{
    const wh_flg = $("#wh_flg"+t_date).val();
    const base_no = $("#base_no_"+login_id+"_"+t_date).val();

    // 公休以外の登録がある場合、編集画面へ
    if(!(base_no=="0"||base_no=="6")) goToEdit(user_id,t_date);

    fobj.mord.value = "onoff6";
    fobj.user_id.value=user_id;
    fobj.t_date.value=t_date;
    $.ajax({url: fobj.action,type: fobj.method,data: $(fobj).serialize(),cache: false,dataType: 'json',
    }).done(function(data) {
      switch(data["sts"]){
        case "create" : 
          $("#base_no_"+data["login_id"]+"_"+data["vacation_day"]).val("6");
          $("#vc_cell_"+data["login_id"]+"_"+data["vacation_day"]).html("公");
          break;
        case "delete" :
          $("#base_no_"+data["login_id"]+"_"+data["vacation_day"]).val("0");
          $("#vc_cell_"+data["login_id"]+"_"+data["vacation_day"]).html("　");
          break;
        default: 
          alert('公休日設定エラー');
          return false;
      }
      ckAllVacations(data["login_id"]);  //再計算＆再チェック
    }).fail(function() {alert('公休日設定エラー');
    }).always(function() {});
  }
}

function confirmExecute(msg){
  return confirm(msg);
}


//公休設定(初期)または公休日自動割当
function setVacation(mord){
  var fobj = document.newform;
  if(fobj){
    $("html").css("cursor","wait");
    var msg="";
    switch(mord){
    case "init6" : msg="公休日の初期設定を行います。";break;
    case "add6" : msg="不足公休日の自動割り当てを行います。";break;
    }
    $("#msgBox").text(msg).css("display","block");
    fobj.mord.value = mord;
    $.ajax({url: fobj.action,type: fobj.method,data: $(fobj).serialize(),cache: false,dataType: 'json',
    }).done(function(data) {
       $("#msgBox").html(data["msg"]);
       if(data["sts"]==303){setTimeout(function(){ckJob();},5000);}
       else{
           $("html").css("cursor","auto");
           msg = data["msg"];
           msg += "<br /><br /><br /><input type='button' value='閉じる' onclick='$(\"#msgBox\").css(\"display\",\"none\");' />";
           $("#msgBox").html(msg);
       }
    }).fail(function() {$("html").css("cursor","auto");alert('実行エラー');
    }).always(function() {});
  }else{
    alert("配番作業員の登録がありません。")
  }
}
//Jobの実行チェック
function ckJob(){
  var fobj = document.newform;
  var url = getUrl("vacations")+"/delayed_jobs/";
  url+="vacations"+fobj.mord.value+fobj.t_year.value+fobj.t_month.value;
    $.ajax({
        url: url,
        type: 'get',
        cache: false,
        dataType: 'json',
    }).done(function(data) {
       $("#msgBox").html(data["msg"]);
       switch(data["sts"]){
       case 404 : location.reload();break;
       case 303 : setTimeout(function(){ckJob();},3000);break;
       default:
           msg = data["msg"];
           msg += "<br /><br /><br /><input type='button' value='閉じる' onclick='$(\"#msgBox\").css(\"display\",\"none\");' />";
           $("#msgBox").html(msg);
       }
    }).fail(function() {alert('実行エラー');
    }).always(function() {});

}
//公休日設定チェック & 集計
function ckAllVacations(vlogin_id){
  var dates = [];
  var wh_flg = {};
  var sumh = {};var sumw = {};
  var gsumh = {};var gsumw = {};
  var tymd;
  //集計の初期化
  for(branch_cd in branches){
    gsumh[branch_cd]={};gsumw[branch_cd]={};
  }
  $("input:hidden[id^='wh_flg_']").each(function(){
    tymd = $(this).attr("id").replace(/^wh_flg_/,"");
    dates.push(tymd);
    wh_flg[tymd] = $(this).val();
    sumh[tymd] = 0;sumw[tymd] = 0;
    for(branch_cd in branches){
      gsumh[branch_cd][tymd] = 0;gsumw[branch_cd][tymd] = 0
    }
  });
  dates.sort();
  $("#hcalData2 > .hcaltable > .hcalRow[id^='user_Group_']").each(function(){
    var login_id=$(this).attr("id").replace(/^user_Group_/,"");
    var branch_cd = $(this).attr("class").replace(/^hcalRow branchGroup_/,"");
    var myhsum = 0; //公休取得日数
    var myahsum = 0; //法定休日以外の公休取得日数
    var continuous = $("#lastmonth_continuous_"+login_id).val()-0;  //連勤回数（初期値は前月までの連勤数
    var maxContinuous = continuous;  //最大連勤回数
    var myhdata = {}
    //連休数（法定休日と指定公休の連続は最大２、指定公休の連続はNG）
    var errMsgs=[];  //エラーメッセージ
    $(this).find("input:hidden[id^='base_no_"+login_id+"']").each(function(){
      tymd = $(this).attr("id").replace("base_no_"+login_id+"_","");
      myhdata[tymd] = $(this).val();
      switch($(this).val()){
      case "0" : 
      case "2" : 
      case "3" : 
      case "31" : 
      case "32" : 
      case "33" : 
      case "34" : 
      case "41" : 
      case "42" : 
        sumw[tymd]++;gsumw[branch_cd][tymd]++;continuous++;
        if(continuous > OverWorkLimit){
          errMsgs.push(tymd.substr(-4,2)+"月"+tymd.substr(-2,2)+"日から連勤数が"+OverWorkLimit+"日を超過しています。");
          $(this).parent("div").addClass("hcalErrCell");
        }else{
          $(this).parent("div").removeClass("hcalErrCell");
        }
        break;
      case "6" : 
        myhsum++;
        if(wh_flg[tymd]!="1"){myahsum++;}

        const sts = $("#" + $(this).attr("id").replace("base_no","sts"));
        if(sts && (sts.val()==4 || sts.val()==5)){
          sumw[tymd]++; gsumw[branch_cd][tymd]++;
          continuous++;
          if(continuous > OverWorkLimit){
            errMsgs.push(tymd.substr(-4,2)+"月"+tymd.substr(-2,2)+"日から連勤数が"+OverWorkLimit+"日を超過しています。");
            $(this).parent("div").addClass("hcalErrCell");
          }else{
            $(this).parent("div").removeClass("hcalErrCell");
          }
        }else{
          sumh[tymd]++;gsumh[branch_cd][tymd]++;
          if(maxContinuous<continuous){maxContinuous=continuous;}
          continuous=0;
          $(this).parent("div").removeClass("hcalErrCell");
        }
        break;
      default :
        if($(this).val()=="7"){
          myhsum++;
          myahsum++;
        };
        // if($(this).val()=="7" || $(this).val()=="17") myhsum++;
        sumh[tymd]++;gsumh[branch_cd][tymd]++;
        if(maxContinuous<continuous){maxContinuous=continuous;}
        continuous=0;
        $(this).parent("div").removeClass("hcalErrCell");
      }
    });
    if(maxContinuous<continuous){maxContinuous=continuous;}
    //集計値を反映
    $("#mysumh_"+login_id).text(myhsum);
    $("#maxcontinuous_"+login_id).text(maxContinuous);
    //公休日設定数チェック
    if(myahsum<h_setting_min){
      errMsgs.push("法定休日以外の公休日設定数が不足しています。");
    }
    //公休日の設定チェック
    //法定公休日との連休数（２日）
    hcontinuous = [];
    hwday_count = {0:[], 1:[], 2:[], 3:[], 4:[], 5:[], 6:[]}
    for(var wi=0;wi<dates.length;wi++){
      tymd = dates[wi];
      nymd = dates[wi+1];
      yymd = dates[wi-1];

      if(myhdata[tymd]=="6" && wh_flg[tymd]!="1"){
        wday = parseYyyymmdd(tymd).getDay();
        hwday_count[wday].push(tymd);
        constraint = constraint_check_data[login_id]
        if(constraint){
          sandwich = constraint[tymd];
          if(sandwich){
            errMsgs.push(tymd.substr(-4,2)+"月"+tymd.substr(-2,2)+"日と"+sandwich.substr(-4,2)+"月"+sandwich.substr(-2,2)+"日の公休日が連続しています。");
            $("#base_no_"+login_id+"_"+tymd).parent("div").addClass("hcalErrCell");
          }
          
        }
        if(constraint_check_data["continuous_date"].includes(tymd)){
          hcontinuous.push(tymd);
        }

        if(myhdata[nymd]=="6"){
          if(wh_flg[nymd]!="1"){
            errMsgs.push(tymd.substr(-4,2)+"月"+tymd.substr(-2,2)+"日と"+nymd.substr(-4,2)+"月"+nymd.substr(-2,2)+"日の公休日が連続しています。");
            $("#base_no_"+login_id+"_"+tymd).parent("div").addClass("hcalErrCell");
            $("#base_no_"+login_id+"_"+nymd).parent("div").addClass("hcalErrCell");
          }else{
            hcontinuous.push(tymd);
            var wj=wi+2;
            while(myhdata[dates[wj]]=="6"){
              if(wh_flg[dates[wj]]!="1"){
                errMsgs.push(tymd.substr(-4,2)+"月"+tymd.substr(-2,2)+"日と"+dates[wj].substr(-4,2)+"月"+dates[wj].substr(-2,2)+"日の公休日が連続しています。");
                $("#base_no_"+login_id+"_"+tymd).parent("div").addClass("hcalErrCell");
                $("#base_no_"+login_id+"_"+dates[wj]).parent("div").addClass("hcalErrCell");
              }
              wj++;
            }
          }
        }else if(myhdata[yymd]=="6" && wh_flg[yymd]=="1"){
          hcontinuous.push(tymd);
        }
      }
      if(myhdata[tymd]=="7"){ // 法定休日に連続する公休としてカウント
        if((myhdata[nymd]=="6" && wh_flg[nymd]=="1") || (myhdata[yymd]=="6" && wh_flg[yymd]=="1")){
          hcontinuous.push(tymd);
        }
      }
    }

    // 日曜連動日数のと月曜日・土曜日公休のカウントチェック
    if(false){
      [[1,"月曜日"],[6,"土曜日"]].forEach(([wday,wdaystr])=>{
        if(hwday_count[wday].length>1){
          errMsgs.push(`${wdaystr}の公休日数が超過しています。`);
          $.each(hwday_count[wday],function(index,tymd){
            $("#base_no_"+login_id+"_"+tymd).parent("div").addClass("hcalErrCell");
          });
        }else if(hwday_count[wday].length==0){
          errMsgs.push(`${wdaystr}の公休日が登録されていません。`);
        }
      })
    }

    hcontinuous = [...new Set(hcontinuous)] // 重複排除
    if(hcontinuous.length < 2){
      errMsgs.push("法定休日との連休が不足しています。");
    }else if(hcontinuous.length > 2){
      errMsgs.push("法定休日との連休が超過しています。");
      $.each(hcontinuous,function(index,tymd){
        $("#base_no_"+login_id+"_"+tymd).parent("div").addClass("hcalErrCell");
      });
    }
    //メッセージSET
    var ErrorMsgBox = $("#ErrorMsgBox"+login_id);
    ErrorMsgBox.html(errMsgs.join("<br />"));
    if(ErrorMsgBox.text()==""){
      $("#ErrorMsgBtn"+login_id).css("display","none");
      ErrorMsgBox.css("display","none");
    }else{
      $("#ErrorMsgBtn"+login_id).css("display","");
      if(vlogin_id==login_id){vacErrorMsgView(login_id,"block");}
    }
  });

  
  //集計値を反映
  for(tymd in wh_flg){
    $("#sumh_"+tymd).text(sumh[tymd]);
    $("#sumw_"+tymd).text(sumw[tymd]);
    for(branch_cd in branches){
      $("#gsumh_"+branch_cd+"_"+tymd).text(gsumh[branch_cd][tymd]);
      $("#gsumw_"+branch_cd+"_"+tymd).text(gsumw[branch_cd][tymd]);
    }
  }
}
//エラーメッセージ表示
function vacErrorMsgView(login_id,display){
    var robj = document.getElementById("ErrorMsgBtn"+login_id);
    var oTop = offsetTop(robj)-30-$("#hcalData1").scrollTop();
    var oLeft = offsetLeft(robj)+10;
    $("#ErrorMsgBox"+login_id).css("top",oTop+"px").css("left",oLeft+"px").css("display",display);
}

//「yyyymmdd」形式の引数を受け取り、Date型を返す
function parseYyyymmdd(dateString) {
  const year = parseInt(dateString.substring(0, 4), 10);
  const month = parseInt(dateString.substring(4, 6), 10) - 1; // JavaScriptのDateは0が1月
  const day = parseInt(dateString.substring(6, 8), 10);

  return new Date(year, month, day);
}

