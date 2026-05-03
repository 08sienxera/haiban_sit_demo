/* 荷役予定(必要人数設定)画面用JS */
var onInputRow = null;
var focusedInput = null;
$(function(){
  initTbl();
  calcCount();
  setSelectionChange();
});
//表示テーブルの横幅調整
function initTbl(){
  var CargosBodyBox = document.getElementById("CargosBodyBox");
  var scllolW = (CargosBodyBox.offsetWidth - CargosBodyBox.clientWidth);
  $("#CargosHeadAdjustCell,#CargosSumAdjustCell,#CargosWokerSumAdjustCell").width(scllolW);
  $("#CargosBodyBox").height($(window).innerHeight()-450);
  //ドラッグ＆ドロップの処理
  $("#CargosBodyTbl").sortable().bind("sortstop", function(){
    // $(this).find('input[type="hidden"][id$="_desp_index"]').each(function(index){
    //   $(this).val(index);
    // });
    renumber();
  });
}

//work_no,desp_index 再割当
function renumber(){
  // 変数
  const workNoList = [];
  let currentWorkNo = 1;

  // 関数
  const incrementWorkNo = ()=>currentWorkNo++;
  const getWorkClass = (moveNo)=>moveNo.match(/\d{8}/) ? "1" : "2"
  const getWorkNo = (moveNo)=>{
    const foundArr = workNoList.find(([,mno])=>mno==moveNo);
    return foundArr ? foundArr[0] : null;
  };

  let tableRows = document.querySelectorAll('#CargosBodyTbl>div[id^="row_"]');
  if(!tableRows) return;
  for(const [index,val] of Object.entries(tableRows)){

    const v_move_no = val.querySelector("[id^=\"v_move_no_\"]");
    const workClass = getWorkClass(v_move_no.innerText);
    const despIndex = index;
    let workNo = null;

    if(workClass=="1"){
      workNo = getWorkNo(v_move_no.innerText);
      if(workNo==null){
        workNo = incrementWorkNo();
        workNoList.push([workNo,v_move_no.innerText])
      }
    }else{
        workNo = incrementWorkNo();
        workNoList.push([workNo,v_move_no.innerText])
    }
    
    // ビューに反映
    const despIndexNode = val.querySelector('input[type="hidden"][id$="_desp_index"]');
    if(despIndexNode) despIndexNode.value = despIndex;

    const iNode = val.querySelector('div[id^="i_work_no_"]>input');
    if(iNode) iNode.value = workNo;

    const vNode = val.querySelector('div[id^="v_work_no_"]');
    if(vNode) vNode.innerText = workNo;
  }
}

//必要人数変更→再集計
function calcCount(robj){
  if(robj){
    var key = robj.id.replace(/^Cargo_in_\d+_/,"")
    if(!myICheck(key,robj)){
      return false;
    }
  }
  //集計
  var sum = {"dr":0,"wk":0}
  $.each(WokerNumKey,function(index,key){sum[key]=0;});
  $("#CargosBodyTbl div.hcalRow").each(function(){
    var rowObj = this; 
    var rowNo = rowObj.id.replace(/^row_/,"");
    var dr = 0;var wk = 0;
    $.each(WokerNumKey,function(index,key){
      count = $(rowObj).find('input[id$="_'+key+'"]:first').val()-0;
      if(isNaN(count) || count==0){
        $(rowObj).find('div[id^="v_'+key+'"]').text("");
      }else{
        $(rowObj).find('div[id^="v_'+key+'"]').text(count);
        sum[key] += count
        if(key.substr(-1,1)=="w"){wk+=count;}
        else{dr+=count;}
      }
      
    });
    //行毎の「運転」にFM～他の合計を反映
    $(this).find('div[id^="row_dr_sum_"]').text(dr);
    $(this).find('div[id^="row_wk_sum_"]').text(wk);
    sum["dr"]+=dr;sum["wk"]+=wk;
  });
  //本船・沿岸合計に反映
  for(key in sum){
    $("#CargosSumCell_"+key).text(sum[key]);
  }
  //対応可能者数と比較し、
  $("#CargosWokerSumTbl div.hcalVCell").each(function(){
    var id = $(this).attr("id");
    var woker = $(this).text() - 0;
    if(id && !isNaN(woker)){
      key = id.replace(/^CargosWokerSumCell_/,"");
      sum_count = 0;
      if(key in sum){sum_count+=sum[key];}
      if(key+"_m" in sum){sum_count+=sum[key+"_m"];}
      if(key+"_s" in sum){sum_count+=sum[key+"_s"];}
      if(key+"_w" in sum && key!="ot"){sum_count+=sum[key+"_w"];}
      if(woker<sum_count){
        $('div[id^="CargosSumCell_'+key+'"]').css("background-color","red");
      }else{
        $('div[id^="CargosSumCell_'+key+'"]').css("background-color","");
      }
    }
  });
}
//行クリック→入力モード
function setInput(rRow){
  if(focusedInput){
    setData(focusedInput);
  }
  if(onInputRow){
    $(onInputRow).find('div[id^="v_"]').css("display","");
    $(onInputRow).find('div[id^="i_"]').css("display","none");
    $(onInputRow).css("background-color","");
  }
  //入力を制御
  var cargo_request_id = $(rRow).find('input[id$="cargo_request_id"]').val();
  if(cargo_request_id=="" || cargo_request_id=="0"){  //沿岸作業
    $(rRow).find('a[id^="serch_btn_"]').css("display","inline-block");
  }else{                     //本船作業
    $(rRow).find('a[id^="serch_btn_"]').css("display","none");
    $(rRow).find('input[id$="move_no"]').attr("readonly",true).css("background-color","#DDDDDD");
    $(rRow).find('input[id$="work_cd"]').attr("readonly",true).css("background-color","#DDDDDD");
  }
  //内容をサブフォームに反映
  $('form[name="subinform"] select[id$="io_flg"]').val($(rRow).find('input[id$="io_flg"]').val());
  $.each(["note","quantity","matter1","matter2","momo_fm","momo_dm","momo_mc","momo_wi","momo_dr","momo_wk"],function(index,key){
    $('form[name="subinform"] input[id$="'+key+'"]').val($(rRow).find('input[id$="'+key+'"]').val()).css("background-color","");
  });
  $('form[name="subinform"] input[id$="dirt_flg"]').prop("checked",($(rRow).find('input[id$="dirt_flg"]').val()=="1"));
  $(rRow).find('div[id^="v_"]').css("display","none");
  $(rRow).find('div[id^="i_"]').css("display","");
  $(rRow).css("background-color","yellow");
  const doFocus = onInputRow != rRow;
  onInputRow = rRow;
  if(doFocus){
    $(rRow).find('input[id$="work_no"]').get(0).focus();
  }
}
//登録フォームで変更→表示に反映
function setVewData(robj){
  var key = robj.id.replace(/^Cargo_in_\d+_/,"")
  if(myICheck(key,robj)){
    $("#"+$(robj).parent().attr("id").replace(/^i/,"v")).text(robj.value);
  }
}
//サブフォームで変更→登録フォームに反映
function setData(robj){
  if(onInputRow){
    var key = robj.id.replace(/^Cargo_in_/,"")
    switch(robj.type){
    case "checkbox" :   $(onInputRow).find('input[id$="'+key+'"]').val((robj.checked ? "1" : "")); break;
    case "select-one" : $(onInputRow).find('input[id$="'+key+'"]').val(robj.value); break;
    default :
       if(myICheck(key,robj)){
         $(onInputRow).find('input[id$="'+key+'"]').val(robj.value);
       }
    }
    focusedInput = null;
  }
}
//行追加
function addRow(){
  var rowCountObj = $('input[name="row_count"]');
  var rowCount = rowCountObj.val()-0+1;
  var rowHTML = $("#CargosSmpleTbl").html()
  $("#CargosBodyTbl").append(rowHTML.replace(/_0/g,"_"+rowCount).replace("('0')","('"+rowCount+"')"));
  rowCountObj.val(rowCount);
  var work_no = 0;
  $('input[id$="_work_no"]').each(function(){
    var tmp = $(this).val() - 0
    if(!isNaN(tmp)){if(tmp>work_no){work_no=tmp;}}
  });
  $('input[id="Cargo_in_'+rowCount+'_work_no"]').val((work_no+1)).trigger("change");
  $('input[id="Cargo_in_'+rowCount+'_desp_index"]').val(rowCount);
  $('#row_'+rowCount).trigger("click");
  
  $('#CargosBodyBox').scrollTop($('#CargosBodyBox').get(0).scrollHeight);
}
//沿岸作業マスタ検索画面POPUP
function goSerchCargoMaster(rowNo){
  var url = getUrl("cargos")+"/cargo_masters/"+rowNo;
  popWin(url,"CargoMasterSerch",800,700);
}
//沿岸作業マスタ検索画面からの戻り→反映
function returnSerch(move_no,rowNo){
  $('input[id="Cargo_in_'+rowNo+'_move_no"]').val(move_no).trigger("change");
}
//動静番号変更→沿岸作業マスタのデータを反映
function loadCargoMaster(robj){
  var rowNo = robj.id.replace(/^Cargo_in_/,"").replace(/_move_no$/,"");
  var url = getUrl("cargos")+"/cargo_masters/"+robj.value+".json";
  $.ajax({
    url: url,
    type: "GET",
    data: "rtarget="+rowNo,
    cache: false,
    dataType: 'json',
  }).done(function(data) {
    if(data["sts"]==200){
      rowNo = data["rtarget"];
      $('input[id="Cargo_in_'+rowNo+'_work_name"]').val(data["work_name"]).trigger("change");
      $('input[id="Cargo_in_'+rowNo+'_work_place"]').val(data["work_place"]).trigger("change");
    }else{
      //alert("動静番号["+data["move_no"]+"]のマスタはありませんでした。");
    }
  }).fail(function() {
    alert('検索エラー');
  }).always(function() {
  });
}
//行削除
function deletRow(){
  if(onInputRow){
    var rowNo = $(onInputRow).find('input[id$="desp_index"]').val();
    var workNo = $(onInputRow).find('input[id$="work_no"]').val();
    var msg = rowNo+"行目(No."+workNo+")の荷役を削除します。\nよろしいですか？";
    if(confirm(msg)){
      $(onInputRow).remove();
      onInputRow=null;
      $(this).find('input[type="hidden"][id$="_desp_index"]').each(function(index){
        $(this).val(index);
      });
    }
  }else{
    alert("削除する荷役を選択してください。")
  }
}
//指定日沿岸作業コピー
function doCopy(btn){
  var max_desp_index=0;
  var max_work_no=0;
  var has_cargo = false;
  //指定日チェック
  var strErrorMassage = check_Day(btn.form.elements["Cargo_in[work_date]"],1,'コピー対象日');
  if(strErrorMassage==""){
    //沿岸作業有無、本船作業の最大値を取得
    $("#CargosBodyTbl div.hcalRow").each(function(){
      cargo_request_id = $(this).find('input[id$="_cargo_request_id"]').val();
      if(cargo_request_id=="" || cargo_request_id=="0"){    //沿岸作業
        has_cargo = true
      }else{
        tmp = $(this).find('input[id$="_desp_index"]').val() - 0; 
        if(!isNaN(tmp)){if(max_desp_index<tmp){max_desp_index=tmp;}}
        tmp = $(this).find('input[id$="_work_no"]').val() - 0; 
        if(!isNaN(tmp)){if(max_work_no<tmp){max_work_no=tmp;}}
      }
    });
    btn.form.max_desp_index.value = max_desp_index;
    btn.form.max_work_no.value = max_work_no;
    if(has_cargo){
      if(confirm("登録済みの沿岸作業は削除されます。\nコピー実施しますか？")){
        btn.form.do_reset.value = 1;
        btn.form.submit();
      }
    }else{
      btn.form.submit();
    }
  }else{btn.form.elements["Cargo_in[work_date]"].focus();alert(strErrorMassage);return false;}
}
//console.log(key);

function setSelectionChange(){
  $('form[name="subinform"] input,form[name="subinform"] select').on('selectionchange', function(){
    focusedInput = this;
  });
}

