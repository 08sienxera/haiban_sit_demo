//グローバル変数
let selectedPanelArr = []
let wkAssignmentInitialized = false;
//OnLoadイベント
$(function(){WkAssignmentinit();});

$(document).on('turbolinks:load', function() {WkAssignmentinit();});
function WkAssignmentinit(){
    if(wkAssignmentInitialized){return false}
    $("#msgBox").text("パネル初期化中").css("display","block");
    def_font_size = document.setting_data.def_font_size.value -0;
    eval("def_tbl_setting="+document.setting_data.str_tbl_setting.value);
    //作業日テーブルに文字サイズ大小ボタン,最大表示ボタンを追加
    WkAAddTDateTbl2Button();

    //ウィンドウの初期化
    if(!window.opener){//メインウィンドウ
      WkAAddTDateTbl3Button();// メインウィンドウの初期化
      observer = new Observer;
      observer.addObserver(window);
      // ウィンドウ間の連動関数　observer.observerFunction(function,window,shouldPropagate,globalContext)
      // function: 連動させる関数
      // window: 連動させるウィンドウ
      // shouldPropagate: 連動させる条件（trueの場合は連動させる）
      // globalContext: 値共有するさせるグローバル変数
      obsWkASetWorker = observer.observerFunction(wkASetWorker,window,(event)=>{return !isModifiedEvent(event)},['selectedPanel']); // 中止条件を追加
      obsWkASelectUser = observer.observerFunction(wkASelectUser,window,(event)=>{return !isModifiedEvent(event)},['selectedPanel','selectedAssignment']);
      obsWkASetMachine = observer.observerFunction(wkASetMachine,window,(event)=>{return !isModifiedEvent(event)},['selectedPanel']);
      obsWkASelectMachine = observer.observerFunction(wkASelectMachine,window,(event)=>{return !isModifiedEvent(event)},['selectedPanel','selectedAssignment']);
      obsWkSetWorkerInfo = observer.observerFunction(wkSetWorkerInfo,window,null);
      obsWkAUnSetAssignment = observer.observerFunction(wkAUnSetAssignment,window,null,['selectedAssignment']);
      obsWkASetLock = observer.observerFunction(wkASetLock,window,null);
      obsWkACargoAddPanelRow = observer.observerFunction(wkACargoAddPanelRow,window,null);
      obsToggleRowDisplay = observer.observerFunction(toggleRowDisplay,window,null);
      obsWkASelectCol = observer.observerFunction(wkASelectCol,window,null);
      obsWkASelectRow = observer.observerFunction(wkASelectRow,window,null);
      obsWkAChangeAssignmentToPanel = observer.observerFunction(wkAChangeAssignmentToPanel,window,null,['selectedAssignment','selectedCol','selectedRow','cpAria']);
      obsWkAPasteAriaToPanel = observer.observerFunction(wkAPasteAriaToPanel,window,null,['cpAria','selectedAssignment','selectedRow','selectedCol']);
    }else{//サブウィンドウ
      window.document.body.innerHTML = window.opener.document.body.innerHTML;
      // 初期表示時にフォーム要素の現在値をメイン→サブへ同期
      initialSyncBetweenWindows();
      WkASwitchWindow(2)
      syncChangeEventBetweenWindows()
      observer = window.opener.observer;
      obsWkASetWorker = window.opener.obsWkASetWorker;
      obsWkASelectUser = window.opener.obsWkASelectUser;
      obsWkASetMachine = window.opener.obsWkASetMachine;
      obsWkASelectMachine = window.opener.obsWkASelectMachine;
      obsWkSetWorkerInfo = window.opener.obsWkSetWorkerInfo;
      obsWkAUnSetAssignment = window.opener.obsWkAUnSetAssignment;
      obsWkASetLock = window.opener.obsWkASetLock;
      obsWkACargoAddPanelRow = window.opener.obsWkACargoAddPanelRow;
      obsToggleRowDisplay = window.opener.obsToggleRowDisplay;
      obsWkASelectCol = window.opener.obsWkASelectCol;
      obsWkASelectRow = window.opener.obsWkASelectRow;
      obsWkAChangeAssignmentToPanel = window.opener.obsWkAChangeAssignmentToPanel;
      obsWkAPasteAriaToPanel = window.opener.obsWkAPasteAriaToPanel;
      // $('#tDateTbl #tDateTbl').css('display','none')
      $('.wkABtn').each((i,v)=>{
        if(["FM前CP","DM前CP","自動配番","配番確定"].includes(v.value)){
          $(v).css('display','none')
        }
      })
      $("#tDateTbl tr>td:nth-child(1)").css("opacity","0").css("pointerEvents","none");
      $("#tDateTbl tr>td:nth-child(4)").css("opacity","0").css("pointerEvents","none");
      $("#tDateTbl tr>td:nth-child(5)").css("opacity","0").css("pointerEvents","none");
      $("input[type='submit'][value='閉じる']").addClass("dispNone");
      $("#link_box a").css("display","none")
      // タイトル変更
      let subTitle = $("div#header h1 div.h1_center").text();
      $("div#header h1 div.h1_center").text(subTitle+"（サブ画面）");
      let mainTitle = window.opener.$("div#header h1 div.h1_center").text();
      window.opener.$("div#header h1 div.h1_center").text(mainTitle+"（メイン画面）");
    }
    //画面設定
    WkASetFontSize(0);
    //画面サイズ変更時イベント追加
    $(window).resize(function(){WkASetView();});
    $(window).on('orientationchange', function(e) {WkASetView();});
    //キーボードイベント追加
    $(window).keydown(function(e){
      switch(e.keyCode){
      case 27 : //Esc
        $("#wkAInfoBox").css("display","none");
        wkAUnsetSelectPanel();
        wkAUnsetSelectedAssignment();
        wkAUnSetChooseableUser();
        clearSelectedPanelArr();
        break;
      case 8 : //Backsoace
      case 46 : //Delete
        for(const win of observer.observers){
          let infoBox = win.document.querySelector('#wkAInfoBox')
          if(infoBox&&infoBox.style.display=='block'){break;}
          win.wkAUnSetAssignment();
        }
        break;
      case 67 : //c
        obsWkAChangeAssignmentToPanel(window);
        break;
      case 86 : //v
        if(cpAria["tRow"]!=""){
          obsWkAPasteAriaToPanel(window);
        }
        break;
      //default:
      //  console.log("keydown:"+e.keyCode);
      }
    });

    //作業名クリックで本船・沿岸を切替（マルチモード時のみ）
    $("span[class^='trigger']").on("click",(evt)=>{
      const target = evt.target;
      if(!multiWindowMode && !window.opener) return ;
      const triggerClassName = target.classList[0];
      obsToggleRowDisplay(window,null,triggerClassName.split("_")[1]);
      // if(target.classList.contains('wc_1')) filterRow(window,2);
      // if(target.classList.contains('wc_2')) filterRow(window,1);
    })
  
    //パネルの初期化＆臨時・人のカウント→パネルリストを閉じる：時間がかかるのでずらす
    setTimeout(function(){
      $("html").css("cursor","wait");
      if(!window.opener) WkAInitData();
      wkAViewPanelList("dummy");
      if(window.localStorage){
        //WkASetFontSize(window.localStorage.getItem("onakai_wk_assignment_font_flg")-0);
        if(window.localStorage.getItem("onakai_wk_assignment_hf_hidden_flg")){WkASwitchVisibleHF(false)}
      }
      $("#msgBox").css("display","none");
      $("html").css("cursor","auto");
    },100);
    wkAssignmentInitialized = true
}

//パネルの初期化＆臨時・人のカウント
function WkAInitData(){
    var cargo_count = document.inform.cargo_count.value-0;
    //各列のデータ初期化
    // 配番パネルを先に取得
    var inputs = document.querySelectorAll("#wkAbody input[id^='wkACargo']");
    for(var row_index=0;row_index<cargo_count;row_index++){
        $.each(AssignmentBlocks,function(index,pkey){
          // var tObj = $("input[name^='wkACargoWorker_"+row_index+"["+pkey+"']input[id$='_login_id']");　変更前
          var tObj = Array.from(inputs).filter(function(input) {
              return input.name.startsWith('wkACargoWorker_' + row_index + '[' + pkey) && input.id.endsWith('_login_id');
          });
          for(const obj of tObj){
            const jq_obj = $(obj)
            if(jq_obj.attr('id').match(/_login_id$/) && jq_obj.val() != ""){
              selectedPanel = "wkAUser_"+jq_obj.val();
              wkASetWorkerInit(document.getElementById(jq_obj.attr('id').replace(/_login_id$/,"")));
            }
          };


          // tObj = $("input[name^='wkACargoMachine_"+row_index+"["+pkey+"']input[id$='_machine_id']"); 変更前
          var tObj2 = Array.from(inputs).filter(function(input) {
            return input.name.startsWith('wkACargoMachine_' + row_index + '[' + pkey) &&　input.id.endsWith('_machine_id');
          });

          for(const obj of tObj2){
            const jq_obj = $(obj)
            if(jq_obj.attr('id').match(/_machine_id$/) && jq_obj.val() != ""){
              selectedPanel = "wkAMachine_"+jq_obj.val();
              wkASetMachineInit(document.getElementById(jq_obj.attr('id').replace(/_machine_id$/,"")));
            }
          };
        });
        selectedPanel ="";
        //行毎臨時・人のカウント
        WkARowReCount(row_index,false);
    }
    //全チェック←初期起動チェック無し
    //wkACkAllAssignment();
}
//注意入力欄の表示／非表示
function wkAMsgRowView(row_index){
    var tObj = $("tr[id^='wkAMsgRow_"+row_index+"']");
    if(tObj.css("display")=="none"){tObj.css("display","");}else{tObj.css("display","none");}
    wkASetWkAbodyRowH(row_index);
}
//パネルリストから選択(共通)
function wkASelectPanel(robj){
    wkAUnsetSelectPanel();
    if(selectedPanel==robj.id){
        return false;
    }else{
        selectedPanel = robj.id
        $("#"+selectedPanel).css("backgroundColor","yellow");
        if(selectedPanel.match(/^wkAUser_(\w+)/) && selectedAssignment==""){
            //配置可能作業の設定
            // wkASetCanWork(selectedPanel);
        }
        return true;
    }
}
//配置可能作業の設定
function wkASetCanWork(panelId){
  var bgc_is_can = "yellow";
  var bgc_is_cannot = "gray";
  var base_no = $("input[name='"+panelId+"[base_no]']").val();
  var at_work = $("input[name='"+panelId+"[at_work]']").val();
  if(base_no=="" || base_no=="2" || (base_no=="6" && at_work=="1")){
    //作業可能
    var competences = {};
    $("input[id^='"+selectedPanel+"_competence_']").each(function(){
      competences[$(this).attr("id").replace(selectedPanel+"_competence_","")]=($(this).val()-0);
    });
    var cargo_count = $("input[id='cargo_count']").val() - 0;
    for(var rowNo=0;rowNo<cargo_count;rowNo++){
      var move_no = $('#cargo_'+rowNo+'_move_no').val();
      var is_can = 2;
      switch(move_no){
      case "HB999991" :  //配番作業
        if(competences["ca"]>0){is_can = 1;}else{is_can = 0;} break;
      case "HB000600" :  //整備
        if(competences["mt"]>0){is_can = 1;}else{is_can = 0;} break;
      case "HB000610" :  //道具
        if(competences["tl"]>0){is_can = 1;}else{is_can = 0;} break;
      }
      switch(is_can){
      case 0 : //作業不可
        $("div[id^='wkACargoWorker_"+rowNo+"_']").css("backgroundColor","gray");break;
      case 1 : //作業可
        $('input[id^="needCount_'+rowNo+'_"]').each(function(){
          var rkey = $(this).attr("id").replace("needCount_"+rowNo+"_","").substr(0,2);
          if(($(this).val() -0 )>0){
            $("div[id^='wkACargoWorker_"+rowNo+"_"+rkey+"_']").css("backgroundColor",bgc_is_can);
          }else{
            $("div[id^='wkACargoWorker_"+rowNo+"_"+rkey+"_']").css("backgroundColor",bgc_is_cannot);
          }
        });break;
      default:  //静動番号でのチェック不可な他作業
        var work_class = $('#cargo_'+rowNo+'_work_class').val();  //作業区分,1:本船,2:沿岸,9:休み
        var work_place = $('#cargo_'+rowNo+'_work_place').val();  //場所
        var cargo_name = $('#cargo_'+rowNo+'_cargo_name').val();  //貨物名
        var canRkey={"fm":false,"dm":false,"wi":false,"dr":false,"wk":false};
        $('input[id^="needCount_'+rowNo+'_"]').each(function(){
          if(($(this).val() -0 )>0){
            if(tmpKeys = $(this).attr("id").match(new RegExp("needCount_"+rowNo+"_(\\w+)_(\\w+)"))){
              var rkey = tmpKeys[1];
              var skey = tmpKeys[2];
              switch(skey){
              case "fm":
                if(work_place.match(/7\-3/) && cargo_name.match(/石炭灰/)){
                  if(competences["fma"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/7\-5/) && cargo_name.match(/石炭灰/)){
                  if(competences["fmp"]>0){canRkey[rkey]=true;}
                }else if(work_class=="1"){
                  if(competences["fmm"]>0){canRkey[rkey]=true;}
                }else if(work_class=="2"){
                  if(competences["fmc"]>0){canRkey[rkey]=true;}
                }
                break;
              case "dm":
                if(work_place.match(/6\-1/) || work_place.match(/H\-1/)){
                  if(competences["sn"]>0){canRkey[rkey]=true;}
                }else{
                  if(competences["dm"]>0){canRkey[rkey]=true;}
                }
                break;
              case "wm": if(competences["wwm"]>0){canRkey[rkey]=true;}break
              case "cr": //クレーン
                if(work_place.match(/3\-3/) || work_place.match(/3\-4/)){
                  if(competences["cr3"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/5\-1/)){
                  if(competences["cr5"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/6\-1/)){
                  if(competences["cr6"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/7\-1/) || work_place.match(/7\-2/)){
                  if(competences["cr7"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/H\-1/)){
                  if(competences["cru"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/O\-3/) || work_place.match(/O\-4/)){
                  if(competences["crg"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/7\-5/)){
                  if(competences["crp"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/H\-2/)){
                  if(competences["cre"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/7\-3/)){
                  if(competences["crs"]>0){canRkey[rkey]=true;}
                }
                break;
              case "ld": //ローダー
                if(work_class=="1"){
                  if(competences["ldm"]>0){canRkey[rkey]=true;}
                }else if(work_class=="2"){
                  if(competences["ldc"]>0){canRkey[rkey]=true;}
                }
                break;
              case "bh": //ﾊﾞｯｸﾎｰ
                if(work_class=="1"){
                  var is_match = false;
                  $("input[id^='wkACargoMachine_"+rowNo+"_"+rkey+"_']input[id$='_machine_cd']").each(function(){
                    if($(this).val().match(/ﾘｰｽﾊﾞ\d+/)){
                      is_match = true;return true;
                    }
                  });
                  if(is_match){ // 機械がﾘｰｽﾊﾞ1、ﾘｰｽﾊﾞ2、ﾘｰｽﾊﾞ3、ﾘｰｽﾊﾞ5
                    if(competences["bhs"]>0){canRkey[rkey]=true;}
                  }else{
                    if(competences["bhh"]>0){canRkey[rkey]=true;}
                  }
                }
                break;
              case "sl": //船内ﾛｰﾀﾞ―
                if(work_class=="1"){
                  if(competences["slm"]>0){canRkey[rkey]=true;}
                }else if(work_class=="2"){
                  if(competences["slc"]>0){canRkey[rkey]=true;}
                }
                break;
              case "bl": //ブル(トーザー)
                if(work_class=="1" && work_place.match(/H\-1/)){
                  if(competences["blh"]>0){canRkey[rkey]=true;}
                }else{
                  if(competences["bld"]>0){canRkey[rkey]=true;}
                }
                break;
              case "lf": //リフト
                if(work_place.match(/物流ｾﾝﾀｰ/) || work_place.match(/物流センター/)){
                  if(competences["lfl"]>0){canRkey[rkey]=true;}
                }else{
                  if(competences["lf"]>0){canRkey[rkey]=true;}
                }
                break;
              case "sc": //ｽﾄﾗﾄﾞﾙｷｬﾘｱ
                if(work_class=="1"){
                  if(competences["scm"]>0){canRkey[rkey]=true;}
                }else if(work_class=="2"){
                  if(competences["scc"]>0){canRkey[rkey]=true;}
                }
                break;
              case "tl": //ﾄﾗﾝｽﾌｧｰｸﾚｰﾝ
                if(work_class=="1"){
                  if(competences["tlm"]>0){canRkey[rkey]=true;}
                }else if(work_class=="2"){
                  if(competences["tlc"]>0){canRkey[rkey]=true;}
                }
                break;
              case "ot": //他
                if(rkey=="dr"){
                  if(move_no=="HB000595" || move_no=="HB000596" || move_no=="HB000597" || move_no=="HB000599"){
                    if(competences["cc"]>0){canRkey[rkey]=true;}
                  }else if(cargo_name.match(/石炭/) && (work_place.match(/7\-1/) || work_place.match(/7\-2/) || work_place.match(/6\-1/) || work_place.match(/H\-1/))){
                    if(competences["od"]>0){canRkey[rkey]=true;}
                  }else if(work_place.match(/H\-1/)){
                    if(competences["ep"]>0){canRkey[rkey]=true;}
                  }else if(work_place.match(/H/)){
                    if(competences["em"]>0){canRkey[rkey]=true;}
                  }
                }else if(rkey=="wk"){
                  var is_match = {"sw":false,"sp":false,"clr":false};
                  $("input[id^='wkACargoMachine_"+rowNo+"_"+rkey+"_']input[id$='_machine_cd']").each(function(){
                    if($(this).val().match(/ｽｲｰﾊﾟ/)){
                      is_match["sw"] = true;
                    }else if($(this).val().match(/散水/)){
                      is_match["sp"] = true;
                    }else if($(this).val().match(/掃除機/) || $(this).val().match(/三洋掃/)){
                      is_match["clr"] = true;
                    }
                  });
                  if(is_match["sw"] && competences["sw"]>0){canRkey[rkey]=true;}
                  if(is_match["sp"] && competences["sp"]>0){canRkey[rkey]=true;}
                  if(is_match["clr"] && competences["clr"]>0){canRkey[rkey]=true;}
                }
                break;
              case "hd": //作業-ハン
                if(work_place.match(/3\-3/) || work_place.match(/3\-4/)){
                  if(competences["w3"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/5\-1/)){
                  if(competences["s5"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/7\-1/) || work_place.match(/7\-2/)){
                  if(competences["s7"]>0){canRkey[rkey]=true;}
                }
                break;
              case "db": if(competences["wgd"]>0){canRkey[rkey]=true;}break;
              case "hs": if(competences["wal"]>0){canRkey[rkey]=true;}break;
              case "sn": //作業-船内
                if(work_place.match(/6\-1/) || work_place.match(/H\-1/)){
                  if(competences["w6e"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/3\-3/) || work_place.match(/3\-4/) || work_place.match(/5\-1/) || work_place.match(/7\-1/) || work_place.match(/7\-2/)){
                  if(competences["wbg"]>0){canRkey[rkey]=true;}
                }else if(work_place.match(/物流ｾﾝﾀｰ/) || work_place.match(/物流センター/)){
                  if(competences["wlg"]>0){canRkey[rkey]=true;}
                }else if((cargo_name.match(/ｺﾝﾃﾅ/) || work_place.match(/コンテナ/)) && (work_place.match(/O\-3/) || work_place.match(/O\-4/))){
                  if(competences["wsc"]>0){canRkey[rkey]=true;}
                }else{
                  if(competences["wsm"]>0){canRkey[rkey]=true;}
                }
                break;
              case "eg": //作業-沿岸
                if((cargo_name.match(/ｺﾝﾃﾅ/) || work_place.match(/コンテナ/)) && (work_place.match(/O\-3/) || work_place.match(/O\-4/))){
                  if(competences["wcc"]>0){canRkey[rkey]=true;}
                }else{
                  if(competences["wc"]>0){canRkey[rkey]=true;}
                }
                break;
              //default:
              //  console.log("rowNo=["+rowNo+"]rkey=["+rkey+"]skey=["+skey+"]val=["+$(this).val()+"]");
              }
            }
          }
        });
        for(rkey in canRkey){
          if(canRkey[rkey]){
            $("div[id^='wkACargoWorker_"+rowNo+"_"+rkey+"_']").css("backgroundColor",bgc_is_can);
          }else{
            $("div[id^='wkACargoWorker_"+rowNo+"_"+rkey+"_']").css("backgroundColor",bgc_is_cannot);
          }
        }
      }
    }
  }else{
    //作業不可
    $("div[id^='wkACargoWorker_']").css("backgroundColor","gray")
  }
  //現在設定済みパネル
  var assignments = $("input[id='"+panelId+"_assignments']").val();
  if(assignments!=""){
    $.each(assignments.split("|"),function(index,assignment){
      if(assignment!=""){$("#"+assignment).css("backgroundColor","greenyellow");}
    });
  }

}


//作業者パネルリストから選択
function wkASelectUser(robj){
  const evt = event;
  if(evt && isModifiedEvent(evt)){
    if(isAltEvent(evt)){
      $("#" + selectedPanel).css("backgroundColor","");
      $("#" + selectedPanel).removeClass("wkAIsAssigned");
      selectedPanel="";
      $("#" + selectedAssignment).css("backgroundColor","");
      $("#" + selectedAssignment).removeClass("wkAIsAssigned");
      selectedAssignment="";
      pushSeletedPanelArr(robj);
    }   
    if(isShiftEvent(evt)) wkAViewMsgBox($("input[name='"+robj.id+"[login_id]']").val());
    if(isCtrlEvent(evt)) wkAViewCompetence(robj);
    return;
  }
  clearSelectedPanelArr()
  if(wkASelectPanel(robj) && selectedAssignment==""){
  
  }

  //配番パネル選択しており作業者パネルを選択した場合→配番パネルに反映
  if(selectedPanel!="" && selectedAssignment!=""){
      if(selectedAssignment.match(/^wkACargoWorker/)){wkASetWorker(document.getElementById(selectedAssignment),false);}
  }
}


function wkAViewCompetence(robj){
  //休暇・力量情報表示
  var vText = "";
  var login_id = $("input[name='"+robj.id+"[login_id]']").val();
  var base_no = $("input[name='"+robj.id+"[base_no]']").val();

  if(base_no != ""){
      vText +="<tr><td colspan=8>"+$("input[name='"+robj.id+"[vacation_info]']").val()+"</td></tr>";
  }
  if(managerFlg==undefined || !managerFlg){return;}

  $.each(Competence,function(index,val){
    if(index % 4 ==0){vText += "<tr>";}
    vText +="<td class='listTitle'>"+val[0]+"</td><td>";
    var competence = $("input[name='"+robj.id+"[competence_"+val[1]+"]']").val() -0;
    if(competence == -1){competence=0;}
    vText += "<span id='competence_level_"+val[1]+"_0' class='competenceStar' onclick='wkASetCompetence(\""+login_id+"\",\""+val[1]+"\",0)'>×</span>";
    for(var wi=1;wi <= competence;wi++){
      vText += "<span id='competence_level_"+val[1]+"_"+wi+"' class='competenceStar' onclick='wkASetCompetence(\""+login_id+"\",\""+val[1]+"\","+wi+")'>★</span>";
    }
    for(var wi=competence+1;wi <= 5;wi++){
      vText += "<span id='competence_level_"+val[1]+"_"+wi+"' class='competenceStar' onclick='wkASetCompetence(\""+login_id+"\",\""+val[1]+"\","+wi+")'>☆</span>";
    }
    vText +="</td>";
    if(index % 4 ==3){vText += "</tr>";}
  });

  if(vText!=""){
    vText = "<table class='soloidline'><tr><td colspan=8 class='listC'>"+$("input[name='"+robj.id+"[s_name]']").val()+"</td></tr>"+vText+"</table>";
  }
  wkAViewNote(robj,vText)
}


//力量変更
function wkASetCompetence(login_id,CompetenceKey,level){
    for(var wi=1;wi <= level;wi++){
        $("#competence_level_"+CompetenceKey+"_"+wi).text("★");
    }
    for(var wi=level+1;wi <= 5;wi++){
        $("#competence_level_"+CompetenceKey+"_"+wi).text("☆");
    }
    if(level==0){level=-1;}
    $("input[name='wkAUser_"+login_id+"[competence_"+CompetenceKey+"]']").val(level);
    //配番可能を再設定
    // wkASetCanWork("wkAUser_"+login_id);
    //設定値をDBに登録
    var fobj = document.set_competence_form;
    fobj.woker_id.value = $("input[name='wkAUser_"+login_id+"[woker_id]']").val();
    fobj.competence_key.value = CompetenceKey;
    fobj.level.value = level;
    $.ajax({
        url: fobj.action,
        type: fobj.method,
        data: $(fobj).serialize(),
        cache: false,
        dataType: 'json',
    }).done(function(data) {if(data["sts"]==200){}else{alert('更新エラー');}
    }).fail(function() {alert('更新エラー');
    }).always(function() {});
}

//機械パネルリストから選択
function wkASelectMachine(robj){
  const evt = event;
  if(evt && isModifiedEvent(evt)){
    if(isAltEvent(evt)){
      $("#" + selectedPanel).css("backgroundColor","");
      selectedPanel="";
      $("#" + selectedAssignment).css("backgroundColor","");
      selectedAssignment="";

      pushSeletedPanelArr(robj)
    }
    return;
  }
  clearSelectedPanelArr();

  if(wkASelectPanel(robj) && selectedAssignment==""){
    var vText,tmpVal;
    vText = ""
    tmpVal = $("input[name='"+robj.id+"[maintenance]']").val();
    if(tmpVal!=""){
      vText +="<tr><td class='listTitle'>メンテナンス</td>";
      vText +="<td class='list'>"+tmpVal+"</td></tr>";
    }
    tmpVal = $("input[name='"+robj.id+"[schedule]']").val();
    if(tmpVal!=""){
      vText +="<tr><td class='listTitle'>予定</td>";
      vText +="<td class='list'>"+tmpVal+"</td></tr>";
    }
    tmpVal = $("input[name='"+robj.id+"[period]']").val();
    if(tmpVal!=""){
      vText +="<tr><td class='listTitle'>稼働</td>";
      vText +="<td class='list'>"+tmpVal+"</td></tr>";
    }
    if(vText!=""){
      vText = "<table class='soloidline'>"+vText+"</table>";
    }
    wkAViewNote(robj,vText)
  }
  //配番パネル選択しており機械パネルを選択した場合→配番パネルに反映
  if(selectedPanel!="" && selectedAssignment!=""){
      if(selectedAssignment.match(/^wkACargoMachine/)){
        wkASetMachine(document.getElementById(selectedAssignment),false);}
  }
}
//配番の入れ替え＆＆選択をクリア
function wkAUnsetSelectAssignment(robj){
  // orbj = 配番作業員パネルｏｒ配番機械パネル
  var ret = true;

  // 配番パネル未選択の場合、True返す
  if(selectedAssignment=="") return ret
  const isSamePanel     = selectedAssignment==robj.id;
  const isLocked        = $("#"+robj.id+"_lock_flg").val() == "1" || $("#"+selectedAssignment+"_lock_flg").val() == "1";
  const isSamePanelType = robj.id.substr(0,15) == selectedAssignment.substr(0,15); //パネルが同じ種類（作業員と作業員、機械と機械）

  if(!(isSamePanel || isLocked) && isSamePanelType){ //選択済みパネルと選択パネルが同じ種類（作業員と作業員、機械と機械）
    //入れ替え
    var tmp,fId,tId;
    $("html").css("cursor","wait");

    const panelType = getPanelType(robj.id);
    // 配番機械パネル
    if(panelType=="CargoMachinePanel"){
      fId = $("#"+selectedAssignment+"_machine_id").val();
      fBox = $("#"+selectedAssignment).get(0);
      fWorkIndex = $("#" + fBox.id + "_work_index").val();
      tId = $("#"+robj.id+"_machine_id").val()
      tBox = robj;
      tWorkIndex = $("#" + tBox.id + "_work_index").val();
      //一旦どちらもはがず
      wkAUnSetAssignment(false);
      selectedAssignment = robj.id;
      wkAUnSetAssignment(false);
      selectedAssignment = "";
      //再選択を実施
      if(tId!=""){
        tmpWorkIndex = tWorkIndex;
        selectedPanel = "wkAMachine_"+tId;
        wkASetMachine(fBox);
        tmpWorkIndex = null;
      }
      if(fId!=""){
        tmpWorkIndex = fWorkIndex;
        selectedPanel = "wkAMachine_"+fId;
        wkASetMachine(tBox);
        tmpWorkIndex = null;
      }
    }

    // 配番作業員パネル
    if(panelType=="CargoWorkerPanel"){
      fId = $("#"+selectedAssignment+"_login_id").val();
      fBox = $("#"+selectedAssignment).get(0);
      fWorkIndex = $("#" + fBox.id + "_work_index").val();
      tId = $("#"+robj.id+"_login_id").val();
      tBox = robj;
      tWorkIndex = $("#" + tBox.id + "_work_index").val();

      //一旦どちらもはがず
      wkAUnSetAssignment(false);
      selectedAssignment = tBox.id;
      wkAUnSetAssignment(false);
      selectedAssignment = "";

      //再選択を実施
      if(tId!=""){
        tmpWorkIndex = tWorkIndex;
        selectedPanel = "wkAUser_"+tId;
        wkASetWorker(fBox);
        tmpWorkIndex = null;
      }
      if(fId!=""){
        tmpWorkIndex = fWorkIndex;
        selectedPanel = "wkAUser_"+fId;
        wkASetWorker(robj);
        tmpWorkIndex = null;
      }
      $("#wkAInfoBox").css("display","none");
    }

    selectedAssignment="";
    selectedPanel="";
    wkAUnSetChooseableUser();
    $("html").css("cursor","auto");
    ret = false
    // ret = (tid=="" && fId=="")
    return ret;
  }else{
    $("#"+selectedAssignment).css("backgroundColor","");

  }
  selectedAssignment = "";
  return ret
}
//配番から選択(共通)
function wkASelectAssignment(robj){
    if(selectedAssignment==robj.id){
      return false;
    }else{
        selectedAssignment = robj.id
        $("#"+selectedAssignment).css("backgroundColor","yellow");
        var flg = (robj.id.match(/^wkACargoWorker/) ? "Workers" : "Machines");
        if($("#wkA"+flg).css("display")=="none" && selectedPanel==""){
          // wkAViewPanelList(flg);
        }
        $("#wkAInfoBox").css("display","none");

        if(false){//配番可能作業者の選定はしない　2025-02-06 懸案台帳の要望対応
        // if(false && block = robj.id.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)/)){
            //配番可能作業者の選定
            competenceKeys = getCompetenceKeys(block[1],block[2],(block[3]-0));
            if(competenceKeys.length > 0){
              $("div[id^='wkAUser_']").css("backgroundColor","gray");
              $("div[id^='wkAUser_']").each(function(){
                if(login_id = $(this).attr("id").match(/^wkAUser_(\w+)/)){
                    var base_no = $("#wkAUser_"+login_id[1]+"_base_no").val();
                    var at_work = $("#wkAUser_"+login_id[1]+"at_work").val();
                    var assignments = $("input[name='wkAUser_"+login_id[1]+"[assignments]'");
                    if(base_no=="" || base_no=="2" || (base_no=="6" && at_work=="1")){
                        var is_can = false;
                        $.each(competenceKeys,function(index,competenceKey){
                            if(($("#wkAUser_"+login_id[1]+"_competence_"+competenceKey).val()-0) > 0){
                                is_can = true; return false;
                            }
                        });
                        //if(is_can){
                          //重複可能な場所以外で既に配番済みユーザを除外
                          //if(assignments.length){
                          //  if(assignments.val()!=""){
                          //    $.each(assignments.val().split("|"),function(index,assignment){
                          //      if(tmp = robj.id.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)){
                          //        if(block[1] == tmp[1]){is_can=false;return false;}
                          //        if($("#cargo_"+block[1]+"_work_no").val() != $("#cargo_"+tmp[1]+"_work_no").val()){
                          //          work_place1 = $("#cargo_"+block[1]+"_work_place").val();
                          //          work_place2 = $("#cargo_"+tmp[1]+"_work_place").val();
                          //          if((work_place1=="" && work_place2=="") || (work_place1!=work_place2)){
                          //              move_no1 = $("#cargo_"+block[1]+"_move_no").val();
                          //              move_no2 = $("#cargo_"+tmp[1]+"_move_no").val();
                          //              if(move_no1!="HB999996" && move_no2!="HB999996" && move_no1!="HB999997" && move_no2!="HB999997"){
                          //                is_can = false;return false;
                          //              }
                          //          }
                          //        }
                          //      }
                          //    });
                          //  }
                          //}
                          //↑重複チェックなし
                        //}
                        if(is_can){
                          if(assignments.length){
                            if(assignments.val()==""){$(this).css("backgroundColor","yellow");}
                            else{$(this).css("backgroundColor","darkorange");}
                          }else{
                            $(this).css("backgroundColor","yellow");
                          }
                        }
                    }
                }
              });
            }
            //設定済みユーザを強調
            var login_id = $("#"+robj.id+"_login_id").val();
            if(login_id!=""){$("#wkAUser_"+login_id).css("backgroundColor","greenyellow ");}
        }
        return true;
    }
}


//場所、機械にSET
function wkASetMachine(robj,withoutLock,continuous=false){
  // 機械タブ表示
  if((selectedPanel=="" || selectedPanel.match(/wkAMachine_/)) && $("#wkAMachines").css("display")=="none") {
    wkAChangeViewMachineGroup();
  }

  const evt = event;
  const isContinue = continuous;
  const eventCancel = forceEventCancel;

  // 修飾キー押下時
  if(!isContinue && isModifiedEvent(evt) && !eventCancel){
    // 一括貼り付け
    if(isAltEvent(evt)){
      const isMachineList = selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]=="wkAMachine";
      if(!isMachineList) return;
      const confirmMsg = `選択済み機械${selectedPanelArr.length}個を一括貼り付けしますか？\n対象機械:${selectedPanelArr.map(robj=>{return `「${robj.innerHTML.substr(0,robj.innerHTML.indexOf("<"))}」`})}`;
      if(confirm(confirmMsg)){
        evt.altKey = false;
        setAllSelectedPanel(
          robj,
          observer.observerFunction(wkASetMachine,window,null,['selectedPanel']), 
          1
        );
      }
    }
    return;
  }
  clearSelectedPanelArr();
  // work_index
  const tmpSelectedPanel = selectedPanel;
  if(wkAUnsetSelectAssignment(robj)){
    // 入れ替えでない場合
    if(ck_result = selectedPanel.match(/^wkAMachine_(\w+)/)){
      var bc_machine_id = $("#"+robj.id+"_machine_id").val()
      var locked = $("#"+robj.id+"_lock_flg").val()
      if(locked!="1" || withoutLock){
        var strassignment="";
        selectedAssignment = robj.id;
        wkAUnSetAssignment();
        
        $("#"+robj.id+"_machine_id").val(ck_result[1]);
        if(!withoutLock){$("#"+robj.id+"_lock_flg").val(0);}
        var root_Panel = $("#"+selectedPanel);
        if(root_Panel.length){
          $("#"+robj.id+"_text").text(root_Panel.text());
          robj.className = root_Panel.attr("class");
          if($("#"+robj.id+"_lock_flg").val()=="1"){wkASetLockView(robj.id,1);}
          root_Panel.css("backgroundColor","");
          root_Panel.addClass("wkAIsAssigned");

          var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
          if(assignmentForm.length){
            $("#"+robj.id+"_text").text(root_Panel.text());
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
          //機械入れ替えで担当作業、バス手当等が変わるので影響範囲を再設定
          if(tmp = robj.id.match(/^wkACargoMachine_(\d+)_(\w+)_(\d+)/)){
            var box_index = tmp[1];
            var rkey = tmp[2];
            var wk_index = tmp[3]-0;


            var login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+wk_index+"_login_id").val();
            if(login_id!="" && login_id!=undefined){
              selectedPanel = "wkAUser_"+login_id;
              const assignPanel = "#wkACargoWorker_"+box_index+"_"+rkey+"_"+wk_index;
              wkASetWorker($(assignPanel).get(0),true,true,false);
            }
            if(wk_index % 2 == 1){ //右隣
              login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index+1)+"_login_id").val();
              if(login_id!="" && login_id!=undefined){
                selectedPanel = "wkAUser_"+login_id;
                const assignPanel = "#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index+1);
                wkASetWorker($(assignPanel).get(0),true,true,false);
              }
            }else{//左隣
              login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index-1)+"_login_id").val();
              if(login_id!="" && login_id!=undefined){
                selectedPanel = "wkAUser_"+login_id;
                const assignPanel = "#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index-1);
                wkASetWorker($(assignPanel).get(0),true,true,false);
              }
            }
            $("#wkAInfoBox").css("display","none");

            // wkASetWorkerによる表示切替を元に戻す
            if((selectedPanel=="" || selectedPanel.match(/wkAMachine_/)) && $("#wkAMachines").css("display")=="none") {
              wkAChangeViewMachineGroup();
            }

          }
          selectedPanel = "";
          //設定チェック
          if(!withoutLock){
            wkACkAssignment(robj.id,true);
            if(strassignment!=""){$.each(strassignment.split("|"),function(index,strid){if(strid!=""){wkACkAssignment(strid,true);}});}
          }
        }
      }
      $(robj).css("backgroundColor","")
    }else{
      wkASelectAssignment(robj)
    }
  }else{
    if(getPanelType(tmpSelectedPanel)=="UserPanel"){
      selectedPanel = tmpSelectedPanel;
      $("#"+selectedPanel).css("backgroundColor","yellow");
      if($("#wkAWorkers").css("display")=="none"){wkAChangeViewWokerGroup()}
    }
  }
}




//作業員にSet
function wkASetWorker(robj,withoutLock,continuous=false,renumber=true){
  // 作業員タブ表示
  if((selectedPanel=="" || selectedPanel.match(/wkAUser_/)) && $("#wkAWorkers").css("display")=="none"){
    wkAChangeViewWokerGroup();
  }

  let assignmentPanel = new AssignmentPanel(robj);
  const evt = event;
  const inContinue = continuous;
  const eventCancel = forceEventCancel;

  // 修飾キー押下時
  if(!inContinue && isModifiedEvent(evt) && !eventCancel){
    // 一括貼り付け
    if(isAltEvent(evt)){
      const isUserList = selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]=="wkAUser"
      if(!isUserList) return;
      const confirmMsg = `選択済みユーザー${selectedPanelArr.length}名を一括貼り付けしますか？\n対象ユーザ:${selectedPanelArr.map(robj=>{return `「${robj.innerHTML.substr(0,3)}」`})}`
      if(confirm(confirmMsg)){
        evt.altKey = false;
        $("#" + selectedAssignment).css("backgroundColor","");
        selectedAssignment = "";
        setAllSelectedPanel(
          robj,
          observer.observerFunction(wkASetWorker,window,null,['selectedPanel']), 
          1
        )
      }
    };
    // メッセージフォームの表示
    if(isShiftEvent(evt)){
      if(assignmentPanel.getValue('login_id')=="") return;
      wkAViewMsgBox(assignmentPanel.getValue('login_id'));
    }
    // 情報フォームの表示
    if(isCtrlEvent(evt)){
      if(assignmentPanel.getValue('login_id')=="") return;
      wkViewWorkerInfo(assignmentPanel.root,"wk");
    };
    return
  };
  clearSelectedPanelArr();

  const tmpSelectedPanel = selectedPanel;
  let tmpLockList = [];
  if(withoutLock){tmpLockList = unLockIfLocked(assignmentPanel.myId(),selectedPanel);}
  

  const unsetResult = wkAUnsetSelectAssignment(assignmentPanel.root);
  if (unsetResult) {
    // 入れ替えでない場合
    if (ck_result = selectedPanel.match(/^wkAUser_(\w+)/)) {
      let selectWorkerLoginId = ck_result[1];
      $("#wkAInfoBox").css("display", "none");
      var strassignment = "";
      // もともと設定された値をはがす
      var bc_login_id = assignmentPanel.getValue('login_id');
      var bc_work_index = assignmentPanel.getValue('work_index');
      var bc_text = assignmentPanel.getText();
      var locked = assignmentPanel.getValue('lock_flg');
      if (locked!="1") {
        selectedAssignment = assignmentPanel.myId();
        wkAUnSetAssignment(renumber);

        // 値を設定
        assignmentPanel.setValue('login_id', selectWorkerLoginId);
        if (!withoutLock) {
          assignmentPanel.setValue('lock_flg', 0);
        }

        // root_Panel -> 配番作業員パネル
        var root_Panel = $("#" + selectedPanel);
        let workerPanel = new ResourcePanel($("#" + selectedPanel)[0]);
        if (workerPanel.root!=null) {
          assignmentPanel.setText(root_Panel.text());
          assignmentPanel.root.className = workerPanel.root.className;

          if(assignmentPanel.getValue('lock_flg')=="1"){
            wkASetLockView(assignmentPanel.myId(), 1);
          }

          workerPanel.root.style.backgroundColor = "";
          workerPanel.root.classList.add("wkAIsAssigned");
          assignmentPanel.setValue('user_id',workerPanel.getValue('user_id'));
          if (tmp = assignmentPanel.myId().match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)) {
            var box_index = tmp[1];
            var rkey      = tmp[2];
            var wk_index  = tmp[3];

            // 作業区分
            assignmentPanel.setValue('work_class',$("#cargo_" + box_index + "_work_class").val());

            // 担当作業
            switch (rkey) {
              case "fm":
              case "dm":
                assignmentPanel.setValue('wk_class',rkey);
                break;
              default:
                var needCount = $("input[id^='needCount_" + box_index + "_" + rkey + "_']");
                if (needCount.length == 1) {
                  var key = needCount.attr("id").replace("needCount_" + box_index + "_" + rkey + "_", "");
                  assignmentPanel.setValue('wk_class',key);
                } else {
                  var m_type1 = $("#wkACargoMachine_" + box_index + "_" + rkey + "_" + wk_index + " input[id$='_m_type']").val();
                  if (m_type1 != "" && typeof m_type1 !== 'undefined') {
                    assignmentPanel.setValue('wk_class',m_type1);
                  } else {
                    var m_type2 = $("#wkACargoMachine_" + box_index + "_" + rkey + "_" + (wk_index - 1) + " input[id$='_m_type']").val();
                    if (m_type2 != "" && typeof m_type2 !== 'undefined') {
                      assignmentPanel.setValue('wk_class',m_type2);
                    }
                  }
                }
                break;
            }

            // 力量
            var competenceKey = wkSelectCompetenceKey(assignmentPanel.getValue('wk_class'), getCompetenceKeys(box_index, rkey, wk_index));
            if (competenceKey != "") {
              assignmentPanel.setValue("competence",workerPanel.getValue("competence_" + competenceKey));
            } else {
              assignmentPanel.setValue("competence","3");
            }

            // バス
            const upperMachine = "#wkACargoMachine_" + box_index + "_" + rkey + "_" + wk_index
            if ($(upperMachine + " input[id$='_m_type']").val() == "bs") {
              assignmentPanel.setValue("bus_flg","1");
            } else {
              assignmentPanel.setValue("bus_flg","0");
            }

            if (bc_login_id == "" || selectWorkerLoginId != bc_login_id) {
              // var assignmentForm = workerPanel.getValue("assignments");

              var assignmentForm = $("input[name='" + root_Panel.attr("id") + "[assignments]']");
              if (assignmentForm.length) {
                var work_index = null;
                if(tmpWorkIndex){
                  work_index = tmpWorkIndex;
                }else{
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
                assignmentPanel.setValue("work_index",work_index);
              } else {
                assignmentPanel.setValue("work_index","0");
              }

              if (assignmentPanel.getValue('work_index') - 0 > 0) {
                assignmentPanel.setText("(" + root_Panel.text() + ")");
              }
            } else {
              assignmentPanel.setValue("work_index",bc_work_index);
              assignmentPanel.setText(bc_text);
            }

            var s_time = '', e_time = '';
            let vacationData = root_Panel.find('input[id$="_base_no"]');
            if (vacationData && ["2", "3", "31", "32", "33", "34", "41", "42"].includes(vacationData.val())) {
              // -- s_time arriv_time・配番の出勤時間の遅い方
              let arrivData = root_Panel.find('input[id$="_arriv_time"]');
              s_time = pickTime(arrivData.val(),()=>getCargoITime(box_index),'later');

              //  -- e_time leav_time・配番の終了時間の早い方
              let leavData = root_Panel.find('input[id$="_leav_time"]');
              e_time = pickTime(leavData.val(),()=>getCargoETime(box_index),'earlier');
            } else {
              s_time = getCargoITime(box_index);
              e_time = getCargoETime(box_index);
            }

            // 就業時間・超過時間等を算出
            const busFlg = assignmentPanel.getValue("bus_flg");
            if(s_time!='' && e_time!='' && busFlg=="1"){
              const defSTime = getCargoITime(box_index);
              const [adjStime,adjEtime] = adjustStimeEtimeByBusFlags(s_time,e_time,defSTime,assignmentPanel.getValue("bus_flg"))
              s_time = adjStime
              e_time = adjEtime
            }
            assignmentPanel.setValue("s_time",s_time);
            assignmentPanel.setValue("e_time",e_time);

            // 所定
            if(s_time!='' && e_time!=''){
              var PWorkTime = wkCalcPWorkTime(s_time, e_time);
              assignmentPanel.setValue("p_work_time",PWorkTime["work_time"]);
              assignmentPanel.setValue("p_orver_time",PWorkTime["orver_time"]);
              // 法定
              var WorkTime  = wkCalcWorkTime(s_time, e_time, busFlg);
              assignmentPanel.setValue("work_time",WorkTime["work_time"]);
              assignmentPanel.setValue("orver_time",WorkTime["orver_time"]);
            }else{
              assignmentPanel.setValue("p_work_time",0);
              assignmentPanel.setValue("p_orver_time",0);
              assignmentPanel.setValue("work_time",0);
              assignmentPanel.setValue("orver_time",0);
            }
          }

          var assignmentForm = $("input[name='" + root_Panel.attr("id") + "[assignments]']");
          if (assignmentForm.length) {
            assignmentForm.val(assignmentForm.val() + "|" + assignmentPanel.myId() + "|");
          }
          selectedPanel = "";
          selectedAssignment = "";

        }

        // 設定チェック
        wkACkAssignment(assignmentPanel.myId(), true);
        if (strassignment != "") {
          $.each(strassignment.split("|"), function (index, strid) {
            if (strid != "") {
              wkACkAssignment(strid, true);
            }
          });
        }

        robjIdA = assignmentPanel.myId().split("_");
        WkARowReCount(robjIdA[1], withoutLock);
      }
      // 可能ユーザ設定の解除
      wkAUnSetChooseableUser();

    } else {
      wkASelectAssignment(assignmentPanel.root);
    }
  }else{
    if(getPanelType(tmpSelectedPanel)=="MachinePanel"){
      selectedPanel = tmpSelectedPanel;
      $("#"+selectedPanel).css("backgroundColor","yellow");
      if($("#wkAMachines").css("display")=="none"){wkAChangeViewMachineGroup()}

    }
  }

  // ロック復元
  tmpLockList.forEach((id)=>{
    wkASetLock($("#"+id).get(0));
  });
}

//可能ユーザ設定の解除
function wkAUnSetChooseableUser(){
    $("div[id^='wkAUser_'].wkAPanel").each(function(){
        $(this).css("backgroundColor","");
        if($("#"+$(this).attr("id")+"_assignments").val() ==""){
            $(this).removeClass("wkAIsAssigned");
          }else{
            $(this).addClass("wkAIsAssigned"); 
        }
    });
    $("div[id^='wkACargoWorker_'].wkAPanel").css("backgroundColor","");
}
//可能機械設定の解除
function wkAUnSetChooseableMachine(){
    $("div[id^='wkAMachine_'].wkAPanel").each(function(){
        $(this).css("backgroundColor","");
        if($("#"+$(this).attr("id")+"_assignments").val() ==""){
            // $(this).css("backgroundColor","");
            $(this).removeClass("wkAIsAssigned");
        }else{
            // $(this).css("backgroundColor","gray");
            $(this).addClass("wkAIsAssigned");
        }
    });
    $("div[id^='wkACargoMachine_'].wkAPanel").css("backgroundColor","");
}
//配番からはがす


//バス
function machineTypeOf(machine_id,type){
  let match = machine_id.match(/wkAMachine_\w+/)
  if(!match){return}
  let panel = $(machine_id + "_m_type")
  if(!panel){return false}
  return panel.val() == type
}


function wkAUnSetAssignment(renumber=true){
  if(selectedAssignment=="") return;
  var locked = $("#"+selectedAssignment+"_lock_flg").val()
  var strassignments = ""
  if(locked=="1") return;

  // 機械
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
  }

  // 作業員
  if(selectedAssignment.match(/^wkACargoWorker_/)){
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


  // 配番パネル
  $("#"+selectedAssignment).css("backgroundColor","").attr("class","wkAPanel");
  $("#"+selectedAssignment+"_text").text("");
  //再チェック
  wkACkAssignment(selectedAssignment,true);
  if(strassignments!=""){$.each(strassignments.split("|"),function(index,key){if(key!=""){wkACkAssignment(key,true);}});}
  wkAUnSetChooseableUser();
  selectedAssignment="";

  if(!unSetting){
    $("#wkAUnSetAssignmentBtn").prop('disabled', true);
    $("#my_body").css('cursor', "wait");
    unSetting = true;
    var panels = wkAgetSelectedAssignmentPanels();
    if(panels.length){
        panels.each(function(index,element){
            selectedAssignment = $(this).attr("id");
            wkAUnSetAssignment();
        });
    }
    unSetting = false;
    $("#my_body").css('cursor', "auto");
    $("#wkAUnSetAssignmentBtn").prop('disabled', false);
  }
}


//ロックとロック解除設定
function wkASetLock(robj){
    var id = "";
    if(robj.id.match(/^wkACargoMachine/)){
        id = $("#"+robj.id+"_machine_id").val()
    }else if(robj.id.match(/^wkACargoWorker_/)){
        id = $("#"+robj.id+"_user_id").val()
    }
    if(id!=""){
        var lockForm = $("#"+robj.id+"_lock_flg");
        if(lockForm.val()=="1"){
            lockForm.val("0");
            wkASetLockView(robj.id,0);
        }else{
            lockForm.val("1");
            wkASetLockView(robj.id,1);
        }
    }
}


//行列ロック（共通）
function wkALockColRow(robj){
    if(!unSetting){
        $("#my_body").css('cursor', "wait");
        unSetting = true;
        var lock_flg=0;
        if(robj.tag == "locked"){
            robj.tag = "unlock";
        }else{
            robj.tag = "locked";lock_flg=1;
        }
        var panels = wkAgetSelectedAssignmentPanels();
        if(panels.length){
            panels.each(function(index,element){
                var id="";
                if($(this).attr("id").match(/^wkACargoMachine/)){
                    id = $("#"+$(this).attr("id")+"_machine_id").val()
                }else if($(this).attr("id").match(/^wkACargoWorker_/)){
                    id = $("#"+$(this).attr("id")+"_user_id").val()
                }
                if(id!=""){
                    $("#"+$(this).attr("id")+"_lock_flg").val(lock_flg);
                    wkASetLockView($(this).attr("id"),lock_flg);
                }
            });
        }
        unSetting = false;
        $("#my_body").css('cursor', "auto");
    }
}
//列ロック
function wkALockCol(robj){
    if(!unSetting){
        if(selectedCol!=""){wkASelectCol(robj);}
        selectedCol = robj.id.split("_").pop();
        wkALockColRow(robj);
        selectedCol = "";
    }
}
//行ロック
function wkALockRow(robj){
    if(!unSetting){
        if(selectedRow!=""){wkASelectRow(robj);}
        selectedRow = robj.id.split("_").pop();
        wkALockColRow(robj);
        selectedRow = "";
    }
}
//選択範囲のAssignmentPanelを取得
function wkAgetSelectedAssignmentPanels(){
    var panels;
    if(selectedCol!="" &&  selectedRow!=""){
        panels = $("div[id^='wkACargoMachine_"+selectedRow+"_"+selectedCol+"_'],div[id^='wkACargoWorker_"+selectedRow+"_"+selectedCol+"_']");
    }else if(selectedCol!=""){
        panels = $("div[id^='wkACargoMachine_']"+"div[id*='_"+selectedCol+"_']"+","+"div[id^='wkACargoWorker_']"+"div[id*='_"+selectedCol+"_']");
    }else if(selectedRow!=""){
        panels = $("div[id^='wkACargoMachine_"+selectedRow+"_'],div[id^='wkACargoWorker_"+selectedRow+"_']");
    }else{
        panels = new Object();
    }
    return panels;
}
//言付け表示
function wkAViewMsgBox(login_id){
    if(login_id!=""){
        var userIdObj = $("#wkAUser_"+login_id+"_user_id");
        if(userIdObj.length && userIdObj.val() != "0"){
            $("#msgFormTo").text($("#wkAUser_"+login_id+"_name").val());
            var fobj = document.set_msg_form;
            if($("#wkAUser_"+login_id+"_created_uname").val()!=""){fobj.created_uname.value = $("#wkAUser_"+login_id+"_created_uname").val();}
            fobj.msg.value = $("#wkAUser_"+login_id+"_msg").val();
            fobj.login_id.value = login_id;
            fobj.user_id.value = $("#wkAUser_"+login_id+"_user_id").val();
            $("#msgFormBox").css("display","block");
        }
    }
}
function wkASendMsg(robj){
    var strErrorMassage="";
    var fobj = document.set_msg_form;
    strErrorMassage += check_Txt(fobj.created_uname,1,'発信者名','','64');
    strErrorMassage += check_Txt(fobj.msg,0,'言付け','','1024');
    if(strErrorMassage==""){
        $.ajax({
            url: fobj.action,
            type: fobj.method,
            data: $(fobj).serialize(),
            cache: false,
            dataType: 'json',
        }).done(function(data) {if(data["sts"]==200){
            login_id = fobj.login_id.value;
            $("#wkAUser_"+login_id+"_msg").val(fobj.msg.value);
            $("#wkAUser_"+login_id+"_created_uname").val(fobj.created_uname.value);
        }else{alert('更新エラー');}
        }).fail(function() {alert('更新エラー');
        }).always(function() {wkACloseMsgFormBox();});
    }else{alert(strErrorMassage);return false;}
}
function wkACloseMsgFormBox(){
    $("#msgFormBox").css("display","none");
}

//全チェック
function wkACkAllAssignment(){
    var ret=true;
    $("div[id^='wkACargoMachine_']").each(function(){ret &= wkACkAssignment($(this).attr("id"),false);});
    $("div[id^='wkACargoWorker_']").each(function(){ret &= wkACkAssignment($(this).attr("id"),false);});
    return ret;
}
//個別チェック
function wkACkAssignment(tObjId,ckAssignments){
    const reg = /^wkACargoMachine_\d+_mc+_\d+$/
    let id_matching = tObjId.match(reg)
    if(id_matching){return} // 機械列のパネルは検査対象外
    
    var tObjIdA = tObjId.split("_");
    var muFlg = tObjIdA[0];
    var row_index = tObjIdA[1];
    var block_id = tObjIdA[2];
    var wk_index = tObjIdA[3];
    var msgId = "ErrMsg_"+tObjId;
    var id,tmpMsg;
    var errMsgA=new Array();
    var ret = true;
    var tObj = $("#"+tObjId);
    var assignments = [];
    tObj.attr("err","0");
    switch(muFlg){
        case "wkACargoMachine" :
            id = $("#"+tObjId+"_machine_id").val();
            if(id!="" && typeof id !=='undefined'){
                //メンテナンスチェック
                if($("input[name='wkAMachine_"+id+"[maintenance]']").val() !=""){
                    tmpMsg = $("input[name='wkAMachine_"+id+"[name]']").val() + "は";
                    tmpMsg += $("input[name='wkAMachine_"+id+"[maintenance]']").val()
                    tmpMsg += "のため"+$("#wkAhead_"+block_id).text()+"に配番できません。";
                    tObj.attr("err","1");
                    errMsgA.push(tmpMsg);
                }
                //重複チェック
                //$("input[id^='wkACargoMachine_']input[id$='_machine_id']input[value='"+id+"']input[id!='"+tObjId+"_machine_id']").each(function(){
                //    if($(this).attr("id") != tObjId+"_machine_id" ){
                //        var tmpA = $(this).attr("id").split("_");
                //        var t_row_index = tmpA[1];
                //        var t_block_id = tmpA[2];
                //        var t_wk_index = tmpA[3];
                //        var work_no = $("#cargo_"+row_index+"_work_no").val();
                //        var t_work_no = $("#cargo_"+t_row_index+"_work_no").val();
                //        if(row_index == t_row_index || work_no!=t_work_no ){
                //            work_place1 = $("#cargo_"+row_index+"_work_place").val();
                //            work_place2 = $("#cargo_"+t_row_index+"_work_place").val();
                //            if((work_place1=="" && work_place2=="") || (work_place1!=work_place2)){
                //                move_no1 = $("#cargo_"+block[1]+"_move_no").val();
                //                move_no2 = $("#cargo_"+tmp[1]+"_move_no").val();
                //                if(move_no1!="HB999996" && move_no2!="HB999996" && move_no1!="HB999997" && move_no2!="HB999997"){
                //                    tmpMsg = $("input[name='wkAMachine_"+id+"[name]']").val() + "が";
                //                    tmpMsg+= "No"+work_no + "の" + $("#wkAhead_"+block_id).text() + "と";
                //                    tmpMsg+= "No"+t_work_no + "の" + $("#wkAhead_"+t_block_id).text() + "とで重複しています。";
                //                    tObj.attr("err","1");
                //                    $(this).attr("err","1");
                //                    errMsgA.push(tmpMsg);
                //                }
                //            }
                //        }
                //        assignments.push($(this).attr("id").replace("_machine_id",""));
                //    }
                //});
                //↑重複チェックはしない
                //場所可不可チェック->将来的に。
            }
            break;
        case "wkACargoWorker" :
            id = $("#"+tObjId+"_login_id").val();
            branch_cd = $("input[name='wkAUser_"+id+"[branch_cd]']").val();
            if(id!="" && typeof id !=='undefined' && branch_cd!="5" && branch_cd!="6"){
                //休暇チェック
                var base_no = $("input[name='wkAUser_"+id+"[base_no]']").val();
                var at_work = $("input[name='wkAUser_"+id+"[at_work]']").val();
                if( base_no !="" && base_no!="2" && base_no!="3" && base_no!="31" 
                      && base_no!="32" && base_no!="33" && base_no!="34" && base_no!="6" && at_work!="1" 
                ){
                    tmpMsg = $("input[name='wkAUser_"+id+"[s_name]']").val() + "は";
                    tmpMsg += $("input[name='wkAUser_"+id+"[vacation_info]']").val();
                    tmpMsg += "のため"+$("#wkAhead_"+block_id).text()+"に配番できません。";
                    tmpMsg += "["+id+"]["+branch_cd+"]";
                    tObj.attr("err","1");
                    errMsgA.push(tmpMsg);
                }
                //重複チェック
                //$("input[id^='wkACargoWorker_']input[id$='_login_id']input[value='"+id+"']input[id!='"+tObjId+"_login_id']").each(function(){
                //    if($(this).attr("id") != tObjId+"_login_id" ){
                //        var tmpA = $(this).attr("id").split("_");
                //        var t_row_index = tmpA[1];
                //        var t_block_id = tmpA[2];
                //        var t_wk_index = tmpA[3];
                //        var work_no = $("#cargo_"+row_index+"_work_no").val();
                //        var t_work_no = $("#cargo_"+t_row_index+"_work_no").val();
                //        if(row_index == t_row_index || work_no!=t_work_no ){
                //            tmpMsg = $("input[name='wkAUser_"+id+"[s_name]']").val() + "が";
                //            tmpMsg+= "No"+work_no + "の" + $("#wkAhead_"+block_id).text() + "と";
                //            tmpMsg+= "No"+t_work_no + "の" + $("#wkAhead_"+t_block_id).text() + "とで重複しています。";
                //            tObj.attr("err","1");
                //            $(this).attr("err","1");
                //            errMsgA.push(tmpMsg);
                //        }
                //        assignments.push($(this).attr("id").replace("_login_id",""));
                //    }
                //});
                //↑重複チェックはしない
                //作業可不可チェック
                var needComp = [];var canNotDo = true;
                var CompetenceKeys = getCompetenceKeys(row_index,block_id,wk_index);
                if(CompetenceKeys.length==0 && block_id=="wk"){
                  canNotDo = false;
                }else{
                  $.each(CompetenceKeys,function(index,CompetenceKey){
                    if($("#wkAUser_"+id+"_competence_"+CompetenceKey).val()-0 > 0){
                        canNotDo = false;
                    }
                    needComp.push(strCompetence[CompetenceKey]);
                  });
                }
                if(canNotDo && needComp.length > 0){
                  tmpMsg = $("input[name='wkAUser_"+id+"[s_name]']").val() + "は";
                  if(needComp.length==1){
                    tmpMsg+=needComp[0]+"はできません。";
                  }else{
                    tmpMsg+=needComp.join("、")+"のいずれもできません。";
                  }
                  tObj.attr("err","1");
                  errMsgA.push(tmpMsg);
                }
                //残業時間チェック
                
            }
            break;
    }
    //エラースタイル適用
    if(false){
      if(tObj.attr("err")=="1"){tObj.css("color","red").css("border-color","red");}
      else{tObj.css("color","").css("border-color","");}
    }
    //関連データチェック
    //if(ckAssignments){
    //$.each(assignments,function(index,strid){if(strid!=""){wkACkAssignment(strid,false)}});}
    //↑重複チェックしないので関連データチェックも行わない
    
    //エラーメッセージ表示
    if(false){
      errMsg = errMsgA.join("<br />");
      var ErrorMsgBox = $("#ErrorMsgBox"+row_index);
      if(ErrorMsgBox.length && msgId!=""){
          var ErrorMsg = $("#"+msgId);
          if(errMsg ==""){
              if(ErrorMsg.length){ErrorMsg.remove();}
          }else{
              if(ErrorMsg.length){ErrorMsg.html(errMsg);}
              else{ErrorMsgBox.append("<div id='"+msgId+"'>"+errMsg+"</div>");}
              ret = false;
          }
          if(ErrorMsgBox.text()==""){
              $("#ErrorMsgBtn"+row_index).css("display","none");
              ErrorMsgBox.css("display","none");
          }else{
              $("#ErrorMsgBtn"+row_index).css("display","");
              wkAErrorMsgView(row_index,"block");
          }
      }
    }

    return ret;
}
//エラーメッセージ表示
function wkAErrorMsgView(row_index,display){
    var robj = document.getElementById("ErrorMsgBtn"+row_index);
    var oTop = offsetTop(robj)-30-$("#wkAbodyCellL").scrollTop();
    var oLeft = offsetLeft(robj)+10;
    $("#ErrorMsgBox"+row_index).css("top",oTop+"px").css("left",oLeft+"px").css("display",display);
}
//保存
function wkAConfirmSave(){
  if(window.opener){
    if(confirm("このウィンドウを閉じて設定を保存しますか？")){
      window.opener.wkADoSave()
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

function wkADoSave(){
    var fobj = document.inform;
    if(fobj.conf_flg.checked){
        //if(wkACkAllAssignment() || confirm("エラーが残っています。\n配番確定しますか？")){
          if(ck_submitting()){fobj.submit();}
        //}
        //↑保存時の再チェック無し
    }else{
        if(ck_submitting()){fobj.submit();}
    }
}



//自動配番等実行
function wkADoCreate(mord){
    var msg="";
    $("html").css("cursor","wait");
    switch(mord){
    case "copyFM" : msg="前回FM配番のコピーを開始します。";break;
    case "copyDM" : msg="前回DM配番のコピーを開始します。";break;
    case "mkAssignment" : msg="自動配番を開始します。";break;
    }
    if(!confirm(msg+"\nよろしいですか？")){
      $("html").css("cursor","auto");
      return false;
    }
    $("#msgBox").text(msg).css("display","block");
    var fobj = document.create_form;
    fobj.mord.value = mord;
    //一旦現状を登録
    var inform = document.inform;
    $.ajax({
        url: inform.action,
        type: inform.method,
        data: $(inform).serialize(),
        cache: false,
        dataType: 'json',
    }).done(function(data) {
      if(data["ret"]==200){
        var fobj = document.create_form;

        $.ajax({
            url: fobj.action,
            type: fobj.method,
            data: $(fobj).serialize(),
            cache: false,
            dataType: 'json',
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
         $("html").css("cursor","auto");
         msg = data["msg"];
         msg += "<br /><br /><br /><input type='button' value='閉じる' onclick='$(\"#msgBox\").css(\"display\",\"none\");' />";
         $("#msgBox").html(msg);
      }
    }).fail(function() {$("html").css("cursor","auto");alert('事前保存エラー');console.log(data);
    }).always(function() {});
}
//Jobの実行チェック
function ckJob(){
  var fobj = document.create_form;
  var url = getUrl("wk_assignment")+"/delayed_jobs/";
  url+="WkAssignment_"+fobj.work_date.value;
    $.ajax({
        url: url,
        type: 'get',
        cache: false,
        dataType: 'json',
    }).done(function(data) {
       $("#msgBox").html(data["msg"]);
       switch(data["sts"]){
       case 404 : location.reload();break;
       case 303 : setTimeout(function(){ckJob();},5000);break;
       default:
           $("html").css("cursor","auto");
           msg = data["msg"];
           msg += "<br /><br /><br /><input type='button' value='閉じる' onclick='$(\"#msgBox\").css(\"display\",\"none\");' />";
           $("#msgBox").html(msg);
       }
    }).fail(function() {alert('実行エラー');
    }).always(function() {});
}

function syncChangeEventBetweenWindows(){
  // #wkAInfoBox
  const sub = window;
  const main = window.opener;
  [[main,sub],[sub,main]].forEach(([from,to])=>{
    from.addEventListener('change',(evt)=>{
      // 相方の要素を検索
      const element = evt.target;
      if(!['INPUT','SELECT','TEXTAREA'].includes(element.tagName)) return;
      // #wkAInfoBox 内の要素なら無視
      if(element.closest('#wkAInfoBox')) return;
      let elementInTarget = null;
      if(element.id){
        elementInTarget = to.document.getElementById(element.id);
      }
      if(!elementInTarget && element.name){
        if(element.tagName === 'INPUT' && element.type === 'radio'){
          elementInTarget = to.document.querySelector(`input[type="radio"][name="${element.name}"][value="${element.value}"]`);
        }else{
          const list = to.document.getElementsByName(element.name);
          elementInTarget = list && list.length ? list[0] : null;
        }
      }
      if(!elementInTarget) return;


      // 相方の要素を更新
      if(element.tagName === 'INPUT'){
        if(['checkbox','radio'].includes(element.type)){
          if(elementInTarget.checked !== element.checked){ elementInTarget.checked = element.checked; }
        }else{
          if(elementInTarget.value !== element.value){
            elementInTarget.value = element.value;
            // if(typeof to.changeS_Time === 'function') to.changeS_Time(elementInTarget); uat290により中止
            if(typeof to.calcWorkTime === 'function') to.calcWorkTime(elementInTarget);
          }
        }
      }else if(element.tagName === 'SELECT'){
        if(elementInTarget.multiple){
          const fromSelected = Array.from(element.options).map(o=>o.selected);
          Array.from(elementInTarget.options).forEach((opt,idx)=>{ opt.selected = !!fromSelected[idx]; });
        }else{
          if(elementInTarget.value !== element.value){ elementInTarget.value = element.value; }
        }
      }else if(element.tagName === 'TEXTAREA'){
        if(elementInTarget.value !== element.value){ elementInTarget.value = element.value; }
      }
        
    });
  });
}

// 初期同期（メインで既に変更済みのフォーム値をサブに反映）
function initialSyncBetweenWindows(){
  if(!window.opener) return;
  const sub = window;
  const main = window.opener;
  try{
    const formControls = Array.from(main.document.querySelectorAll('input, select, textarea'));
    for(const fromEl of formControls){
      const tag = fromEl.tagName;
      let toEl = null;
      // id があれば最優先でマッチ
      if(fromEl.id){
        toEl = sub.document.getElementById(fromEl.id);
      }
      // id が無い/見つからない場合は name でマッチ
      if(!toEl && fromEl.name){
        if(tag === 'INPUT' && fromEl.type === 'radio'){
          toEl = sub.document.querySelector(`input[type="radio"][name="${CSS.escape(fromEl.name)}"][value="${CSS.escape(fromEl.value)}"]`);
        }else{
          toEl = sub.document.querySelector(`${tag.toLowerCase()}[name="${CSS.escape(fromEl.name)}"]`);
        }
      }
      if(!toEl || toEl.tagName !== tag) continue;
      switch(tag){
        case 'INPUT':
          if(['checkbox','radio'].includes(fromEl.type)){
            if(toEl.checked !== fromEl.checked){ toEl.checked = fromEl.checked; }
          }else{
            if(toEl.value !== fromEl.value){
              toEl.value = fromEl.value;
              // if(typeof sub.changeS_Time === 'function') sub.changeS_Time(toEl); uat290により中止
              if(typeof sub.calcWorkTime === 'function') sub.calcWorkTime(toEl);
            }
          }
          break;
        case 'SELECT':
          if(toEl.multiple){
            const fromSelected = Array.from(fromEl.options).map(o=>o.selected);
            Array.from(toEl.options).forEach((opt,idx)=>{ opt.selected = !!fromSelected[idx]; });
          }else{
            if(toEl.value !== fromEl.value){ toEl.value = fromEl.value; }
          }
          break;
        case 'TEXTAREA':
          if(toEl.value !== fromEl.value){ toEl.value = fromEl.value; }
          break;
      }
    }
  }catch(e){
    console.error('initialSyncBetweenWindows error', e);
  }
}

// ------- 複数選択一括登録関係 -------------
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
  $(robj).addClass('selectKeep');
  selectedPanelArr.push(robj)
  return selectedPanelArr
}


//選択済みリストを配番パネルに貼り付け
function setAllSelectedPanel(robj,func,step){
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
        func(window,null,tpanel,false,true)
      }
    })
    clearSelectedPanelArr()
    return true
  }else{return false}
}

