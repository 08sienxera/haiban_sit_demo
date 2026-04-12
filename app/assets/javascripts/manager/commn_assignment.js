//定数
var boxKeys = ["r","m","l"];
var rowKeys = ["head","body","foot"];
var AssignmentBlocks = ["fm","dm","mc","wi","dr","wk"];
var def_font_size;
var font_size;
var def_tbl_setting;
var selectedPanel="";
var selectedAssignment="";
var selectedCol="";
var selectedRow="";
var unSetting=false;
var cpAria = {"tRow":"","tCol":""};
var subW; //沿岸(別面)ウィンドウ
var multiWindowMode = false;
var viewMord = 'wide';
var adjustmentHeight = 0;
var observer = null;
var obsWkASetWorker = null;
var obsWkASelectUser = null;
var obsWkASetMachine = null;
var obsWkASelectMachine = null;
var obsWkSetWorkerInfo = null;
var obsWkAUnSetAssignment = null;
var obsWkASetLock = null;
var obsWkACargoAddPanelRow = null;
var obsToggleRowDisplay = null;
var tmpWorkIndex = null;
var forceEventCancel = false
var tmpTargetId = [];

// コピペ関係
var obsWkASelectCol = null;
var obsWkASelectRow = null;
var obsWkAChangeAssignmentToPanel = null;
var obsWkAPasteAriaToPanel = null;

//作業日テーブルに文字サイズ大小ボタンを追加してレイアウト調整
//作業日テーブルに「表示最大化／通常表示」ボタンを追加してレイアウト調整
function WkAAddTDateTbl2Button(){
    var newElement;
    var tDateTbl = document.getElementById("tDateTbl");
    var tRow = tDateTbl.rows[0]
    tRow.cells[0].style.width="80%";
    var newCell = document.createElement('td');
    newCell.className = "listR";
    newCell.innerText="表示サイズ：";
    newCell.style.width="5%";
    tRow.appendChild(newCell);
    var newCell = document.createElement('td');
    newCell.className = "listC";
    newCell.style.width="15%";
    $.each([["-1","小"],["0","中"],["1","大"]],function(index,btnList){
        newElement = document.createElement("input");
        newElement.type="button";
        newElement.className="fontSizeBtn";
        newElement.value = btnList[1];
        newElement.setAttribute('onclick', 'WkASetFontSize('+btnList[0]+')');
        newCell.appendChild(newElement);
    });
    $.each([["表示最大化","hfOffBtn",false,""],["通常表示","hfOnBtn",true,"vm-disp-none"]],function(index,btnList){
      newElement = document.createElement("input");
      newElement.type="button";
      newElement.className="fontSizeBtn";
      newElement.value = btnList[0];
      newElement.id = btnList[1];
      newElement.setAttribute('onclick', `WkASwitchVisibleHF(${btnList[2]})`);
      if(btnList[3]){
        newElement.classList.add(btnList[3])
      }
      newCell.appendChild(newElement);
  });

    tRow.appendChild(newCell);
}

//作業日テーブルにタブ切替えを追加してレイアウト調整
function WkAAddTDateTbl3Button(){
  var newElement;
  var tDateTbl = document.getElementById("tDateTbl");
  var tRow = tDateTbl.rows[0]
  tRow.cells[0].style.width="80%";
  var newCell = document.createElement('td');
  newCell.className = "listR tabBtn";
  newCell.innerText="表示タブ：";
  newCell.style.width="5%";
  tRow.appendChild(newCell);
  var newCell = document.createElement('td');
  newCell.className = "listC tabBtn";
  newCell.style.width="15%";
  $.each([["0","全件"],["1","本船"],["2","沿岸"],["5","沿岸(別面)"]],function(index,btnList){
      newElement = document.createElement("input");
      newElement.type="button";
      newElement.className="fontSizeBtn";
      newElement.value = btnList[1];
      newElement.setAttribute('onclick', 'WkASwitchWindow('+btnList[0]+')');
      newCell.appendChild(newElement);
  });
  tRow.appendChild(newCell);
}


//フォントサイズ変更
function WkASetFontSize(flg){
    switch(flg){
        case -1 :if(font_size>1){font_size--;} break;
        case 0 : font_size = def_font_size; break;
        case 1 : font_size++; break;
        default: font_size= (def_font_size + flg);
    }
    if(isNaN(font_size)){font_size = def_font_size;}
    $("#wkAhead,#wkAbody,#wkAfoot,#wkAInfoBox,.wkAtimeField,.wkABtn,.wkAPanel,.wkAnoteField,.ioAlert").css("font-size",font_size+"pt");
    $(".wkAtimeField").css("width",(def_font_size*2.5)+"pt");
    $(".wkAPanel").css("width",(def_font_size*5)+"pt").css("height",(font_size+2)+"pt");
    $(".wkAWorkerTitle").css("width",(font_size*4)+"pt");
    $(".wkAMachineTitle").css("width",(font_size*5.1)+"pt");
    $(".wkAnoteField").css("height",(font_size+2)+"pt");
    $(".wkAnoteFieldmc,.mcNm").css("width",(def_font_size*4)+"pt");
    $(".wkAPanelock").css("backgroundSize",font_size+"pt "+font_size+"pt ")

    WkASetView();
    if(window.localStorage && (font_size-def_font_size)!=0){window.localStorage.setItem("onakai_wk_assignment_font_flg", (font_size-def_font_size));}
}

//ヘッダーフッダー表示切替
function WkASwitchVisibleHF(visible){
  const strageKey = "onakai_wk_assignment_hf_hidden_flg"
  const header = document.getElementById('header')
  const footer = document.getElementById('footer')
  const onBtn =  document.getElementById('hfOnBtn')
  const offBtn =  document.getElementById('hfOffBtn')
  const linkBox = document.getElementById('link_box')
  const field1 = document.getElementById('field1')
  const tDateTbl = document.getElementById('tDateTbl')
  if(visible){ //通常表示
    // 表示
    [header,footer,offBtn,linkBox].forEach(target => target.classList.remove('vm-disp-none'));
    // 非表示
    onBtn.classList.add('vm-disp-none');
    // マージン通常
    [field1].forEach(target => target.classList.remove('vm-marg-none'));
    // 横幅通常
    [tDateTbl].forEach(target => target.classList.remove('vm-w100'));
    adjustmentHeight=0;
    //wkASetWkABodyOverflow();

    // 設定削除
    localStorage.removeItem(strageKey);
  }else{ //最大表示
    // 表示
    onBtn.classList.remove('vm-disp-none');
    // 非表示
    let usableHeight = 0;
    [header,footer,offBtn,linkBox].forEach((target) => {
      target.classList.remove('vm-disp-none');
      usableHeight += target.offsetHeight;
      target.classList.add('vm-disp-none');
    });
    usableHeight -= offBtn.offsetHeight;
    usableHeight -= 40; // ヘッダー領域からはみ出す要素分高さを調整
    // マージン０
    [field1].forEach(target => target.classList.add('vm-marg-none'));
    // 横幅最大
    [tDateTbl].forEach(target => target.classList.add('vm-w100'));

    // Body高さ再調整
    adjustmentHeight = usableHeight;
    //wkASetWkABodyOverflow();

    // 設定保存
    window.localStorage.setItem(strageKey, true);
  }
  // 横幅再計算
  WkASetView()
}



//表示タブ切替え
function WkASwitchWindow(switchKey){
  const workClassList = {0:[0,1,2], 1:[1], 2:[0,2], 5:[0,2]}
  let tWorkClass = workClassList[switchKey]
  if(switchKey==5){
    if(!subW){
      subW = openSubWindow(window,'sub')
      filterRow(window,1)
      observer.addObserver(subW);
      $('.tabBtn').css('display','none')
    }
  }else{
    if(subW){
      if(multiWindowMode){
        alert("サブウィンドウを開いています。\n保存を実行してから再度、表示するタブを選択してください。")
        return
      }
      filterRow(window,tWorkClass)
      // subW.close()
      // subW = null
    }else{
      filterRow(window,tWorkClass)
    }
  }
}

//サブウィンドウ表示
const openSubWindow = (masterWindow,name)=>{
  if(subW){
      subW.close()
      multiWindowMode = false
  }
  mainWindow = masterWindow
  subW = masterWindow.open(
      masterWindow.location.href,
      name,
      `dtop=200,left=200,width=${masterWindow.outerWidth},height=${masterWindow.outerHeight}`
  )
  multiWindowMode = true
  return subW
}

// 配番表示行の制御
function filterRow(twindow,workClass){
  if(typeof(workClass)=='number'){workClass = [workClass]}
  const tableRowsR = twindow.document.getElementById('wkAbodyR').children;
  const tableRowsM = twindow.document.getElementById('wkAbodyM').children;
  const tableRowsL = twindow.document.getElementById('wkAbodyL').children;
  Array.from(tableRowsR).forEach((row,index)=>{
    const workClassHiddenField = row.querySelector('div input[name$="[work_class]"]')
    if(!workClassHiddenField) return;

    let wc = Number(workClassHiddenField.value)
    if(workClass.includes(wc)){
      tableRowsR[index].style.display = 'block';
      tableRowsM[index].style.display = 'block';
      tableRowsL[index].style.display = 'block';
    }else{
      tableRowsR[index].style.display = 'none';
      tableRowsM[index].style.display = 'none';
      tableRowsL[index].style.display = 'none';
    }
  });
}

function toggleRowDisplay(rowIndex){
  // 選択状態のリセット
  $("#"+selectedPanel).css("backgroundColor","");
  $("#"+selectedAssignment).css("backgroundColor","");
  selectedPanel="";
  selectedAssignment="";

  const rowR = document.querySelector('#wkAbodyR>div#wkAbodyR_row_' + String(rowIndex));
  const rowM = document.querySelector('#wkAbodyM>div#wkAbodyM_row_' + String(rowIndex));
  const rowL = document.querySelector('#wkAbodyL>div#wkAbodyL_row_' + String(rowIndex));
  if(rowR.style.display=="none"){
    rowR.style.display = 'block';
    rowM.style.display = 'block';
    rowL.style.display = 'block';
  }else{
    rowR.style.display = 'none';
    rowM.style.display = 'none';
    rowL.style.display = 'none';
  }
};



//画面表示調整
function WkASetView(){
    //横幅調整
    var windowW = $("#tDateTbl").width();
    var panelW = $(".wkAPanel").width()+4;
    var box_widths = {}
    //各列の横幅を算出→設定
    $.each(boxKeys,function(index,boxKey){
        var box_width = 0;
        $.each(def_tbl_setting[boxKey+"_block"],function(index,pkey){
            var cell_w = 0;
            setting_obj = def_tbl_setting[pkey];
            if(setting_obj["w_size"] !== undefined){
                cell_w = def_font_size * setting_obj["w_size"];
            }else if(setting_obj["col"] !== undefined){
                cell_w = panelW * setting_obj["col"];
            }
            box_width += cell_w;
            $("#wkAhead_"+pkey+",[id^='wkAbody_"+pkey+"_']").width(cell_w);
        });

        // 臨時等表示・非表示時の幅制御
        box_widths[boxKey] = box_widths[boxKey] || 0
        if(boxKey.toUpperCase()=="L" && viewMord=="wide"){
          box_widths["m"] += box_width;
        }else{
          box_widths[boxKey] += box_width;
        }
        $("#wkAhead"+boxKey.toUpperCase()).width(box_width);
        $("#wkAbody"+boxKey.toUpperCase()).width(box_width);

    });
    var is_over_w = (windowW < box_widths["r"]+box_widths["m"]+box_widths["l"]);
    //全体横幅を設定
    if(is_over_w){$.each(rowKeys,function(index,rowKey){$("#wkA"+rowKey).width(windowW);});}
    else{$.each(rowKeys,function(index,rowKey){$("#wkA"+rowKey).width(0);});}
    var rowH = $("#wkAhead").height();
    $("#wkAheadCellR").width(box_widths["r"]);
    $("#wkAheadCellL").width(box_widths["l"]);
    $("#wkABodyCellR").width(box_widths["r"]);
    $("#wkABodyCellL").width(box_widths["l"]);
    if(is_over_w){
        $("#wkAheadCellM").width(windowW-box_widths["r"]-box_widths["l"]).css("overflow","hidden");
        $("#wkAbodyCellM").width(windowW-box_widths["r"]-box_widths["l"]).css("overflow-x","hidden");
        $("#wkAfoot").width(windowW);
    }else{
        $("#wkAheadCellM").width(box_widths["m"]).css("overflow","visible");
        $("#wkAbodyCellM").width(box_widths["m"]).css("overflow-x","hidden");
        $("#wkAfoot").width(box_widths["r"]+box_widths["m"]+box_widths["l"]);
    }
    //立幅調整
    var cargo_count = document.inform.cargo_count.value-0;
    //各列の立幅を設定
    for(var row_index=0;row_index<cargo_count;row_index++){
        wkASetWkAbodyRowH(row_index);
    }
    wkASetWkABodyOverflow();

    let ee = document.querySelectorAll('.toggle')
    for(let e of ee){
      if(viewMord=="wide"){
        e.style.display='none'
      }else{
        e.style.display='table-row'
      }
    }


}

//表示グループ切替（機械
// 汎用関数
function isOpen(panelSelector){
  const target = document.querySelector(panelSelector)
  let openFlg = !(target.style.display==='' || target.style.display==='none')
  return openFlg
}


let currentDisplayMachineType = ""
function wkAChangeViewMachineGroup(machine_type=null){
  // ボタングループ表示制御
  $(".machinegroup-selectbutton-outer").addClass("active");
  $(".wokergroup-selectbutton-outer").removeClass("active");
  //if(machine_type==null) machine_type=currentDisplayMachineType
  //if(machine_type=="")   machine_type="ld"
  machine_type="0";

  let machineRows = document.querySelectorAll("#wkAMachines div[class*=\"wkAMachineType_\"]");
  let machineRowAry = Array.from(machineRows);

  //machineRowAry.forEach((row)=>{$(row.parentNode).css("display","none")});
  let selectMtypeRow = machineRowAry.find((row)=>{
    const classPattern = /wkAMachineType_(\w+)/;
    let match = row.className.match(classPattern)?.[1];
    return machine_type===match;
  })
  if(selectMtypeRow){
    $(selectMtypeRow.parentNode).css("display","initial");
  }

  let needsPanelToggle = false
  if(isOpen("div#wkAMachines")){
    needsPanelToggle = currentDisplayMachineType!==machine_type
  }

  wkAViewPanelList('Machines');
  if(needsPanelToggle){ //再表示のため、再実行の必要がある。
    wkAViewPanelList('Machines');
  }
  currentDisplayMachineType = machine_type
};

//表示グループ切替（作業員
let currentDisplayWorkerGroup = ""
function wkAChangeViewWokerGroup(branch_cd=null){
  $(".machinegroup-selectbutton-outer").removeClass("active");
  $(".wokergroup-selectbutton-outer").addClass("active");
  //if(branch_cd==null) branch_cd=currentDisplayWorkerGroup
  //if(branch_cd=="")   branch_cd="1"
  branch_cd="0"

  //const cdMapping = [
  //  ["1"],
  //  ["2"],
  //  ["3"],
  //  ["4"],
  //  ["5","6"],
  //]

  let branchRows = document.querySelectorAll("div[id^='brancheRow'")
  //let displayCd = cdMapping.find((ary)=>{
  //  return ary.includes(branch_cd)
  //})
  //for(let el of branchRows){
  //  let match = el.id.match(/\d+$/);
  //  if(el)
  //  el.style.display = 'none';
  //  if(match){
  //    const cdPart = match[0]
  //    if(branch_cd==="0" || displayCd.includes(cdPart)){
  //      el.style.display = 'initial';
  //    }
  //  }
  //};

  let needsPanelToggle = false
  if(isOpen("div#wkAWorkers")){
    needsPanelToggle = currentDisplayWorkerGroup!==branch_cd
  }

  wkAViewPanelList('Workers');
  if(needsPanelToggle){
    wkAViewPanelList('Workers');
  }
  currentDisplayWorkerGroup = branch_cd
}


//表示モード切替（臨時等の表示制御
function switchViewMode(event,target){
  event.preventDefault();
  if(viewMord=="normal"){
    viewMord="wide"
    target.value = "臨時等表示"
  }else{
    viewMord="normal"
    target.value = "臨時等非表示"
  }
  WkASetView();

}
//列の高さを揃える
function wkASetWkAbodyRowH(row_index){
    $.each(boxKeys,function(index,boxKey){
        $("#wkAbody"+boxKey.toUpperCase()+"_row_"+row_index).css("height","auto");
        $("#wkAbody"+boxKey.toUpperCase()+"_row_"+row_index+" > hcalVCell").css("height","auto");
    });
    var rowH = Math.max($("#wkAbodyR_row_"+row_index).height(),$("#wkAbodyM_row_"+row_index).height(),$("#wkAbodyL_row_"+row_index).height());
    $.each(boxKeys,function(index,boxKey){
        $("#wkAbody"+boxKey.toUpperCase()+"_row_"+row_index).height(rowH);
        $("#wkAbody"+boxKey.toUpperCase()+"_row_"+row_index+" > hcalVCell").height(rowH);
    });
}
//Bodyの高さを調整
function wkASetWkABodyOverflow(){
    var tmpOffset = $("#wkAbody").offset()
    var windowH = window.innerHeight - tmpOffset.top - $("#wkAfoot").height()-90+adjustmentHeight;
    $("#wkAbodyCellM").height(windowH).css("overflow-y","scroll");
    $("#wkAbodyCellL,#wkAbodyCellR").height(windowH).css("overflow","hidden");
}
//Bodyスクロール時の同期
function doWkABodyScroll(robj){
    //縦
    $("#wkAbodyCellL,#wkAbodyCellR").scrollTop(robj.scrollTop);
    $("div[id^='ErrorMsgBox']:visible").each(function(){
        var robj = document.getElementById("ErrorMsgBtn"+$(this).attr("id").replace("ErrorMsgBox",""));
        var oTop = offsetTop(robj)-30-$("#wkAbodyCellL").scrollTop();
        if(oTop < 30 || oTop > window.innerHeight){
            $(this).css("display","none");
        }else{
            $(this).css("top",oTop+"px");
        }
    });
    //if($("#wkAInfoBox").css("display")=="block"){
    //
    //}
    //横
    if($("#wkAheadCellM").scrollLeft() < 50 || robj.scrollLeft!=0){
        //縦スクロール実行時にrobj.scrollLeftが0を返す事があるので
        $("#wkAheadCellM").scrollLeft(robj.scrollLeft);
    }
}
//行毎臨時・人のカウント
function WkARowReCount(row_index,withoutLock){
    if(!withoutLock){
        var countDatas = {};
        var countSubs = {};
        var isFull = true;
        $.each(AssignmentBlocks,function(index,pkey){
            countDatas[pkey] = 0;
            var tObjs = $("input[name^='wkACargoWorker_"+row_index+"["+pkey+"']input[id$='_login_id']");
            tObjs.each(function(index,obj){
                if($(this).attr('id').match(/_login_id$/) && $(this).val() != ""){
                  val = obj.value
                  var PanelText = $("#wkAUser_"+$(this).val()).text();
                  if(!val.toLowerCase().startsWith('rokyo')){
                    countDatas[pkey]++;
                    if(pkey=="wk"){
                      switch($("#wkAUser_"+$(this).val()+"_branch_cd").val()){
                      case "1":
                      case "2":
                      case "3":
                      case "4":
                          break;
                      default:
                        if(PanelText in countSubs){
                          countSubs[PanelText]++;
                        }else{
                            countSubs[PanelText] = 1;
                        }
                      }
                    }
                  }
                }
            });
            var needCount = 0
            $("input[id^='needCount_"+row_index+"_"+pkey+"']").each(function(){
                needCount += ($(this).val() - 0);
            });
            if(needCount == 0 || countDatas[pkey] >= needCount){
                // $("#wkAbody_"+pkey+"_"+row_index).css("backgroundColor","");
            }else{
                // $("#wkAbody_"+pkey+"_"+row_index).css("backgroundColor","#ff7f7f");
                isFull = false;
            }
        });
        $("#wkACargoWkNp_"+row_index).text(countDatas["wk"]);
        var wkACargoNpStr = "";
        for(var PanelText in countSubs){wkACargoNpStr+= PanelText+":"+countSubs[PanelText]+"<br />";}
        $("#wkACargoNp_"+row_index).html(wkACargoNpStr);
        if(isFull){
            $("input[name='cargo_"+row_index+"[esta_flg]'][value=2]").prop('checked', true);
        }
        // for(var npkey in countDatas){$("input[name='cargo_"+row_index+"["+npkey+"_np]'").val(countDatas[npkey]);}
    }
}



//出勤予定時刻
const getCargoITime = (box_index,useDefault=false)=>{
    if(check_Time($("#cargo_"+box_index+"_i_time").get(0),1,"出勤予定時刻")==""){
      return $("#cargo_"+box_index+"_i_time").val();
    }else{
      setError($("#cargo_"+box_index+"_i_time").get(0),"OFF");
      return useDefault ? RegularITime : '';
    }
  }
//開始時刻
const getCargoSTime = (box_index,useDefault=false)=>{
  if(check_Time($("#cargo_"+box_index+"_s_time").get(0),1,"開始予定時刻")==""){
    return $("#cargo_"+box_index+"_s_time").val();
  }else{
    setError($("#cargo_"+box_index+"_s_time").get(0),"OFF");
    return useDefault ? RegularSTime : '';
  }
}
//終了時刻
const getCargoETime = (box_index,useDefault=false)=>{
  if(check_Time($("#cargo_"+box_index+"_e_time").get(0),1,"終了予定時刻")==""){
    return $("#cargo_"+box_index+"_e_time").val();
  }else{
    setError($("#cargo_"+box_index+"_e_time").get(0),"OFF");
    return useDefault ? RegularETime : '';
  }
}


//作業員パネルの表示を配番パネルに反映
function wkASetWorkerInit(robj){
  if(ck_result = selectedPanel.match(/^wkAUser_(\w+)/)){
    var root_Panel = $("#"+selectedPanel);
    if(root_Panel.length){
      if($("#"+robj.id+"_work_index").val()-0 > 0){
        $("#"+robj.id+"_text").text("("+root_Panel.text()+")");
      }else{
        $("#"+robj.id+"_text").text(root_Panel.text());
      }
      robj.className = root_Panel.attr("class");
      if($("#"+robj.id+"_lock_flg").val()=="1"){wkASetLockView(robj.id,1);}
      root_Panel.addClass("wkAIsAssigned");
      // root_Panel.css("backgroundColor","gray");
      var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
      if(assignmentForm.length){assignmentForm.val(assignmentForm.val()+"|"+robj.id+"|");}
    }
  }
}

//機械パネルの表示を配番パネルに反映
function wkASetMachineInit(robj){
  if(ck_result = selectedPanel.match(/^wkAMachine_(\w+)/)){
    var root_Panel = $("#"+selectedPanel);
    if(root_Panel.length){
      if($("#"+robj.id+"_work_index").val()-0 > 0){
        $("#"+robj.id+"_text").text("("+root_Panel.text()+")");
      }else{
        $("#"+robj.id+"_text").text(root_Panel.text());
      }
      robj.className = root_Panel.attr("class");
      if($("#"+robj.id+"_lock_flg").val()=="1"){wkASetLockView(robj.id,1);}
      root_Panel.addClass("wkAIsAssigned");
      // root_Panel.css("backgroundColor","gray");
      var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
      if(assignmentForm.length){assignmentForm.val(assignmentForm.val()+"|"+robj.id+"|");}
    }
  }
}
//ロック表示(初期表示のために別関数)
function wkASetLockView(robjId,locked){
    var panel = $("#"+robjId);
    if(panel.length){
        if(locked==1 && !panel.hasClass("wkAPanelock")){
            panel.addClass("wkAPanelock").css("backgroundSize",font_size+"pt "+font_size+"pt ");
        }else if(locked==0 && panel.hasClass("wkAPanelock")){
            panel.removeClass("wkAPanelock");
        }
    }
}


// ロック解除（wkASetWorker内で使用、withoutLock=trueの場合に使用される）
unLockIfLocked = (from,to)=>{
  let ret = [];
  if($("#"+from+"_lock_flg").val()=="1"){
    wkASetLock($("#"+from).get(0));
    ret.push(from);
  }
  if($("#"+to+"_lock_flg").val()=="1"){
    wkASetLock($("#"+to).get(0));
    ret.push(to);
  }
  return ret;
}




//出勤時間、終了時間の再計算（バスフラグに更新に伴う再計算に使用
// s_time -> 現在の出勤時間(YY:MM)
// e_time -> 現在の終業予定時間(YY:MM)
// cargo_i_time -> 配番作業の出勤時間(YY:MM)
// bus_flg -> 変更後のバスフラグ true->"1" false->"0"
function adjustStimeEtimeByBusFlags(s_time,e_time,cargo_i_time,bus_flg){
  const sTimeMin = strHHMMtoMinutes(s_time);
  const eTimeMin = strHHMMtoMinutes(e_time);
  let afterSTimeMin = sTimeMin
  let afterETimeMin = eTimeMin

  if(bus_flg=="1"){
    afterSTimeMin -= 30
    if(afterSTimeMin<strHHMMtoMinutes("7:00")){
      afterSTimeMin = sTimeMin
      afterETimeMin += 30
    }
  }else{
    const cargoITimeMin = strHHMMtoMinutes(cargo_i_time)
    if(cargoITimeMin>=strHHMMtoMinutes("7:30")){
      afterSTimeMin +=30
    }else{
      afterETimeMin -=30
    }
  }
  const afterSTime = minutesToStrHHMM(afterSTimeMin)
  const afterETime = minutesToStrHHMM(afterETimeMin)

  return [afterSTime,afterETime]

}


function shiftType(s_time){
  let shift = "1直";
  const sTimeMin = strHHMMtoMinutes(s_time);
  const time1859 = strHHMMtoMinutes("18:59");
  const time1959 = strHHMMtoMinutes("19:59");

  if(time1959 < sTimeMin){
    shift = "2直2" // 出勤時間 20:00～
  }else if(time1859 < sTimeMin){
    shift = "2直1" // 出勤時間 19:00～
  }
  return shift
}

//(法定)就業時間の計算
function wkCalcWorkTime(s_time,e_time,bus_flg){
  const shift = shiftType(s_time);
  let work_time = orver_time = 0
  const p_work_time = wkCalcPWorkTime(s_time,e_time);
  let ret = {"s_time":s_time,"e_time":e_time,"work_time":0,"orver_time":0};
  s_time = strHHMMtoMinutes(s_time);
  e_time = strHHMMtoMinutes(e_time);
  if(s_time > e_time) e_time += 60*24;
  work_time = p_work_time["work_time"];

  //法定実労
  switch(shift){
    case "1直":
      // ・出勤が19:00以前＆終了18:30未満				所定時間　-　30分		←手洗いのみ
      // ・出勤が19:00以前＆終了21:00未満				所定時間　-　60分		←手洗い＋30分休憩
      // ・出勤が19:00以前＆終了21:00以降				所定時間　-　90分		←手洗い＋30分休憩×２
      const time1830 = strHHMMtoMinutes("18:30");
      const time2100 = strHHMMtoMinutes("21:00");
      if(e_time <= time1830){
        work_time -= 30
      }else if(e_time < time2100){
        work_time -= 60
      }else if(e_time >= time2100){
        work_time -= 90
      }else{
      }
      break;
    case "2直1":
      // ・出勤が19:00以降～終了04:30未満				所定時間　-　30分		←手洗いのみ
      // ・出勤が19:00以降～				所定時間　-　60分		←手洗い＋30分休憩
      const time0430 = strHHMMtoMinutes("04:30") + 60*24;
      if(e_time < time0430){
        work_time -= 30
      }else if(e_time >= time0430){
        work_time -= 60
      }else{
      }
      break;

    case "2直2":
      // ・出勤が20:00以降～終了05:00未満				所定時間　-　30分		←手洗いのみ
      // ・出勤が20:00以降～				所定時間　-　60分		←手洗い＋30分休憩
      const time0500 = strHHMMtoMinutes("05:00") + 60*24;
      if(e_time < time0500){
        work_time -= 30
      }else if(e_time >= time0500){
        work_time -= 60
      }
      break;
  }

  //バスフラグ
  // ・出勤時間に関わらずバスフラグが付いた場合				さらに-30分
  if(bus_flg=="1") work_time -= 30;

  //法定残業
  // ・Max（法定実労-8時間、0）　←２直も同じ
  orver_time = Math.max(work_time - 8*60, 0);

  ret["work_time"] = work_time;
  ret["orver_time"] = orver_time;
  return ret;

}


//(所定)就業時間の計算
function wkCalcPWorkTime(s_time,e_time){
  //--変数初期化
  const shift = shiftType(s_time);
  let p_work_time = p_orver_time = p_early_time = 0;
  let ret = {"s_time":s_time,"e_time":e_time,"work_time":0,"orver_time":0};

  s_time = strHHMMtoMinutes(s_time);
  e_time = strHHMMtoMinutes(e_time);
  if(s_time > e_time) e_time += 60*24;
  p_work_time = e_time - s_time;

  switch(shift){
    case "1直":
      // 所定
      // 5. 終了が12:00以前の場合: 終了-出勤
      // 5‘. 開始が13:00以降の場合: 終了-出勤
      // 6. 上記以外: 終了-出勤-60分（12:00～60分昼食休憩）
      const time1200 = strHHMMtoMinutes("12:00");
      const time1300 = strHHMMtoMinutes("13:00");
      if(e_time > time1200 && s_time < time1300){
        p_work_time -= 60
      }

      // 早出
      // ・出勤が08:00以前				08:00-出勤　（※PN年の場合でも計上
      const time0800 = strHHMMtoMinutes("08:00");
      p_early_time = Math.max(time0800 - s_time, 0);

      // 残業
      // 終了-16:00　（※AM年の場合でも計上、マイナスは0）
      const time1600 = strHHMMtoMinutes("16:00");
      p_orver_time = Math.max(e_time - time1600, 0);
      break;
    case "2直1":
    case "2直2":
      // 所定
      // 6. 上記以外: 終了-出勤-60分（12:00～60分昼食休憩）
      if(shift === "2直1"){
        // 3. 出勤が19:00以降～終了23:30未満の場合: 終了-出勤（日付に注意）
        // 4. 出勤が19:00以降の場合: 終了-出勤-60分（23:00～60分夕食休憩、日付に注意）
        const time2330 = strHHMMtoMinutes("23:30");
        if(e_time>=time2330){
          p_work_time -= 60
        }
      }else{
        // 1. 出勤が20:00以降～終了00:00未満の場合: 終了-出勤（日付に注意）
        // 2. 出勤が20:00以降の場合: 終了-出勤-60分（00:00～60分夕食休憩、日付に注意）
        const time0000 = strHHMMtoMinutes("00:00") + 60*24;
        if(e_time>=time0000){
          p_work_time -= 60
        }
      }

      // 早出
      // ・出勤が19:00以降～20:00＆終了が05:00以降 => 終了-05:00
      // ・出勤が19:00以降～20:00＆終了が05:00以前 => 0
      const time0500 = strHHMMtoMinutes("05:00") + 60*24;
      if(e_time >= time0500){
        p_early_time = Math.max(e_time - time0500, 0);
      }

      // 残業
      if(shift === "2直1"){
        // ・出勤が19:00以降				終了-02:00　（マイナスは0）
        const time0200 = strHHMMtoMinutes("02:00") + 60*24;
        p_orver_time = Math.max(e_time - time0200, 0);
      }else{
        // ・出勤が20:00以降				終了-04:00　（マイナスは0）
        const time0400 = strHHMMtoMinutes("04:00") + 60*24;
        p_orver_time = Math.max(e_time - time0400, 0);
      }
      break;
  }
  ret["work_time"] = p_work_time;
  ret["orver_time"] = p_orver_time+p_early_time;
  return ret;

}

//配番された作業員の情報表示
function wkViewWorkerInfo(robj,mord){
  if(tmp = robj.id.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)){
    var box_index = tmp[1];
    var rkey = tmp[2];
    var wk_index = tmp[3];
    var vText,tmpVal;
    vText = "<form><table class='soloidline'>";
    tmpVal = $("input[id='"+robj.id+"_work_class']").val();
    vText +="<tr><td colspan='2' class='listTitle'>作業区分</td>";
    vText +="<td class='list'>";
    vText +="<label><input type='radio' name='work_class' value='1' "+(tmpVal=="1" ? "checked" : "")+" onclick='obsWkSetWorkerInfo(window,event,this);' />本船</label>"
    vText +="<label><input type='radio' name='work_class' value='2' "+(tmpVal=="2" ? "checked" : "")+" onclick='obsWkSetWorkerInfo(window,event,this);' />沿岸</label>"
    vText +="</td></tr>";
    tmpVal = $("input[id='"+robj.id+"_wk_class']").val();
    var wk_class_list=[["--","--"]];
    vText +="<tr><td colspan='2' class='listTitle'>担当作業</td>";
    vText +="<td class='list'>";
    $("input[id^='needCount_"+box_index+"_"+rkey+"_']").each(function(){
      if(tmpKeys = $(this).attr("id").match(new RegExp("needCount_"+box_index+"_"+rkey+"_(\\w+)"))){
        var skey = tmpKeys[1];
        switch(skey){
        case "fm": wk_class_list.push([skey,"FM"]);break;
        case "dm": wk_class_list.push([skey,"DM"]);break;
        case "wm": wk_class_list.push([skey,"WM"]);break;
        case "cr": wk_class_list.push([skey,"ｸﾚｰﾝ"]);break;
        case "ld": wk_class_list.push([skey,"ローダ"]);break;
        case "bh": wk_class_list.push([skey,"ﾊﾞｯｸﾎｰ"]);break;
        case "sl": wk_class_list.push([skey,"船内ﾛｰﾀﾞ"]);break;
        case "bl": wk_class_list.push([skey,"ブル"]);break;
        case "lf": wk_class_list.push([skey,"リフト"]);break;
        case "sc": wk_class_list.push([skey,"SC"]);break;
        case "tl": wk_class_list.push([skey,"TL"]);break;
        case "ot": wk_class_list.push([skey,"他作業"]);break;
        case "hd": wk_class_list.push([skey,"ハンドル"]);break;
        case "db": wk_class_list.push([skey,"土場作業"]);break;
        case "hs": wk_class_list.push([skey,"配車作業"]);break;
        case "sn": wk_class_list.push([skey,"船内作業"]);break;
        case "eg": wk_class_list.push([skey,"沿岸作業"]);break;
        }
      }
    });
    vText +="<select name='wk_class' onchange='obsWkSetWorkerInfo(window,event,this);'>";
    // vText +="<select name='wk_class' onchange='wkSetWorkerInfo(this);'>";
    $.each(wk_class_list,function(index,wKclass){
      vText +="<option value='"+wKclass[0]+"' "+(tmpVal==wKclass[0] ? "selected" : "")+">"+wKclass[1]+"</option>";
    });
    vText +="</select>";
    vText +="</td></tr>";
    //tmpVal = $("input[id='"+robj.id+"_competence']").val();
    //vText +="<tr><td class='listTitle'>力量(確認)</td>";
    //vText +="<td class='list' id='wkAInfoBox_competence'>"+tmpVal+"</td></tr>";
    //if(mord == "rz"){
    //  tmpVal = $("input[id='"+robj.id+"_base_no']").val();
    //  vText +="<tr><td class='listTitle'>出欠("+tmpVal+")</td>";
    //  vText +="<td class='list'>";
    //  vText +="<label><input type='radio' name='base_no' value='1' "+(tmpVal=="1" ? "checked" : "")+" onclick='wkSetWorkerInfo(this);' />出勤</label>"
    //  vText +="<label><input type='radio' name='base_no' value='2' "+(tmpVal=="2" ? "checked" : "")+" onclick='wkSetWorkerInfo(this);' />早退</label>"
    //  vText +="<label><input type='radio' name='base_no' value='8' "+(tmpVal=="8" ? "checked" : "")+" onclick='wkSetWorkerInfo(this);' />年休</label>"
    //  vText +="<label><input type='radio' name='base_no' value='22' "+(tmpVal=="22" ? "checked" : "")+" onclick='wkSetWorkerInfo(this);' />欠勤</label>"
    //  vText +="</td></tr>";
    //}
    tmpVal = $("input[id='"+robj.id+"_bus_flg']").val();
    vText +="<tr><td colspan='2' class='listTitle'>バス手当</td>";
    vText +="<td class='list'><input type='checkbox' name='bus_flg' "+(tmpVal=="1" ? "checked" : "" )+" onchange='wkAdjustWorkerInfoByBusFlg(this);obsWkSetWorkerInfo(window,event,this);'/></td></tr>";

    tmpVal = $("input[id='"+robj.id+"_work_index']").val();
    vText +="<tr><td colspan='2' class='listTitle'>作業順</td>";
    vText +="<td class='list'><input type='text' name='work_index' value='"+tmpVal+"' onchange='obsWkSetWorkerInfo(window,event,this);' size=3 style='text-align:right'/></td></tr>";

    tmpVal = $("input[id='"+robj.id+"_s_time']").val();
    vText +="<tr><td colspan='2' class='listTitle'>出勤時刻</td>";
    vText +="<td class='list'><input type='text' name='s_time' value='"+tmpVal+"' onchange='set_time(this);obsWkSetWorkerInfo(window,event,this);' size=5/></td></tr>";
    tmpVal = $("input[id='"+robj.id+"_e_time']").val();
    var e_time_title="終了予定時刻";
    switch(mord){
    case "rz" : e_time_title = "終了時刻";break;
    }
    vText +="<tr><td colspan='2' class='listTitle'>"+e_time_title+"</td>";
    vText +="<td class='list'><input type='text' name='e_time' value='"+tmpVal+"' onchange='set_time(this);obsWkSetWorkerInfo(window,event,this);' size=5/></td></tr>";
    tmpVal = Math.round(($("input[id='"+robj.id+"_work_time']").val()-0) / 6)/10; //時間表記
    vText +="<tr>";
    vText +="<td rowspan='4' class='listTitle text-vertical'>法定</td>";
    vText +="<td class='listTitle'>就業時間</td>";
    vText +="<td class='list'><input type='text' name='work_time' value='"+tmpVal+"' onchange='obsWkSetWorkerInfo(window,event,this);' size=5 style='text-align:right'/>時間</td></tr>";
    tmpVal = Math.round(($("input[id='"+robj.id+"_orver_time']").val()-0) /6)/10; //時間表記
    vText +="<tr><td class='listTitle'>超過時間</td>";
    vText +="<td class='list'><input type='text' name='orver_time' value='"+tmpVal+"' onchange='obsWkSetWorkerInfo(window,event,this);' size=5  style='text-align:right'/>時間</td></tr>";

    var login_id = $("#"+robj.id+"_login_id").val();
    var alert;
    //vText +="<tr><td class='listTitle'>login_id</td>";
    //vText +="<td class='list'>"+login_id+"</td></tr>";
    var total_orver_time = ($("input[id='"+robj.id+"_orver_time']").val()-0);
    // --
    total_orver_time += ($('input[id="wkAUser_'+login_id+'_total_orver_time"]').val() - 0);
    if(total_orver_time > 2700){ //2700=45h*60m
      alert = " class='err'";
    }else{
      alert = "";
    }
    vText +="<tr><td class='listTitle'>当月累計超過時間(予定)</td>";
    vText +="<td class='listR'><span id='tot'"+alert+">"+(Math.round(total_orver_time /6)/10)+"</span>時間</span></td></tr>";
    // --

    total_orver_time += ($('input[id="wkAUser_'+login_id+'_total_yorver_time"]').val()-0);
    if(total_orver_time > 21600){ //21600=360h*60m
      alert = " class='err'";
    }else{
      alert = "";
    }
    vText +="<tr><td class='listTitle'>当年累計超過時間(予定)</td>";
    vText +="<td class='listR'><span id='ytot'"+alert+">"+(Math.round(total_orver_time /6)/10)+"</span>時間</td></tr>";

    // --
    // 所定労働時間と所定残業時間を追加する
    var pWorkTime = $("input[id='"+robj.id+"_p_work_time']").val();
    // 所定作業時間が未計算の場合は、所定労働時間と所定残業時間を計算して置換する ...DBに持たないため
    if(pWorkTime==-1){
      var s_time = $("input[id='"+robj.id+"_s_time']").val();
      var e_time = $("input[id='"+robj.id+"_e_time']").val();
      var bus_flg = $("input[id='"+robj.id+"_bus_flg']").val();
      let work_time = orver_time = 0;

      if(s_time != "" && e_time != ""){
        var WorkPTime = wkCalcPWorkTime(s_time,e_time,bus_flg);
        work_time = WorkPTime["work_time"];
        orver_time = WorkPTime["orver_time"];
      }
      $("input[id='"+robj.id+"_p_work_time']").val(work_time);
      $("input[id='"+robj.id+"_p_orver_time']").val(orver_time);
    }

    tmpVal = Math.round(($("input[id='"+robj.id+"_p_work_time']").val()-0) / 6)/10; //時間表記
    vText +="<tr>";
    vText +="<td rowspan='3' class='listTitle text-vertical'>所定</td>";
    vText +="<td class='listTitle'>就業時間</td>";
    vText +="<td class='listR'><span id='p_work_time'>" + tmpVal + "</span>時間</td></tr>";
    tmpVal = Math.round(($("input[id='"+robj.id+"_p_orver_time']").val()-0) /6)/10; //時間表記
    vText +="<tr><td class='listTitle'>超過時間</td>";
    vText +="<td class='listR'><span id='p_orver_time'>" + tmpVal + "</span>時間</td></tr>";


    var total_p_orver_time = ($("input[id='"+robj.id+"_p_orver_time']").val()-0);
    if(total_p_orver_time==-1){ //-1=>登録済み作業者の所定作業時間が初期化されていない　計算して置換する
      var s_time = $("input[id='"+robj.id+"_s_time']").val();
      var e_time = $("input[id='"+robj.id+"_e_time']").val();
      var bus_flg = $("input[id='"+robj.id+"_bus_flg']").val();
      var WorkPTime = wkCalcPWorkTime(s_time,e_time,bus_flg);
      $("input[id='"+robj.id+"_p_work_time']").val(WorkPTime["work_time"]);
      $("input[id='"+robj.id+"_p_orver_time']").val(WorkPTime["orver_time"]);
      total_p_orver_time = ($("input[id='"+robj.id+"_p_orver_time']").val()-0);
    }
    total_p_orver_time += ($('input[id="wkAUser_'+login_id+'_total_orver_time2"]').val() - 0);
    if(total_p_orver_time > 2700){ //2700=45h*60m
      alert = " class='err'";
    }else{
      alert = "";
    }
    vText +="<tr><td class='listTitle'>当月累計超過時間(予定)</td>";
    vText +="<td class='listR'><span id='topt'"+alert+">"+(Math.round(total_p_orver_time /6)/10)+"</span>時間</span></td></tr>";
    // --
    vText +="<tr><td class='listC' colspan=2><input type='button' value='閉じる' onclick='$(\"#wkAInfoBox\").css(\"display\",\"none\");' /></td></tr>";
    vText += "</table>";    vText += "<input type=hidden name='robj_id' value='"+robj.id+"' />";
    vText += "</from>";
    wkAViewNote(robj,vText)
  }
}
// 

//フォーム値をバスフラグの値で更新する
function wkAdjustWorkerInfoByBusFlg(robj){
  if(robj.name!="bus_flg") return;
  var fobj = robj.form;
  var robjId = fobj.robj_id.value
  if(tmp = robjId.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)){
    var box_index = tmp[1];
    var cargoITime = getCargoITime(box_index);
    if(cargoITime==''){
      const cargoSTime = getCargoSTime(box_index);
      if(cargoSTime!=''){
        cargoITime = minutesToStrHHMM(strHHMMtoMinutes(cargoSTime)-30);
      }else{
        cargoITime = getCargoITime(box_index,true);
      }

    }
    var busFlg = fobj.bus_flg.checked ? "1" : "0"
    // if(fobj.s_time.value && fobj.e_time.value && busFlg=="1"){
    if(fobj.s_time.value && fobj.e_time.value){
      const [adjStime,adjEtime] = adjustStimeEtimeByBusFlags(fobj.s_time.value,fobj.e_time.value,cargoITime,busFlg)
      fobj.s_time.value = adjStime
      fobj.e_time.value = adjEtime
    }
  }
}


function wkSetWorkerInfo(robj){
  var fobj = robj.form;
  var robjId = fobj.robj_id.value
  if(tmp = robjId.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)){
    var box_index = tmp[1];
    var rkey = tmp[2];
    var wk_index = tmp[3];
    var login_id = $("#"+robjId+"_login_id").val();



    //就業時間＆超過時間
    // バスフラグ値による30min補正は外部関数で行う（wkAdjustWorkerInfoByBusFlg
    if(robj.name !="work_time" && robj.name !="orver_time"){
      const sTime = fobj.s_time.value
      const eTime = fobj.e_time.value
      const busFlg = fobj.bus_flg.checked ? "1": "0";

      if(sTime == "" || eTime == ""){
        // --法定
        fobj.work_time.value = 0;
        fobj.orver_time.value = 0;
        // --所定
        $("span#p_work_time").text(0);
        $("span#p_orver_time").text(0);

      }else{
        // --法定
        var WorkTime = wkCalcWorkTime(sTime,eTime,busFlg);
        fobj.work_time.value = convMinToHour(WorkTime["work_time"]);
        fobj.orver_time.value = convMinToHour(WorkTime["orver_time"]);
  
        // --所定
        var WorkPTime = wkCalcPWorkTime(sTime,eTime);
        $("span#p_work_time").text(convMinToHour(WorkPTime["work_time"]));
        $("span#p_orver_time").text(convMinToHour(WorkPTime["orver_time"]));
      }
    }



    //配番データに反映
    if(robj.name == "work_index"){
      var plain_text = $("#"+robjId+"_text").text().replace("(","").replace(")","");
      $("#"+robjId+"_text").text(Number(fobj.work_index.value)==0 ? plain_text : "("+plain_text+")");
    }
    $("#"+robjId+"_work_class").val(getRadioVal(fobj.work_class));
    $("#"+robjId+"_wk_class").val(fobj.wk_class.value);
    if(fobj.base_no){$("#"+robjId+"_base_no").val(getRadioVal(fobj.base_no));}
    var competenceKey = wkSelectCompetenceKey(fobj.wk_class.value,getCompetenceKeys(box_index,rkey,wk_index));
    if(competenceKey!=""){
      $("#"+robjId+"_competence").val($('input[id="wkAUser_'+login_id+'_competence_'+competenceKey+'"]').val());
    }else{
      $("#"+robjId+"_competence").val("3");
    }
    //$("#wkAInfoBox_competence").html($("#"+robjId+"_competence").val());
    $("#"+robjId+"_bus_flg").val(fobj.bus_flg.checked ? "1" : "0");
    $("#"+robjId+"_work_index").val(fobj.work_index.value);
    $("#"+robjId+"_s_time").val(fobj.s_time.value);
    $("#"+robjId+"_e_time").val(fobj.e_time.value);
    $("#"+robjId+"_work_time").val((fobj.work_time.value-0)*60);
    $("#"+robjId+"_orver_time").val((fobj.orver_time.value-0)*60);

    //残業時間チェック(法定)
    var total_orver_time = ($("#"+robjId+"_orver_time").val()-0);
    var monthly_orver_time = ($('input[id="wkAUser_'+login_id+'_total_orver_time"]').val() - 0);
    total_orver_time += monthly_orver_time;
    $("#tot").text(Math.round(total_orver_time /6)/10);
    if(total_orver_time > 2700){ //2700=45h*60m
      $("#tot").addClass("err");
    }else{
      $("#tot").removeClass("err");
    }
    var yearly_orver_time = ($('input[id="wkAUser_'+login_id+'_total_yorver_time"]').val() - 0);
    total_orver_time += yearly_orver_time;
    $("#ytot").text(Math.round(total_orver_time /6)/10);
    if(total_orver_time > 21600){ //21600=360h*60m
      $("#ytot").addClass("err");
    }else{
      $("#ytot").removeClass("err");
    }

    //残業時間チェック(所定) ※当月累計表示のみ
    var p_work_time = p_orver_time = 0;
    if(fobj.s_time.value != "" && fobj.e_time.value != ""){
      var PWorkTime = wkCalcPWorkTime(fobj.s_time.value,fobj.e_time.value,(fobj.bus_flg.checked ? "1": "0"));
      p_work_time = Math.round(PWorkTime["work_time"] / 6)/10;
      p_orver_time = Math.round(PWorkTime["orver_time"] / 6)/10;
    }
    $("#"+robjId+"_p_work_time").val((p_work_time-0)*60);
    $("#"+robjId+"_p_orver_time").val((p_orver_time-0)*60);

    var total_p_orver_time = p_orver_time*60;
    var monthly_p_orver_time = ($('input[id="wkAUser_'+login_id+'_total_orver_time2"]').val() - 0);
    total_p_orver_time += monthly_p_orver_time;
    $("#topt").text(Math.round(total_p_orver_time / 6)/10);
    if(total_p_orver_time > 2700){ //2700=45h*60m
      $("#topt").addClass("err");
    }else{
      $("#topt").removeClass("err");
    }

  }
}
//注釈表示
function wkAViewNote(robj,vText){
    var popBox = document.getElementById('wkAInfoBox');
    if(!popBox){
        popBox =document.createElement('div');
        popBox.id = 'wkAInfoBox';
        popBox.className = 'wkAInfoBox';
        popBox.style.fontSize=font_size+"pt";
        popBox.addEventListener('click',function(){$('wkAInfoBox').css('display','none')});
        document.getElementById('field1').appendChild(popBox);
    }
    if(vText == ""){
      popBox.style.display='none';
    }else{
        var oTop = offsetTop(robj)-30;
        var oLeft = offsetLeft(robj)+35;
        if(robj.id.match(/^wkACargoWorker/) || robj.id.match(/^wkACargoMachine/)){
          oTop -= $("#wkAbodyCellM").scrollTop();
          oLeft -= $("#wkAbodyCellM").scrollLeft();
        }else if(robj.id.match(/^wkAUser/)){
        }else if(robj.id.match(/^wkAMachine/)){
          oTop -= $("#wkAMachines").scrollTop();
        }
        popBox.style.top=oTop+'px';
        popBox.style.left=oLeft+'px';
        popBox.style.display='block';
        popBox.innerHTML = vText;
    }
}
//担当作業と可能作業となる力量キー配列から力量キーを確定
function wkSelectCompetenceKey(wk_class,competenceKeys){
  if(competenceKeys.length == 1){
    return competenceKeys[0];
  }else{
    switch(wk_class){
    case "fm":
      if(competenceKeys.includes("fma")){return "fma";}
      if(competenceKeys.includes("fmp")){return "fmp";}
      if(competenceKeys.includes("fmm")){return "fmm";}
      if(competenceKeys.includes("fmc")){return "fmc";}
      break;
    case "dm":
      if(competenceKeys.includes("sn")){return "sn";}
      if(competenceKeys.includes("dm")){return "dm";}
      break;
    case "wm":
      if(competenceKeys.includes("wwm")){return "wwm";}
      break;
    case "cr":
      if(competenceKeys.includes("cr3")){return "cr3";}
      if(competenceKeys.includes("cr5")){return "cr5";}
      if(competenceKeys.includes("cr6")){return "cr6";}
      if(competenceKeys.includes("cr7")){return "cr7";}
      if(competenceKeys.includes("cru")){return "cru";}
      if(competenceKeys.includes("crg")){return "crg";}
      if(competenceKeys.includes("crp")){return "crp";}
      if(competenceKeys.includes("cre")){return "cre";}
      if(competenceKeys.includes("crs")){return "crs";}
      break;
    case "ld":
      if(competenceKeys.includes("ldm")){return "ldm";}
      if(competenceKeys.includes("ldc")){return "ldc";}
      break;
    case "bh":
      if(competenceKeys.includes("bhs")){return "bhs";}
      if(competenceKeys.includes("bhh")){return "bhh";}
      break;
    case "sl":
      if(competenceKeys.includes("slm")){return "slm";}
      if(competenceKeys.includes("slc")){return "slc";}
      break;
    case "bl":
      if(competenceKeys.includes("blh")){return "blh";}
      if(competenceKeys.includes("bld")){return "bld";}
      break;
    case "lf":
      if(competenceKeys.includes("lfl")){return "lfl";}
      if(competenceKeys.includes("lf")){return "lf";}
      break;
    case "sc":
      if(competenceKeys.includes("scm")){return "scm";}
      if(competenceKeys.includes("scc")){return "scc";}
      break;
    case "tl":
      if(competenceKeys.includes("tlm")){return "tlm";}
      if(competenceKeys.includes("tlc")){return "tlc";}
      break;
    case "ot":
      if(competenceKeys.includes("cc")){return "cc";}
      if(competenceKeys.includes("od")){return "od";}
      if(competenceKeys.includes("ep")){return "ep";}
      if(competenceKeys.includes("em")){return "em";}
      if(competenceKeys.includes("sw")){return "sw";}
      if(competenceKeys.includes("sp")){return "sp";}
      if(competenceKeys.includes("clr")){return "clr";}
      break;
    case "hd":
      if(competenceKeys.includes("w3")){return "w3";}
      if(competenceKeys.includes("s5")){return "s5";}
      if(competenceKeys.includes("s7")){return "s7";}
      break;
    case "db":
      if(competenceKeys.includes("wgd")){return "wgd";}
      break;
    case "hs":
      if(competenceKeys.includes("wal")){return "wal";}
      break;
    case "sn":
      if(competenceKeys.includes("w6e")){return "w6e";}
      if(competenceKeys.includes("wbg")){return "wbg";}
      if(competenceKeys.includes("wlg")){return "wlg";}
      if(competenceKeys.includes("wsc")){return "wsc";}
      if(competenceKeys.includes("wsm")){return "wsm";}
      break;
    case "eg":
      if(competenceKeys.includes("wcc")){return "wcc";}
      if(competenceKeys.includes("wc")){return "wc";}
      break;
    }
    return "";
  }
}
//配番パネル上のユーザ領域指定→可能作業となる力量キー配列を返す
function getCompetenceKeys(rowNo,rkey,wk_index){
    var competenceKeys=[];
    var move_no = $('#cargo_'+rowNo+'_move_no').val();
    switch(move_no){
    case "HB999991" : competenceKeys.push("ca");break; //配番作業
    case "HB000600" : competenceKeys.push("mt");break; //整備
    case "HB000610" : competenceKeys.push("tl");break; //道具
    default:
      var work_class = $('#cargo_'+rowNo+'_work_class').val();  //作業区分,1:本船,2:沿岸,9:休み
      var work_place = $('#cargo_'+rowNo+'_work_place').val();  //場所
      var cargo_name = $('#cargo_'+rowNo+'_cargo_name').val();  //貨物名
      var machine_cd = "";
      var machine_type = "";
      if(wk_index % 2 == 1){
        machine_cd = $("#wkACargoMachine_"+rowNo+"_"+rkey+"_"+wk_index+"_machine_cd").val();
        machine_type = $("#wkACargoMachine_"+rowNo+"_"+rkey+"_"+wk_index+"_m_type").val();
      }else{
        machine_cd = $("#wkACargoMachine_"+rowNo+"_"+rkey+"_"+(wk_index-1)+"_machine_cd").val();
        machine_type = $("#wkACargoMachine_"+rowNo+"_"+rkey+"_"+(wk_index-1)+"_m_type").val();
        if(machine_cd==""){
          machine_cd = $("#wkACargoMachine_"+rowNo+"_"+rkey+"_"+wk_index+"_machine_cd").val();
          machine_type = $("#wkACargoMachine_"+rowNo+"_"+rkey+"_"+wk_index+"_m_type").val();
        }
      }
      $('input[id^="needCount_'+rowNo+'_'+rkey+'"]').each(function(){
        if(tmpKeys = $(this).attr("id").match(new RegExp("needCount_"+rowNo+"_"+rkey+"_(\\w+)"))){
          var skey = tmpKeys[1];
          switch(skey){
          case "fm":
            if(work_place.match(/7\-3/) && cargo_name.match(/石炭灰/)){competenceKeys.push("fma");
            }else if(work_place.match(/7\-5/) && cargo_name.match(/石炭灰/)){competenceKeys.push("fmp");
            }else if(work_class=="1"){competenceKeys.push("fmm");
            }else if(work_class=="2"){competenceKeys.push("fmc");}
            break;
          case "dm":
            if(work_place.match(/6\-1/) || work_place.match(/H\-1/)){competenceKeys.push("sn");
            }else{competenceKeys.push("dm");}
            break;
          case "wm": competenceKeys.push("wwm");break;
          case "cr": //クレーン
            if(work_place.match(/3\-3/) || work_place.match(/3\-4/)){competenceKeys.push("cr3");
            }else if(work_place.match(/5\-1/)){competenceKeys.push("cr5");
            }else if(work_place.match(/6\-1/)){competenceKeys.push("cr6");
            }else if(work_place.match(/7\-1/) || work_place.match(/7\-2/)){competenceKeys.push("cr7");
            }else if(work_place.match(/H\-1/)){competenceKeys.push("cru");
            }else if(work_place.match(/O\-3/) || work_place.match(/O\-4/)){competenceKeys.push("crg");
            }else if(work_place.match(/7\-5/)){competenceKeys.push("crp");
            }else if(work_place.match(/H\-2/)){competenceKeys.push("cre");
            }else if(work_place.match(/7\-3/)){competenceKeys.push("crs");}
            break;
          case "ld": //ローダー
            if(machine_type=="" || machine_type==skey){
              if(work_class=="1"){competenceKeys.push("ldm");
              }else if(work_class=="2"){competenceKeys.push("ldc");}
            }
            break;
          case "bh": //ﾊﾞｯｸﾎｰ
            if(machine_type=="" || machine_type==skey){
              if(work_class=="1"){
                if(machine_cd.match(/ﾘｰｽﾊﾞ\d+/)){competenceKeys.push("bhs");
                }else{competenceKeys.push("bhh");}
              }
            }
            break;
          case "sl": //船内ﾛｰﾀﾞ―
            if(machine_type=="" || machine_type==skey){
              if(work_class=="1"){competenceKeys.push("slm");
              }else if(work_class=="2"){competenceKeys.push("slc");}
            }
            break;
          case "bl": //ブル(トーザー)
            if(machine_type=="" || machine_type==skey){
              if(work_class=="1" && work_place.match(/H\-1/)){competenceKeys.push("blh");
              }else{competenceKeys.push("bld");}
            }
            break;
          case "lf": //リフト
            if(machine_type=="" || machine_type==skey){
              if(work_place.match(/物流ｾﾝﾀｰ/) || work_place.match(/物流センター/)){competenceKeys.push("lfl");
              }else{competenceKeys.push("lf");}
            }
            break;
          case "sc": //ｽﾄﾗﾄﾞﾙｷｬﾘｱ
            if(machine_type=="" || machine_type==skey){
              if(work_class=="1"){competenceKeys.push("scm");
              }else if(work_class=="2"){competenceKeys.push("scc");}
            }
            break;
          case "tl": //ﾄﾗﾝｽﾌｧｰｸﾚｰﾝ
            if(machine_type=="" || machine_type=="lf"){
              if(work_class=="1"){competenceKeys.push("tlm");
              }else if(work_class=="2"){competenceKeys.push("tlc");}
            }
            break;
          case "ot": //他
            if(rkey=="dr"){
              if(move_no=="HB000595" || move_no=="HB000596" || move_no=="HB000597" || move_no=="HB000599"){
                competenceKeys.push("cc");
              }else if(cargo_name.match(/石炭/) && (work_place.match(/7\-1/) || work_place.match(/7\-2/) || work_place.match(/6\-1/) || work_place.match(/H\-1/))){
                competenceKeys.push("od");
              }else if(work_place.match(/H\-1/)){
                competenceKeys.push("ep");
              }else if(work_place.match(/H/)){
                competenceKeys.push("em");
              }
            }else if(rkey=="wk"){
              if(machine_cd.match(/ｽｲｰﾊﾟ/)){
                competenceKeys.push("sw");
              }else if(machine_cd.match(/散水/)){
                competenceKeys.push("sp");
              }else if(machine_cd.match(/掃除機/) || machine_cd.match(/三洋掃/)){
                competenceKeys.push("clr");
              }
            }
            break;
          case "hd": //作業-ハン
            if(work_place.match(/3\-3/) || work_place.match(/3\-4/)){
                competenceKeys.push("w3");
            }else if(work_place.match(/5\-1/)){
                competenceKeys.push("s5");
            }else if(work_place.match(/7\-1/) || work_place.match(/7\-2/)){
                competenceKeys.push("s7");
            }
            break;
          case "db": competenceKeys.push("wgd");break;
          case "hs": competenceKeys.push("wal");break;
          case "sn": //作業-船内
            if(work_place.match(/6\-1/) || work_place.match(/H\-1/)){
                competenceKeys.push("w6e");
            }else if(work_place.match(/3\-3/) || work_place.match(/3\-4/) || work_place.match(/5\-1/) || work_place.match(/7\-1/) || work_place.match(/7\-2/)){
                competenceKeys.push("wbg");
            }else if(work_place.match(/物流ｾﾝﾀｰ/) || work_place.match(/物流センター/)){
                competenceKeys.push("wlg");
            }else if((cargo_name.match(/ｺﾝﾃﾅ/) || work_place.match(/コンテナ/)) && (work_place.match(/O\-3/) || work_place.match(/O\-4/))){
                competenceKeys.push("wsc");
            }else{
                competenceKeys.push("wsm");
            }
            break;
          case "eg": //作業-沿岸
            if((cargo_name.match(/ｺﾝﾃﾅ/) || work_place.match(/コンテナ/)) && (work_place.match(/O\-3/) || work_place.match(/O\-4/))){
                competenceKeys.push("wcc");
            }else{
                competenceKeys.push("wc");
            }
            break;
          }
        }
      });
    }
    return competenceKeys;
}

//作業開始時間変更時に 出勤時間＝作業開始時間-30分 を反映
function changeS_Time(robj){
  var match = robj.id.match(/^cargo_(\d+)_s_time$/)
  if(match){
    var row_index = match[1];
    var s_time = $('input[id="cargo_'+row_index+'_s_time"]').val();
    if(s_time){
      var sM = strHHMMtoMinutes(s_time);
      var iM = sM - 30;
      if(iM<0){iM+=24*60;}
      $('input[id="cargo_'+row_index+'_i_time"]').val(minutesToStrHHMM(iM));
    }
  }
}

//作業開始、終了時間変更→作業時間、残業時間を算出
function calcWorkTime(robj){
  var match = robj.id.match(/^cargo_(\d+)_[e|s|i]_time$/)
  if(match){
    //cargoの作業時間、残業時間
    var row_index = match[1];
    var str_i_time = $('input[id="cargo_'+row_index+'_i_time"]').val();
    var str_s_time = $('input[id="cargo_'+row_index+'_s_time"]').val();
    var str_e_time = $('input[id="cargo_'+row_index+'_e_time"]').val();
    str_i_time = str_i_time || getCargoITime(row_index);
    str_s_time = str_s_time || getCargoSTime(row_index);
    str_e_time = str_e_time || getCargoETime(row_index);
    var defWorkTime = wkCalcWorkTime(str_i_time,str_e_time,"0");
    $(robj).parent().find('input[id$="work_time"]').val(defWorkTime["work_time"]);
    $(robj).parent().find('input[id$="orver_time"]').val(defWorkTime["orver_time"]);
    //配番済み作業員の開始、終了時間を変更
    var tObj = $("input[name^='wkACargoWorker_"+row_index+"[']input[id$='_login_id']");
    tObj.each(function(index,obj){
      if($(this).attr('id').match(/_login_id$/) && $(this).val()!=""){
        const lockFLg = $("#"+$(this).attr('id').replace(/_login_id$/,"_lock_flg")).val();
        if(lockFLg=="1"){return true;}
        var root_Panel = $("#wkAUser_"+$(this).val())
        let sTime = str_i_time;
        let eTime = str_e_time;
        let busFlg = '';

        const baseNo = root_Panel.find('input[id$="_base_no"]').val();
        if (["2", "3", "31", "32", "33", "34", "41", "42"].includes(baseNo)){
          // -- sTime
          const arrivTime = root_Panel.find('input[id$="_arriv_time"]')
          sTime = pickTime(arrivTime.val(),()=>str_i_time,'later');

          //  -- eTime
          const leavTime = root_Panel.find('input[id$="_leav_time"]')
          eTime = pickTime(leavTime.val(),()=>str_e_time,'earlier');
        }

        busFlg = $("#"+$(this).attr('id').replace(/_login_id$/,"_bus_flg")).val()
        if(sTime!='' && eTime!='' && busFlg=="1"){
          let adjSTime,adjETime;
          [adjSTime,adjETime] = adjustStimeEtimeByBusFlags(sTime,eTime,getCargoITime(row_index),busFlg)
          if(sTime!=='' && sTime!==adjSTime) sTime = adjSTime;
          if(eTime!=='' && eTime!==adjETime) eTime = adjETime;
        }
        $("#"+$(this).attr('id').replace(/_login_id$/,"_s_time")).val(sTime);
        $("#"+$(this).attr('id').replace(/_login_id$/,"_e_time")).val(eTime);

        // 所定
        if(sTime!=='' && eTime!==''){
          var PWorkTime = wkCalcPWorkTime(sTime,eTime);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_p_work_time")).val(PWorkTime["work_time"]);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_p_orver_time")).val(PWorkTime["orver_time"]);
          // 法定
          var WorkTime = wkCalcWorkTime(sTime,eTime,busFlg);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_work_time")).val(WorkTime["work_time"]);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_orver_time")).val(WorkTime["orver_time"]);
        }else{
          $("#"+$(this).attr('id').replace(/_login_id$/,"_p_work_time")).val(0);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_p_orver_time")).val(0);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_work_time")).val(0);
          $("#"+$(this).attr('id').replace(/_login_id$/,"_orver_time")).val(0);

        }
      }
    });


    //配番済み機械の稼働時間を変更
    var tObj = $("input[name^='wkACargoMachine_"+row_index+"[']input[id$='_machine_cd']");
    tObj.each(function(index,obj){
      if($(this).attr('id').match(/_machine_cd$/) && $(this).val() != ""){
        const lockFLg = $("#"+$(this).attr('id').replace(/_machine_cd$/,"_lock_flg")).val();
        if(lockFLg=="1"){return true;}

        let workTime = str_i_time!='' && str_e_time!='' ? defWorkTime["work_time"] : 0;
        $("#"+$(this).attr('id').replace(/_machine_cd$/,"_work_time")).val(workTime);
      }
    });
  }
}
//パネルリスト表示
function wkAViewPanelList(flg){
    var tBox = $("#wkA"+flg);
    if(tBox.css("display")=="none"){
        $('#wkAfoot > div[id^="wkA"]').each(function(){
          if($(this).attr("id") == "wkA"+flg){$(this).css("display","block");}
          else if($(this).attr("id") != "wkAButtons"){$(this).css("display","none");}
        });
    }else{tBox.css("display","none");}
    wkAViewNote("","");
    wkASetWkABodyOverflow()
}
//パネルリストの選択をクリア
function wkAUnsetSelectPanel(){
    if(selectedPanel!=""){
        $("#"+selectedPanel).css("backgroundColor","");
        selectedPanel = "";
        wkAViewNote("","");
    }
    wkAViewPanelList("dummy");
}
//配番の選択をクリア
function wkAUnsetSelectedAssignment(){
    if(selectedAssignment!=""){
        $("#"+selectedAssignment).css("backgroundColor","");
        selectedAssignment = "";
    }
}
//備考欄の表示／非表示
function wkANoteBoxView(row_index){
  var box = $("#noteBox_"+row_index);
  if(box.css("display")=="none"){
    box.css("display","");
  }else{
    box.css("display","none");
  }
}

//操作ロックリクエスト
function wkACargoLock(button){
  let form = document.querySelector("form[name='lock_form']")
  let formData = new FormData(form)
  fetch(
    form.action,
    {
      method: form.method,
      body: formData
    }
  ).then(
    (response)=>{
      return response.json()
    }
  ).then(
    (data)=>{
      if(data["sts"]==200){
        button.setAttribute("disabled",true)
        button.value = "ロック中"
        button.setAttribute("onclick","return false;")
      }else{
        alert("＊＊ロックに失敗しました。\n" + data["msg"])
      }
    }
  ).catch(
    err=>alert("ロックに失敗しました。")
  )
}


//パネル種別取得
function getPanelType(panelId){
  if(typeof(panelId)!='string') return "";
  if(panelId.match(/^wkACargoMachine/)) return "CargoMachinePanel";
  if(panelId.match(/^wkACargoWorker_/)) return "CargoWorkerPanel";
  if(panelId.match(/^wkAMachine_/))     return "MachinePanel";
  if(panelId.match(/^wkAUser_/))        return "UserPanel";
  return "";
}

function convMinToHour(min,round=true,round_base=1){
  let hourFloat = min / 60.0;
  if(round){
    return Math.round(hourFloat * 10**round_base)/(10**round_base);
  }else{
    return hourFloat;
  }
}


//時間の早い方、遅い方を指定して時間を返す（'earlier' or 'later'）
//引数の時間形式は文字列のHH:MM
//一方が空文字の場合は有効な時間のほうを返す
//いずれも有効な場合は比較して返し、いずれも有効でない場合は空文字を返す
function pickTime(primary,fallbackFn,prefer){
  // fallback: getCargo〜Time で取得した値
  let fallback = fallbackFn() || '';

  if (primary === '' && fallback !== '') return fallback;
  if (primary !== '' && fallback !== '') {
    if (prefer === 'later') {
      return primary < fallback ? fallback : primary;
    } else if (prefer === 'earlier') {
      return primary > fallback ? fallback : primary;
    }
  }
  return primary;

}


// -- パネル行追加機能　の関連メソッド --
// パネル行取得
function getPanelRow(type,rowIndex,colKey){
  let rowSelector = "";
  if(type === "machine"){
    rowSelector = "tr.wkACargoMachineRow";
  }else if(type === "worker"){
    rowSelector = "tr.wkACargoWorkerRow";
  }else{
    return null;
  }

  let rows = document.querySelectorAll(`#wkATbl_${rowIndex}_${colKey} ${rowSelector}`);
  return rows;
  
}
// パネル行の列数取得
function getColSize(rowIndex,workClass){
  let size = 0;
  const rows = getPanelRow("worker",rowIndex,workClass);
  if(!rows || rows.length === 0) return 0;
  return rows[0].children.length;
}
// パネル数取得（work_indexカウント用
function getPanelCount(rowIndex,workClass){
  const rows = getPanelRow("worker",rowIndex,workClass);
  if(!rows || rows.length === 0) return 0;
  const count = rows.length * getColSize(rowIndex,workClass);
  return count
}
// パネル行追加
function addPanelRow(rowIndex,workClass){
  const tTbl = $("#wkATbl_"+rowIndex+"_"+workClass);
  if(!tTbl.length) return;
  const machineRows = getPanelRow("machine",rowIndex,workClass);
  const workerRows  = getPanelRow("worker",rowIndex,workClass);
  const colSize     = getColSize(rowIndex,workClass);
  if(!machineRows.length && !workerRows.length) return;


  // テンプレートマスの初期化
  let tempWPanel = null;
  let tempMPanel = null;

  // 機械行
  if(machineRows.length){
    tempMPanel = $(machineRows[0].firstChild).clone();
    tempMPanel.find("input").each(function(){$(this).val("");})
    const newRow = document.createElement("tr");
    newRow.className = "wkACargoMachineRow";
    for(let i=0; i<colSize; i++){
      const workIndex = (machineRows.length*colSize)+(i+1);
      const idPrefix = "wkACargoMachine_" + rowIndex + "_" + workClass + "_" + workIndex;

      const outerPanel = document.createElement("td");
      outerPanel.innerHTML = tempMPanel.html().replaceAll(`${workClass}_1`,`${workClass}_${workIndex}`);
      outerPanel.querySelector("div").className = "wkAPanel";
      outerPanel.querySelector(`div>span#${idPrefix}_text`).innerText = "";
      newRow.appendChild(outerPanel);
    }
    tTbl.find("tbody").append(newRow);
  }

  // 作業員行
  if(workerRows.length){
    tempWPanel = $(workerRows[0].firstChild).clone();
    tempWPanel.find("input").each(function(){$(this).val("");})
    const newRow = document.createElement("tr");
    newRow.className = "wkACargoWorkerRow";
    for(let i=0; i<colSize; i++){
      const workIndex = (workerRows.length*colSize)+(i+1);
      const idPrefix = "wkACargoWorker_" + rowIndex + "_" + workClass + "_" + workIndex;

      const outerPanel = document.createElement("td");
      outerPanel.innerHTML = tempWPanel.html().replaceAll(`${workClass}_1`,`${workClass}_${workIndex}`);
      outerPanel.querySelector("div").className = "";
      outerPanel.querySelector(`div>span#${idPrefix}_text`).innerText = "";
      newRow.appendChild(outerPanel);
    }
    tTbl.find("tbody").append(newRow);
  }
  //画面設定
  WkASetFontSize(0);
  WkASetView();

}
//配番パネルの行追加（クリックイベントに対応
function wkACargoAddPanelRow(tblKey){
  const wkATbl = $("#"+tblKey);
  const match  = tblKey.match(/wkATbl_(\d+)_(\w+)/);
  if(!(wkATbl.length && match)) return;
  const [,rowIndex,workClass] = match; 
  addPanelRow(rowIndex,workClass);

}

//-- コピペ機能 -- 
//列選択
function wkASelectCol(robj){
  var col_key = robj.id.split("_").pop();
  if(selectedCol != ""){
    $("div[id^='wkAbody_"+selectedCol+"_']").removeClass("selectedCol");
  }
  if(selectedCol == col_key){
      selectedCol = "";
  }else{
      selectedCol = col_key;
      $("div[id^='wkAbody_"+selectedCol+"_']").addClass("selectedCol");
  }
}
//行選択
function wkASelectRow(robj){
    if(selectedRow != ""){
      $.each(boxKeys,function(index,boxKey){$("#wkAbody"+boxKey.toUpperCase()+"_row_"+selectedRow).removeClass("selectedRow");});
    }
    var row_index = robj.id.split("_").pop();
    if(selectedRow == row_index){
        selectedRow = "";
    }else{
        selectedRow = row_index;
        $.each(boxKeys,function(index,boxKey){$("#wkAbody"+boxKey.toUpperCase()+"_row_"+selectedRow).addClass("selectedRow");});
    }
}
//選択行列のコピー、または配番パネル選択時にcでコピー用に従業員／機械パネルを選択
function wkAChangeAssignmentToPanel(){
  if(selectedRow!="" || selectedCol!=""){
    if(selectedRow!="" && selectedCol!=""){ //行と列を選択
      if(cpAria["tRow"]!=""){$("div[id^='wkAbody'][id$='_row_"+cpAria["tRow"]+"']").removeClass("selectedRowCopy");}
      if(cpAria["tCol"]!=""){$("div[id^='wkAbody_"+cpAria["tCol"]+"_']").removeClass("selectedColCopy");}
      cpAria["tRow"]=selectedRow;
      wkASelectRow($("#wkAbody_no_"+selectedRow).get(0));  //行選択を解除
      cpAria["tCol"]=selectedCol;
      wkASelectCol($("#wkAhead_"+selectedCol).get(0));  //列選択を解除
      $("#wkAbody_"+cpAria["tCol"]+"_"+cpAria["tRow"]).addClass("selectedColCopy");
      selectedRow = "";
      selectedCol = "";
    }else if(selectedRow!=""){ //行を選択
      if(cpAria["tRow"]!=""){$("div[id^='wkAbody'][id$='_row_"+cpAria["tRow"]+"']").removeClass("selectedRowCopy");}
      if(cpAria["tCol"]!=""){$("div[id^='wkAbody_"+cpAria["tCol"]+"_']").removeClass("selectedColCopy");}
      cpAria["tRow"]=selectedRow;
      wkASelectRow($("#wkAbody_no_"+selectedRow).get(0));  //行選択を解除
      $("div[id^='wkAbody'][id$='_row_"+cpAria["tRow"]+"']").addClass("selectedRowCopy");
      cpAria["tCol"]=""
      selectedRow = "";
      selectedCol = "";
    }
  
  }else if(selectedAssignment!=""){
    if(selectedAssignment.match(/^wkACargoMachine_/)){
      var machine_id = $("#"+selectedAssignment+"_machine_id").val();
      if(machine_id!=""){
        wkAUnsetSelectedAssignment();
        wkASelectMachine($("#wkAMachine_"+machine_id).get(0));
      }
    }else if(selectedAssignment.match(/^wkACargoWorker_/)){
      var login_id = $("#"+selectedAssignment+"_login_id").val();
      if(login_id!=""){
        wkAUnsetSelectedAssignment();
        wkAUnSetChooseableUser();
        wkASelectUser($("#wkAUser_"+login_id).get(0));
      }
    }
  }
}
//コピーした行列のペースト
function wkAPasteAriaToPanel(){

  // 対象パネルを検索、無ければ行追加
  const findPanelIfNotExistInsertRow = (type,rowIndex,colKey,workIndex)=>{
    let tForm = null;
    if(type === "Machine"){
      tForm = $("#wkACargoMachine_"+rowIndex+"_"+colKey+"_"+workIndex+"_machine_id");
    }else if(type === "Worker"){
      tForm = $("#wkACargoWorker_"+rowIndex+"_"+colKey+"_"+workIndex+"_login_id");
    }
    if(tForm.length) return tForm;

    // 行が足りない場合は行追加
    addPanelRow(rowIndex,colKey);
    if(type === "Machine"){
      tForm = $("#wkACargoMachine_"+rowIndex+"_"+colKey+"_"+workIndex+"_machine_id");
    }else if(type === "Worker"){
      tForm = $("#wkACargoWorker_"+rowIndex+"_"+colKey+"_"+workIndex+"_login_id");
    }
    return tForm;
  }

  if(cpAria["tRow"]!=""){
    if(selectedRow!="" && cpAria["tRow"]!=selectedRow){
      //現在の選択をクリア
      selectedAssignment = "";
      unSetting = true;
      if(cpAria["tCol"]==""){  //行をコピー
        //機械行
        reg = new RegExp("^wkACargoMachine_"+cpAria["tRow"]+"_(.+)_(\\d+)_machine_id$");
        $("input[id^='wkACargoMachine_"+cpAria["tRow"]+"'][id$='_machine_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            // tForm = $("#wkACargoMachine_"+selectedRow+"_"+idx[1]+"_"+idx[2]+"_machine_id");
            tForm = findPanelIfNotExistInsertRow("Machine",selectedRow,idx[1],idx[2]);
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAMachine_"+$(this).val();
                forceEventCancel = true;
                wkASetMachine(tForm.parent().get(0),false);
                forceEventCancel = false;
              }
            }
          }
        });


        //現業職行
        reg = new RegExp("^wkACargoWorker_"+cpAria["tRow"]+"_(.+)_(\\d+)_login_id$");
        $("input[id^='wkACargoWorker_"+cpAria["tRow"]+"'][id$='_login_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            // tForm = $("#wkACargoWorker_"+selectedRow+"_"+idx[1]+"_"+idx[2]+"_login_id");
            tForm = findPanelIfNotExistInsertRow("Worker",selectedRow,idx[1],idx[2]);
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAUser_"+$(this).val();
                forceEventCancel = true;
                wkASetWorker(tForm.parent().get(0),false);
                forceEventCancel = false;
              }
            }
          }
        });
        //後始末
        $("div[id^='wkAbody_"+selectedCol+"_']").removeClass("selectedColCopy");  //列選択を解除

      }else{//指定行列エリアのみコピー
        var fAria = $("#wkAbody_"+cpAria["tCol"]+"_"+cpAria["tRow"]);
        //機械行
        reg = new RegExp("^wkACargoMachine_"+cpAria["tRow"]+"_"+cpAria["tCol"]+"_(\\d+)_machine_id$");
        fAria.find("input[id^='wkACargoMachine_'][id$='_machine_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            // tForm = $("#wkACargoMachine_"+selectedRow+"_"+cpAria["tCol"]+"_"+idx[1]+"_machine_id");
            tForm = findPanelIfNotExistInsertRow("Machine",selectedRow,cpAria["tCol"],idx[1]);
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAMachine_"+$(this).val();
                forceEventCancel = true;
                wkASetMachine(tForm.parent().get(0),false);
                forceEventCancel = false;
              }
            }
          }
        });
        //現業職行
        reg = new RegExp("^wkACargoWorker_"+cpAria["tRow"]+"_"+cpAria["tCol"]+"_(\\d+)_login_id$");
        fAria.find("input[id^='wkACargoWorker_'][id$='_login_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            // tForm = $("#wkACargoWorker_"+selectedRow+"_"+cpAria["tCol"]+"_"+idx[1]+"_login_id");
            tForm = findPanelIfNotExistInsertRow("Worker",selectedRow,cpAria["tCol"],idx[1]);
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
                
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAUser_"+$(this).val();
                forceEventCancel = true;
                wkASetWorker(tForm.parent().get(0),false);
                forceEventCancel = false;
              }
            }
          }
        });
        //後始末
        fAria.css("backgroundColor","");
        $("div[id^='wkAbody_"+selectedCol+"_']").removeClass("selectedColCopy");  //列選択を解除
        selectedCol = "";
        
      }

      // お掃除
      $(".selectedCol, .selectedRow").removeClass("selectedCol selectedRow");
      $(".selectedColCopy, .selectedRowCopy").removeClass("selectedColCopy selectedRowCopy");
      selectedRow = "";selectedCol = "";
      cpAria = {"tRow":"","tCol":""};  //選択情報をクリア
      selectedAssignment = "";
      unSetting = false;
      wkAViewPanelList("dummy");
    }
  }

}


//サブ画面を閉じる
function wkAConfirmCloseSubWindow(){
  if(!subW){ return true };
  if(confirm("サブ画面を開いています。\nサブ画面を閉じて処理を実行しますか？")){
    subW.close();
    return true;
  }else{
    return false;
  }
}

// 作業番号(work_index)を再割当
function wkARenumberWorkIndexes(){
  const [selected,targetId] = tmpTargetId;
  const rootPanel = $("#" + selected || "");
  if(!rootPanel.length) return;
  const match = selected.match(/^(wkACargoMachine|wkACargoWorker)_(\d+)+_(\w+)_(\d+)/)
  if(!match) return;
  const [,panelType,rowIndex,key,workIndex] = match;

  let targetPanels;
  if(panelType === "wkACargoMachine"){
    targetPanels = $(`input[id^='wkACargoMachine_'][id$='_machine_id'][value='${targetId}']`);
  }else if(panelType === "wkACargoWorker"){
    targetPanels = $(`input[id^='wkACargoWorker_'][id$='_login_id'][value='${targetId}']`);
  }
  if(!targetPanels.length) return;

  // work_index要素を取得してソート
  const sortedWorkIndexEl = targetPanels
    .map(function(){ return $(this).siblings("input[id$='_work_index']").get(0); })
    .sort((a, b) => a.value - b.value);

  // 再割当とテキスト更新
  sortedWorkIndexEl.each(function(i){
    const $el = $(this);
    const $text = $el.siblings("span[id$='_text']");
    const plainText = $text.text().replace(/[()]/g, "");
    if(plainText!==""){
      $text.text(i === 0 ? plainText : `(${plainText})`);
      $el.val(i);
    }
  });
  tmpTargetId = [];
}