//グローバル変数
let selectedPanelArr = []
//OnLoadイベント
$(function(){RzAssignmentinit();});
$(document).on('turbolinks:load', function() {RzAssignmentinit();});
function RzAssignmentinit(){
  $("#msgBox").text("パネル初期化中").css("display","block");
  def_font_size = document.setting_data.def_font_size.value -0;
  eval("def_tbl_setting="+document.setting_data.str_tbl_setting.value);


  //作業日テーブルに文字サイズ大小ボタンを追加
  WkAAddTDateTbl2Button();

  //ウィンドウの初期化
  observer = new Observer;
  observer.addObserver(window);
  obsWkASetWorker = observer.observerFunction(wkASetWorker,window,null);
  obsWkASelectUser = observer.observerFunction(wkASelectUser,window,null);
  obsWkASetMachine = observer.observerFunction(wkASetMachine,window,null);
  obsWkASelectMachine = observer.observerFunction(wkASelectMachine,window,null);
  obsWkSetWorkerInfo = observer.observerFunction(wkSetWorkerInfo,window,null);
  obsWkAUnSetAssignment = observer.observerFunction(wkAUnSetAssignment,window,null);
  obsWkASetLock = observer.observerFunction(wkASetLock,window,null);
  obsWkACargoAddPanelRow = observer.observerFunction(wkACargoAddPanelRow,window,null);
  obsWkASelectCol = observer.observerFunction(wkASelectCol,window,null);
  obsWkASelectRow = observer.observerFunction(wkASelectRow,window,null);
  obsWkAChangeAssignmentToPanel = observer.observerFunction(wkAChangeAssignmentToPanel,window,null);
  obsWkAPasteAriaToPanel = observer.observerFunction(wkAPasteAriaToPanel,window,null);

  //画面サイズ変更時イベント追加
  $(window).resize(function(){WkASetView();});
  $(window).on('orientationchange', function(e){WkASetView();});
  //キーボードイベント追加
  $(window).keydown(function(e){
    switch(e.keyCode){
      case 27 : //Esc
        $("#wkAInfoBox").css("display","none");
        wkAUnsetSelectPanel();
        wkAUnsetSelectedAssignment();
        clearSelectedPanelArr();
        break;
      case 8 : //Backsoace
      case 46 : //Delete
        let infoBox = document.querySelector('#wkAInfoBox')
        if(infoBox&&infoBox.style.display=='block'){break;}
        wkAUnSetAssignment();
        
        break;
      case 67 : //c
        obsWkAChangeAssignmentToPanel(window);
        break;
      case 86 : //v
        if(cpAria["tRow"]!=""){obsWkAPasteAriaToPanel(window);}
        break;

      //default:
      //  console.log("keydown:"+e.keyCode);
    }

  });
  setTimeout(function(){
    $("html").css("cursor","wait");
    WkAInitData();
    $("input.wkAnoteField:visible").each(function(){
      $(this).attr("type","hidden");
      var memoObj = $('<span>',{text: $(this).val()});
      memoObj.appendTo($(this).parent());
    });
    if(window.localStorage){
      WkASetFontSize(window.localStorage.getItem("onakai_wk_assignment_font_flg")-0);
      if(window.localStorage.getItem("onakai_wk_assignment_hf_hidden_flg")){WkASwitchVisibleHF(false)}
    }
    $("#msgBox").css("display","none");
    $("html").css("cursor","auto");
  },300);
}
//パネルの初期化＆臨時・人のカウント
function WkAInitData(){
    var cargo_count = document.inform.cargo_count.value-0;
    //各列のデータ初期化
    var inputs = document.querySelectorAll("#wkAbody input[id^='wkACargo']");
    for(var row_index=0;row_index<cargo_count;row_index++){
        $.each(AssignmentBlocks,function(index,pkey){
            // var tObj = $("input[name^='wkACargoWorker_"+row_index+"["+pkey+"']input[id$='_login_id']");
            var tObj = Array.from(inputs).filter(function(input) {
              return input.name.startsWith('wkACargoWorker_' + row_index + '[' + pkey) && input.id.endsWith('_login_id');
            });
            // tObj.each(function(index,obj){
            for(const obj of tObj){
              const jq_obj = $(obj)
              if(jq_obj.attr('id').match(/_login_id$/) && jq_obj.val() != ""){
                  selectedPanel = "wkAUser_"+jq_obj.val();
                  var assignment = $("#"+jq_obj.attr('id').replace(/_login_id$/,""));
                  wkASetWorkerInit(assignment.get(0));
                  if(assignment.attr("class").includes("wkAIsHoliday")){
                    assignment.removeClass("wkAIsHoliday").addClass("wkAIsErr");
                  }
              }
            };
            // tObj = $("input[name^='wkACargoMachine_"+row_index+"["+pkey+"']input[id$='_machine_id']");
            // wkACargoMachine_0[wk_1_machine_id]
            // wkACargoMachine_3[wk_10_machine_id]
            // wkACargoMachine_0_wk_1_machine_id
            // var tObj2 = Array.from(inputs).filter(function(input) {
            //   return input.name.startsWith('wkACargoMachine_' + row_index + '[' + pkey) && input.id.endsWith('_machine_id');
            // });
            // Array.from(inputs).forEach((input)=>{
            //   const match = input.name.match(/wkACargoMachine_(\d)+\[([a-z]+)_\d+_machine_id\]/);
            //   if(match && input.value!="" && match[1]==String(row_index)){
            //     console.log(match,row_index,pkey)
            //   }
            // })

            var tObj2 = Array.from(inputs).filter((input)=>{
              const match = input.name.match(/wkACargoMachine_(\d)+\[([a-z]+)_\d+_machine_id\]/);
              if(input.value=="" || !match) return false;
              const [,rowI,key] = match;
              if(rowI==row_index && key==pkey) return true;
              return false; 
            })

            for(const obj of tObj2){
              // tObj.each(function(index,obj){
                const jq_obj = $(obj)
                if(jq_obj.attr('id').match(/_machine_id$/) && jq_obj.val() != ""){
                    selectedPanel = "wkAMachine_"+jq_obj.val();
                    var assignment = $("#"+jq_obj.attr('id').replace(/_machine_id$/,""));
                    wkASetMachineInit(assignment.get(0));
                    if(assignment.attr("class").includes("wkAIsHoliday")){
                      assignment.removeClass("wkAIsHoliday").addClass("wkAIsErr");
                    }
                }
            };
        });
        selectedPanel ="";
        //行毎臨時・人のカウント
        // WkARowReCount(row_index,false);
        //成約フラグを非表示
        $("#wkAbodyR_row_"+row_index+" div.radiobox").css("display","none");
        //コメントアイコンを非表示
        $("#wkAbodyR_row_"+row_index+" i.fa-pen-to-square").css("display","none");
    }
    //全チェック
    //wkACkAllAssignment();
    //フッタの各ボタン非表示
    $("#wkAButtons input[type='button']").each(function(){
      if($(this).val()=="FM前CP" || $(this).val()=="DM前CP" || $(this).val()=="自動配番"){
        $(this).css("display","none");
      }
    });
    //配番確定→文言変更
    $("#wkAButtons div.checkboxBtn label").text("実績確定");
    
    var tDateTbl = document.getElementById("tDateTbl");
    var newRow = document.createElement('tr');
    var newCell = document.createElement('td');
    newCell.className = "listC";
    newCell.colSpan=4
    newCell.style.padding = "5px";
    var newElement = document.createElement("input");
    newElement.type="button";
    if(!hasData){
      newElement.value = "配番データ取込み";
    }else{
      newElement.value = "配番データ再取込み";
    }
    newElement.setAttribute('onclick', 'rzDoCopy()');
    newElement.style.padding = "5px";
    newCell.appendChild(newElement);
    newRow.appendChild(newCell);
    tDateTbl.appendChild(newRow);
}
//配番データ取込み
function rzDoCopy(){
    var msg="";
    if(document.inform.cargo_count.value!="0"){
      if(!window.confirm("再取込みを行うと初期化されます。\nよろしいですか？")){
        return false;
      }
    }
    $("html").css("cursor","wait");
    $("#msgBox").text("配番データ取込みを開始します。").css("display","block");
    var fobj = document.create_form;
    $.ajax({
      url: fobj.action,
      type: fobj.method,
      data: $(fobj).serialize(),
      cache: false,
      dataType: 'json',
    }).done(function(data) {
      $("#msgBox").html(data["msg"]);
      if(data["sts"]==303){setTimeout(function(){ckJob();},3000);}
      else{
        $("html").css("cursor","auto");
        msg = data["msg"];
        msg += "<br /><br /><br /><input type='button' value='閉じる' onclick='$(\"#msgBox\").css(\"display\",\"none\");' />";
        $("#msgBox").html(msg);
      }
    }).fail(function() {$("html").css("cursor","auto");alert('実行エラー1');
    }).always(function() {});
}


//バス
function machineTypeOf(machine_id,type){
  let match = machine_id.match(/wkAMachine_\w+/)
  if(!match){return}
  let panel = $(machine_id + "_m_type")
  if(!panel){return false}
  return panel.val() == type
}


//配番からはがす
function wkAUnSetAssignment(renumber=true){
  if(selectedAssignment!=""){
    if(selectedAssignment.match(/^wkACargoMachine_/)){
      let match = selectedAssignment.match(/^wkACargoMachine_(\d+)_(\w+)_(\d+)$/)
      let box_index = match[1];
      let rkey = match[2];
      let wk_index = match[3];

      var machine_id = $("#"+selectedAssignment+"_machine_id").val();
      var assignments = $("input[name='wkAMachine_"+machine_id+"[assignments]'");
      if(assignments.length){
        assignments.val(assignments.val().replace("|"+selectedAssignment+"|",""));
        strassignments=assignments.val();
        if(strassignments==""){
          $("#wkAMachine_"+machine_id).css("backgroundColor","");
          $("#wkAMachine_"+machine_id).removeClass("wkAIsAssigned");
        }
      }
      $("#"+selectedAssignment+" input").val("");
      tmpTargetId = [selectedAssignment,machine_id];
      if(renumber){
        wkARenumberWorkIndexes();
      }
    // --
    // はがす機械がバスの場合、直下の配番作業員のバスフラグを外す＋勤怠再計算
    if(machineTypeOf("#wkAMachine_"+machine_id,'bs')){
      // 直下の作業員パネルを取得
      let root_panel_id = "#wkACargoWorker_"+box_index+"_"+rkey+"_"+wk_index
      let login_id = $(root_panel_id+"_login_id").val();
      if(login_id!="" && login_id!=undefined){ // 割当の有無を判定
        // バスフラグを削除
        let cargoWorkerPanel = document.querySelector(root_panel_id)
        wkViewWorkerInfo(cargoWorkerPanel,"wk")
        let busFlgBox = document.querySelector("div#wkAInfoBox form input[name='bus_flg']")
        if(busFlgBox){
          busFlgBox.checked = false;
          wkAdjustWorkerInfoByBusFlg(busFlgBox);
          wkSetWorkerInfo(busFlgBox);
        }
      }
    }

    // --

    }else if(selectedAssignment.match(/^wkACargoWorker_/)){
      var login_id = $("#"+selectedAssignment+"_login_id").val();
      var assignments = $("input[name='wkAUser_"+login_id+"[assignments]'");
      if(assignments.length){
        assignments.val(assignments.val().replace("|"+selectedAssignment+"|",""));
        strassignments=assignments.val();
        if(strassignments==""){
          $("#wkAUser_"+login_id).css("backgroundColor","");
          $("#wkAUser_"+login_id).removeClass("wkAIsAssigned");
        }
      }
      $("#"+selectedAssignment+" input").val("");
      var tmp = selectedAssignment.split("_");
      tmpTargetId = [selectedAssignment,login_id];
      if(renumber){
        wkARenumberWorkIndexes();
      }
      // if(tmp.length > 1){WkARowReCount((tmp[1] -0),false);}
    }
    $("#"+selectedAssignment).css("backgroundColor","").attr("class","wkAPanel");
    $("#"+selectedAssignment+"_text").text("");
    $("#wkAInfoBox").css("display","none");
    selectedAssignment="";
  }
}
//作業者パネルリストから選択
function wkASelectUser(robj){
  const evt = event;
  if(evt && isModifiedEvent(evt)){
    if(isAltEvent(evt)){
      $("#"+selectedPanel).css("backgroundColor","");;
      $("#"+selectedPanel).removeClass("wkAIsAssigned");
      selectedPanel = "";
      $("#" + selectedAssignment).css("backgroundColor","");
      $("#" + selectedAssignment).removeClass("wkAIsAssigned");
      selectedAssignment="";
      pushSeletedPanelArr(robj)
    }
    return;
  }
  clearSelectedPanelArr();

  if(selectedPanel!=""){$("#"+selectedPanel).css("backgroundColor","");}
  selectedPanel = robj.id;
  $("#"+selectedPanel).css("backgroundColor","yellow");
  if(selectedAssignment.match(/^wkACargoWorker_/) ){
    //配番パネルの作業員選択がある→入れ替える
    wkASetWorker($("#"+selectedAssignment).get(0),true);
  }
}
//機械パネルリストから選択
function wkASelectMachine(robj){
  const evt = event;
  if(evt && isModifiedEvent(evt)){
    if(isAltEvent(evt)){
      $("#"+selectedPanel).css("backgroundColor","");
      selectedPanel = "";
      $("#" + selectedAssignment).css("backgroundColor","");
      selectedAssignment="";

      pushSeletedPanelArr(robj)
    }
    return;
  }
  clearSelectedPanelArr();

  if(selectedPanel!=""){$("#"+selectedPanel).css("backgroundColor","");}
  selectedPanel = robj.id
  $("#"+selectedPanel).css("backgroundColor","yellow");
  if(selectedAssignment.match(/^wkACargoMachine_/) ){
    //配番パネルの作業員選択がある→入れ替える
    wkASetMachine($("#"+selectedAssignment).get(0),true);
  }
}


//配番-作業員パネルクリック
function wkASetWorker(robj,withoutLock,continuous=false,renumber=true){
  // 作業員タブ表示
  if((selectedPanel=="" || selectedPanel.match(/wkAUser_/)) && $("#wkAWorkers").css("display")=="none"){
  // if($("#wkAWorkers").css("display")=="none" && selectedAssignment && selectedAssignment.match(/wkAMachine_/)){
    wkAChangeViewWokerGroup();
  }

  const evt = event;
  const inContinue = continuous;
  const eventCancel = forceEventCancel;
  // 修飾キー押下時
  if(!inContinue && evt && isModifiedEvent(evt) && !eventCancel){
    // 一括貼り付け
    if(isAltEvent(evt)){
      const isUserList = selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]=="wkAUser";
      if(!isUserList) return;
      const confirmMsg = `選択済みユーザー${selectedPanelArr.length}名を一括貼り付けしますか？\n対象ユーザ:${selectedPanelArr.map(robj=>{return `「${robj.innerHTML.substr(0,3)}」`})}`;
      if(confirm(confirmMsg)){
        evt.altKey = false;
        setAllSelectedPanel(robj,wkASetWorker,1);
      };
    };
    // 情報フォームの表示
    if(isCtrlEvent(evt)){
      if($("#"+robj.id+"_login_id").val() =="") return;
      wkViewWorkerInfo(robj,"rz");
    };
    return;
  }
  clearSelectedPanelArr();

  const tmpSelectedPanel = selectedPanel;
  if(selectedAssignment!=robj.id && selectedAssignment.match(/^wkACargoWorker_/)){
    //作業員の入れ替え
    var fData = {
      "assignmentId": selectedAssignment,
      "login_id": $("#"+selectedAssignment+"_login_id").val(),
      "box": $("#"+selectedAssignment),
      "work_index" : $("#"+selectedAssignment+"_work_index").val()
    };
    var tData = {
      "assignmentId": robj.id,
      "login_id": $("#"+robj.id+"_login_id").val(),
      "box": robj,
      "work_index" : $("#"+robj.id+"_work_index").val()
    };

    //一旦どちらもはがす
    wkAUnSetAssignment(false);
    selectedAssignment=robj.id;
    wkAUnSetAssignment(false);
    selectedAssignment="";

    if(fData["login_id"]!=""){
      //元の作業員を選択し、先パネルをクリック
      tmpWorkIndex = fData["work_index"];
      selectedPanel = "wkAUser_"+fData["login_id"];
      wkASetWorker($("#"+tData["assignmentId"]).get(0),false);
      tmpWorkIndex = null;
    }
    if(tData["login_id"]!=""){
      //先の作業員を選択し、元パネルをクリック
      tmpWorkIndex = tData["work_index"];
      selectedPanel = "wkAUser_"+tData["login_id"];
      wkASetWorker($("#"+fData["assignmentId"]).get(0),false);
      tmpWorkIndex = null;
    }

    // 機械パネルが選択されていた場合、選択状態を復元
    if(getPanelType(tmpSelectedPanel)=="MachinePanel"){
      selectedPanel = tmpSelectedPanel;
      $("#"+selectedPanel).css("backgroundColor","yellow");
      if($("#wkAWorkers").css("display")=="none") wkAChangeViewMachineGroup();
      
    }

  }else{
    if(login_id = selectedPanel.match(/^wkAUser_(\w+)/)){
      var bc_login_id = ""
      var bc_work_index = ""
      var bc_text = ""
      //まずはがす
      if($("#"+robj.id+"_login_id").val()!=""){
        selectedAssignment = robj.id
        bc_login_id = $("#"+robj.id+"_login_id").val();
        bc_work_index = $("#"+robj.id+"_work_index").val();
        bc_text = $("#"+robj.id+"_text").text();
        wkAUnSetAssignment(renumber);
      }
      //値を設定
      $("#"+robj.id+"_login_id").val(login_id[1]);
      var root_Panel = $("#"+selectedPanel);
      if(root_Panel.length){
        $("#"+robj.id+"_text").text(root_Panel.text());
        robj.className = root_Panel.attr("class");
        root_Panel.css("backgroundColor","");
        root_Panel.addClass("wkAIsAssigned");
        $("#"+robj.id+"_user_id").val(root_Panel.find('input[id$="_user_id"]').val());
        if(tmp = robj.id.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)){
          var box_index = tmp[1];
          var rkey = tmp[2];
          var wk_index = tmp[3];
          //作業区分
          $("#"+robj.id+"_work_class").val($("#cargo_"+box_index+"_work_class").val());
          //担当作業
          switch(rkey){
          case "fm":
          case "dm":
            $("#"+robj.id+"_wk_class").val(rkey);
           break;
          default:
            var needCount =$("input[id^='needCount_"+box_index+"_"+rkey+"_']");
            if(needCount.length == 1){
              var key = needCount.attr("id").replace("needCount_"+box_index+"_"+rkey+"_","");
              $("#"+robj.id+"_wk_class").val(key);
            }else{
              var m_type1 =$("#wkACargoMachine_"+box_index+"_"+rkey+"_"+wk_index+" input[id$='_m_type']").val();
              if(m_type1!="" && typeof m_type1 !=='undefined'){
                $("#"+robj.id+"_wk_class").val(m_type1);
              }else{
                var m_type2 =$("#wkACargoMachine_"+box_index+"_"+rkey+"_"+(wk_index-1)+" input[id$='_m_type']").val();
                if(m_type2!="" && typeof m_type2 !=='undefined'){
                  $("#"+robj.id+"_wk_class").val(m_type2);
                }else{
                  //$("#"+robj.id+"_wk_class").val("");
                }
              }
            }
            break;
          }
          //力量
          var competenceKey = wkSelectCompetenceKey($("#"+robj.id+"_wk_class").val(),getCompetenceKeys(box_index,rkey,wk_index));
          if(competenceKey!=""){
            $("#"+robj.id+"_competence").val(root_Panel.find('input[id$="_competence_'+competenceKey+'"]').val());
          }else{
            $("#"+robj.id+"_competence").val("3");
          }
          //バス
          if($("#wkACargoMachine_"+box_index+"_"+rkey+"_"+wk_index+" input[id$='_m_type']").val() == "bs"){
            $("#"+robj.id+"_bus_flg").val("1");
          }else{
            $("#"+robj.id+"_bus_flg").val("0");
          }
          if(bc_login_id=="" || login_id[1]!=bc_login_id){ //はがした作業員と設定する作業員が異なる
            // 同作業員のマスカウントと作業順の設定
            var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
            if(assignmentForm.length){
              var work_index = null;
              if(tmpWorkIndex){
                work_index = tmpWorkIndex;
              }else{
                // --
                var wokerDiv = document.getElementById(selectedPanel);
                var wokerPanel = new ResourcePanel(wokerDiv);
                var workIndexes = wokerPanel.getAssignPanel().map((p)=>{return p.getValue("work_index")});
                var nextWorkIndex = 0; // 初期化
                if(workIndexes.length>0){
                  numberList = workIndexes.map((n)=>Number(n));
                  nextWorkIndex = Math.max(...numberList) + 1;
                }
                work_index = nextWorkIndex;

              }
              $("#"+robj.id+"_work_index").val(work_index);
            }else{
              $("#"+robj.id+"_work_index").val("0");
            }


            // ========== work_index のカウント、設定（） =========== 
            if($("#"+robj.id+"_work_index").val()-0 > 0){
              $("#"+robj.id+"_text").text("("+root_Panel.text()+")");
            }
          }else{
            $("#"+robj.id+"_work_index").val(bc_work_index);
            $("#"+robj.id+"_text").text(bc_text);
          }
          var s_time = getCargoITime(box_index) || '';
          var e_time = getCargoETime(box_index) || '';

          //2,3,31,32,33,34 => s_time = arriv_time, e_time = leav_time
          let vacationData = root_Panel.find('input[id$="_base_no"]')
          if(vacationData && ["2","3","31","32","33","34","41","42"].includes(vacationData.val())){
            // -- s_time
            let arrivData = root_Panel.find('input[id$="_arriv_time"]');
            if(arrivData && arrivData.val()){
              s_time = pickTime(arrivData.val(),()=>s_time,'later');
            }

            //  -- e_time
            let leavData = root_Panel.find('input[id$="_leav_time"]');
            if(leavData && leavData.val()){
              e_time = pickTime(leavData.val(),()=>e_time,'earlier');
            }
          }

          //就業時間＆超過時間等を算出
          const busFlg = $("#"+robj.id+"_bus_flg").val();
          if(s_time!='' && e_time!='' && busFlg=="1"){
            const [adjStime,adjEtime] = adjustStimeEtimeByBusFlags(s_time,e_time,getCargoITime(box_index),busFlg)
            s_time = adjStime
            e_time = adjEtime
          }
          $("#"+robj.id+"_s_time").val(s_time);
          $("#"+robj.id+"_e_time").val(e_time);

          if(s_time!='' && e_time!=''){
            // 所定
            var PWorkTime = wkCalcPWorkTime(s_time,e_time);
            $("#"+robj.id+"_p_work_time").val(PWorkTime["work_time"]);
            $("#"+robj.id+"_p_orver_time").val(PWorkTime["orver_time"]);
            // 法定
            var WorkTime = wkCalcWorkTime(s_time,e_time,busFlg);
            $("#"+robj.id+"_work_time").val(WorkTime["work_time"]);
            $("#"+robj.id+"_orver_time").val(WorkTime["orver_time"]);
          }else{
            $("#"+robj.id+"_p_work_time").val(0);
            $("#"+robj.id+"_p_orver_time").val(0);
            $("#"+robj.id+"_work_time").val(0);
            $("#"+robj.id+"_orver_time").val(0);
          }
        }
      }
      
      var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
      if(assignmentForm.length){
        assignmentForm.val(assignmentForm.val()+"|"+robj.id+"|");
      }
      selectedPanel = "";
      selectedAssignment = "";
      $('#' + robj.id).css('backgroundColor',"");

      // 背景色黄色のままになる事象対策
      const yellowElems = Array.from(document.querySelectorAll('[style]')).filter(el =>
        el.style.backgroundColor === 'rgb(255, 255, 0)'
      );
      if(yellowElems) $(yellowElems).css("backgroundColor","");



    }else{
      $("#" + selectedAssignment).css("backgroundColor","");
      selectedAssignment = robj.id;
      $("#"+selectedAssignment).css("backgroundColor","yellow");
    }
  }

}
//配番-機械パネルクリック→結果入力
function wkASetMachine(robj,withoutLock,continuous=false){
  // 機械タブ表示
  if((selectedPanel=="" || selectedPanel.match(/wkAMachine_/)) && $("#wkAMachines").css("display")=="none") {
    wkAChangeViewMachineGroup();
  }


  const evt = event;
  const inContinue = continuous;
  const eventCancel = forceEventCancel;
  // 修飾キー押下時
  if(!inContinue && evt && isModifiedEvent(evt) && !eventCancel){
    // 一括貼り付け
    if(isAltEvent(evt)){
      const isMachineList = selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]=="wkAMachine";
      if(!isMachineList) return;
      const confirmMsg = `選択済み機械${selectedPanelArr.length}個を一括貼り付けしますか？\n対象機械:${selectedPanelArr.map(robj=>{return `「${robj.innerHTML.substr(0,robj.innerHTML.indexOf("<"))}」`})}`;
      if(confirm(confirmMsg)){
        evt.altKey = false;
        setAllSelectedPanel(robj,wkASetMachine,1);
      }
    };
    // 情報フォーム表示
    if(isCtrlEvent(evt)){
      if($("#"+robj.id+"_machine_cd").val() == "") return;
      wkViewMachineInfo(robj,"rz");
    };
    return;
  };
  clearSelectedPanelArr();

  const tmpSelectedPanel = selectedPanel;
  if(selectedAssignment!=robj.id && selectedAssignment.match(/^wkACargoMachine_/)){
    //機械入の入れ替え
    var fData = {
      "assignmentId": selectedAssignment,
      "machine_id": $("#"+selectedAssignment+"_machine_id").val(),
      "box" : $("#"+selectedAssignment),
      "work_index" : $("#"+selectedAssignment+"_work_index").val()
    };
    var tData = {
      "assignmentId": robj.id,
      "machine_id": $("#"+robj.id+"_machine_id").val(),
      "box" : robj,
      "work_index" : $("#"+robj.id+"_work_index").val()
    };
    //一旦どちらもはがす
    wkAUnSetAssignment(false);
    selectedAssignment = robj.id;
    wkAUnSetAssignment(false);
    selectedAssignment = "";

    if(fData["machine_id"]!=""){
      //元の機械を選択し、先パネルをクリック
      tmpWorkIndex = fData["work_index"];
      selectedPanel = "wkAMachine_"+fData["machine_id"];
      wkASetMachine($("#"+tData["assignmentId"]).get(0),false);
      tmpWorkIndex = null;
    }
    if(tData["machine_id"]!=""){
      tmpWorkIndex = tData["work_index"];
      //先の機械を選択し、元パネルをクリック
      selectedPanel = "wkAMachine_"+tData["machine_id"];
      wkASetMachine($("#"+fData["assignmentId"]).get(0),false);
      tmpWorkIndex = null;
    }

    // 機械パネルが選択されていた場合、選択状態を復元
    if(getPanelType(tmpSelectedPanel)=="UserPanel"){
      selectedPanel = tmpSelectedPanel;
      $("#"+selectedPanel).css("backgroundColor","yellow");
      if($("#wkAWorkers").css("display")=="none") wkAChangeViewWokerGroup();
    }


  }else{
    if(machine_id = selectedPanel.match(/^wkAMachine_(\w+)/)){
      //まずはがす
      if($("#"+robj.id+"_machine_id").val()!=""){ //選択配番パネルに機械割当済みなら
        selectedAssignment = robj.id
        wkAUnSetAssignment();
      }
      //値を設定
      $("#"+robj.id+"_machine_id").val(machine_id[1]);
      var root_Panel = $("#"+selectedPanel);
      if(root_Panel.length){
        $("#"+robj.id+"_text").text(root_Panel.text());
        robj.className = root_Panel.attr("class");
        root_Panel.css("backgroundColor","");
        root_Panel.addClass("wkAIsAssigned");

        var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
        if(assignmentForm.length){
          let work_index = null;
          if(tmpWorkIndex){
            work_index = tmpWorkIndex;
          }else{
            var machineDiv = document.getElementById(selectedPanel);
            var machinePanel = new ResourcePanel(machineDiv);
            var workIndexes = machinePanel.getAssignPanel().map((p)=>{return p.getValue("work_index")});
            var nextWorkIndex = 0; // 初期化
            if(workIndexes.length>0){
              numberList = workIndexes.map((n)=>Number(n));
              nextWorkIndex = Math.max(...numberList) + 1;
            }
            work_index = nextWorkIndex;
          }
          $("#"+robj.id+"_work_index").val(work_index);

          // ========== work_index のカウント、設定（） =========== 
          if(work_index>0){
            $("#"+robj.id+"_text").text("("+$("#"+robj.id+"_text").text()+")");
          }
          assignmentForm.val(assignmentForm.val()+"|"+robj.id+"|");
        }

        $("#"+robj.id+"_machine_cd").val(root_Panel.find('input[id$="_cd"]').val());
        $("#"+robj.id+"_m_type").val(root_Panel.find('input[id$="_m_type"]').val());
        if(tmp = robj.id.match(/^wkACargoMachine_(\d+)_.*/)){
          $("#"+robj.id+"_work_time").val($("#cargo_"+tmp[1]+"_work_time").val());
        }
        $("#"+robj.id+"_maintenanc_type").val("");
        $("#"+robj.id+"_e_date").val("");
        $("#"+robj.id+"_note").val("");
        wkViewMachineInfo(robj,"rz");
        
        //機械入れ替えで担当作業、バス手当等が変わるので影響範囲を再設定
        if(tmp = robj.id.match(/^wkACargoMachine_(\d+)_(\w+)_(\d+)/)){
          var box_index = tmp[1];
          var rkey = tmp[2];
          var wk_index = tmp[3]-0;
          var login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+wk_index+"_login_id").val();
          if(login_id!="" && login_id!=undefined){
            selectedPanel = "wkAUser_"+login_id;
            wkASetWorker($("#wkACargoWorker_"+box_index+"_"+rkey+"_"+wk_index).get(0),false,true,false);
          }
          if(wk_index % 2 == 1){ //右隣
            login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index+1)+"_login_id").val();
            if(login_id!="" && login_id!=undefined){
              selectedPanel = "wkAUser_"+login_id;
              wkASetWorker($("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index+1)).get(0),false,true,false);
            }
          }else{//左隣
            login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index-1)+"_login_id").val();
            if(login_id!="" && login_id!=undefined){
              selectedPanel = "wkAUser_"+login_id;
              wkASetWorker($("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index-1)).get(0),false,true,false);
            }
          }
          $("#wkAInfoBox").css("display","none");
          // wkASetWorkerによる表示切替を元に戻す
          if((selectedPanel=="" || selectedPanel.match(/wkAMachine_/)) && $("#wkAMachines").css("display")=="none") {
            wkAChangeViewMachineGroup();
          }

        }
      }
      selectedPanel = "";
      selectedAssignment = "";
      $("#"+robj.id).css("backgroundColor","");

      // 背景色黄色のままになる事象対策
      const yellowElems = Array.from(document.querySelectorAll('[style]')).filter(el =>
        el.style.backgroundColor === 'rgb(255, 255, 0)'
      );
      if(yellowElems) $(yellowElems).css("backgroundColor","");

    }else{
      $("#"+selectedAssignment).css("backgroundColor","");
      selectedAssignment = robj.id
      $("#"+selectedAssignment).css("backgroundColor","yellow");
    }
  }
}

//可能ユーザ設定の解除
function wkAUnSetChooseableUser(){
    $("div[id^='wkAUser_'].wkAPanel").each(function(){
        if($("#"+$(this).attr("id")+"_assignments").val() ==""){
            $(this).css("backgroundColor","");
        }else{
            $(this).css("backgroundColor","gray");
        }
    });
    $("div[id^='wkACargoWorker_'].wkAPanel").css("backgroundColor","");
}

//配番された機械の情報表示
function wkViewMachineInfo(robj,mord){
  if(tmp = robj.id.match(/^wkACargoMachine_(\d+)_(\w+)_(\d+)$/)){
    var box_index = tmp[1];
    var rkey = tmp[2];
    var wk_index = tmp[3];
    var vText,tmpVal;
    vText = "<form><table class='soloidline'>";
    tmpVal = $("input[id='"+robj.id+"_work_time']").val();
    vText +="<tr><td class='listTitle'>稼働時間</td>";
    vText +="<td class='list'><input type='text' name='work_time' value='"+tmpVal+"' onchange='wkSetMachineInfo(this);' size=5/>分</td></tr>";
    tmpVal = $("input[id='"+robj.id+"_maintenanc_type']").val();
    vText +="<tr><td class='listTitle'>故障発生</td>";
    vText +="<td class='list'><label><input type='checkbox' name='maintenanc_type' id='maintenanc_type' value='2' "+ (tmpVal=="2" ? "checked" : "")+" onclick='wkSetMachineInfo(this);' />故障発生</label></td></tr>";
    tmpVal = $("input[id='"+robj.id+"_e_date']").val();
    vText +="<tr><td class='listTitle'>復旧見込日</td>";
    vText +="<td class='list'><input type='text' name='e_date' value='"+tmpVal+"' onchange='set_date(this);wkSetMachineInfo(this);' size=10 /></td></tr>";
    tmpVal = $("input[id='"+robj.id+"_note']").val();
    vText +="<tr><td class='listTitle'>故障内容</td>";
    vText +="<td class='list'><input type='text' name='note' value='"+tmpVal+"' onchange='wkSetMachineInfo(this);' size=30 maxlength=128 /></td></tr>";

    vText +="<tr><td class='listC' colspan=2><input type='button' value='閉じる' onclick='$(\"#wkAInfoBox\").css(\"display\",\"none\");' /></td></tr>";
    vText += "</table>";
    vText += "<input type=hidden name='robj_id' value='"+robj.id+"' />";
    vText += "</from>";
    wkAViewNote(robj,vText)
  }
}
//機械結果登録
function wkSetMachineInfo(robj){
  var fobj = robj.form;
  var robjId = fobj.robj_id.value
  if(tmp = robjId.match(/^wkACargoMachine_(\d+)_(\w+)_(\d+)$/)){
    var box_index = tmp[1];
    var rkey = tmp[2];
    var wk_index = tmp[3];
    //配番データに反映
    $("#"+robjId+"_work_time").val(fobj.work_time.value);
    $("#"+robjId+"_maintenanc_type").val((fobj.maintenanc_type.checked ? fobj.maintenanc_type.value : ""));
    $("#"+robjId+"_e_date").val(fobj.e_date.value);
    $("#"+robjId+"_note").val(fobj.note.value);
  }
}
//ダブルクリック（処理なし）
function wkASetLock(){}
// function wkASelectCol(){} ... commn_assignment.jsで共通化
function wkALockCol(){}
// function wkASelectRow(){} ... commn_assignment.jsで共通化
function wkALockRow(){}

//Jobの実行チェック
function ckJob(){
  var fobj = document.create_form;
  var url = getUrl("result_assignment")+"/delayed_jobs/";
  url+="ResultAssignment_"+fobj.work_date.value;
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
           $("html").css("cursor","auto");
           msg = data["msg"];
           msg += "<br /><br /><br /><input type='button' value='閉じる' onclick='$(\"#msgBox\").css(\"display\",\"none\");' />";
           $("#msgBox").html(msg);
       }
    }).fail(function() {alert('実行エラー2');
    }).always(function() {});
}

// 実行確認
function wkAConfirmSave(){
  if(window.opener){
    if(confirm("このウィンドウを閉じて設定を保存しますか？")){
      window.opener.wkADoSave();
      window.close()
    }
  }else if(subW){
    if(confirm("サブウィンドウを閉じて設定を保存しますか？")){
      window.wkADoSave();
      subW.close()
    }
  }else{
    window.wkADoSave();
  }
}

//保存
function wkADoSave(){
    var fobj = document.inform;
    if(ck_submitting()){fobj.submit();}
}

// 複数選択一括登録関係
//選択済みリストを掃除
function clearSelectedPanelArr(){
  if(selectedPanelArr<=0){ return }
  selectedPanelArr.forEach((robj)=>{
    $(`#${robj.id}`).removeClass('selectKeep')
  })
  selectedPanelArr = []
}

//-- 選択済みリストに追加
//　クラス付与や作業員⇒機械を選択時のお掃除など良しなにしてくれる
function pushSeletedPanelArr(robj){
  in_robj_type = robj.id.split("_")[0] // wkAUser || wkAMachine
  if(selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]!==in_robj_type){
    clearSelectedPanelArr()
  }
  if(selectedPanelArr.find((tobj)=>{return tobj.id==robj.id})){return selectedPanelArr}
    $(robj).addClass('selectKeep')
  selectedPanelArr.push(robj)
  return selectedPanelArr
}


//選択済みリストを配番パネルに貼り付け
function setAllSelectedPanel(robj,func,step){
  // alert("ぺたっ ".repeat(selectedPanelArr.length))
  // 貼り付け範囲のロックセルをチェック
  $(`#${robj.id}`).removeClass('selectKeep')
  var match = robj.id.match(/^(.*_)(\d+)$/)
  if(match){
    let panelPrefix = match[1]
    let startIndex = match[2]-0
    let targetPanels = selectedPanelArr.map((tobg,index)=>{
      let tmpId = panelPrefix + String(startIndex+(step*index))
      return document.getElementById(`${tmpId}`)
    })
    var locked = targetPanels.find((tobj)=>{return tobj ? tobj.classList.contains('wkAPanelock') : false})
    if(locked){
      alert("貼り付け範囲にロックされたパネルがあります。ロック解除後に操作をやり直してください。")
      return false
    }
    selectedPanelArr.forEach((tobj,index)=>{
      $(`#${tobj.id}`).removeClass('selectKeep')
      let tpanel = targetPanels[index]
      if(tpanel){
        selectedPanel=tobj.id
        func(tpanel,true,true)
      }
    })
    clearSelectedPanelArr()
    return true
  }else{return false}
}

