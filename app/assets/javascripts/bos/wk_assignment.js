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

    //サブウィンドウの初期化
    if(window.opener){
      WkASwitchWindow(2)
      syncChangeEventBetweenWindows(window.opener)
      $('#tDateTbl #tDateTbl').css('display','none')
      $('.wkABtn').each((i,v)=>{
        if(["FM前CP","DM前CP","自動配番","配番確定"].includes(v.value)){
          $(v).css('display','none')
        }
      })
    }else{
      // メインウィンドウの初期化
      WkAAddTDateTbl3Button();
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
        wkAUnSetAssignment();
        break;
      case 67 : //c
        wkAChangeAssignmentToPanel();
        break;
      case 86 : //v
        if(cpAria["tRow"]!=""){wkAPasteAriaToPanel();}
        break;
      //default:
      //  console.log("keydown:"+e.keyCode);
      }
    });

  
    //パネルの初期化＆臨時・人のカウント→パネルリストを閉じる：時間がかかるのでずらす
    setTimeout(function(){
      $("html").css("cursor","wait");
      WkAInitData();
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
            wkASetCanWork(selectedPanel);
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
    if(KeyboardEvent.shiftKey || event.shiftKey){
        wkAViewMsgBox($("input[name='"+robj.id+"[login_id]']").val());
    }else{
      if(wkASelectPanel(robj) && selectedAssignment==""){
        if(!(KeyboardEvent.altKey || event.altKey)){
          clearSelectedPanelArr()
        }
        pushSeletedPanelArr(robj)

        //休暇・力量情報表示
            var vText = "";
            var login_id = $("input[name='"+robj.id+"[login_id]']").val();
            var base_no = $("input[name='"+robj.id+"[base_no]']").val();
            if(base_no != ""){
                vText +="<tr><td colspan=8>"+$("input[name='"+robj.id+"[vacation_info]']").val()+"</td></tr>";
            }
            if(managerFlg==undefined){managerFlg=false;}
            if(managerFlg && (KeyboardEvent.ctrlKey || event.ctrlKey)){
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
            }
            if(vText!=""){
              vText = "<table class='soloidline'><tr><td colspan=8 class='listC'>"+$("input[name='"+robj.id+"[s_name]']").val()+"</td></tr>"+vText+"</table>";
            }
            wkAViewNote(robj,vText)
        }
        //配番パネル選択しており作業者パネルを選択した場合→配番パネルに反映
        if(selectedPanel!="" && selectedAssignment!=""){
            if(selectedAssignment.match(/^wkACargoWorker/)){wkASetWorker(document.getElementById(selectedAssignment),false);}
        }
    }
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
    wkASetCanWork("wkAUser_"+login_id);
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
    if(wkASelectPanel(robj) && selectedAssignment==""){
        if(!(KeyboardEvent.altKey || event.altKey)){
          clearSelectedPanelArr()
        }
        pushSeletedPanelArr(robj)

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
        if(selectedAssignment.match(/^wkACargoMachine/)){wkASetMachine(document.getElementById(selectedAssignment),false);}
    }
}
//配番の入れ替え＆＆選択をクリア
function wkAUnsetSelectAssignment(robj){
    var ret = true;
    if(selectedAssignment!=""){ //パネル選択済みの場合
        if(selectedAssignment!=robj.id && //選択済みパネルと選択パネルが異なる
            $("#"+robj.id+"_lock_flg").val() != "1" && //選択パネルがロックされていない
            $("#"+selectedAssignment+"_lock_flg").val() != "1" && //選択済みパネルがロックされていない
            robj.id.substr(0,15) == selectedAssignment.substr(0,15)){ //選択済みパネルと選択パネルが同じ種類（作業員と作業員、機械と機械）
            //入れ替え
            var tmp,fId,tId;
            $("html").css("cursor","wait");
            if(robj.id.match(/^wkACargoMachine/)){
                fId = $("#"+selectedAssignment+"_machine_id").val();tId = $("#"+robj.id+"_machine_id").val();
                //配番パネルのデータを入れ替え
                if(tId==""){
                  wkAUnSetAssignment();
                }else{
                  selectedPanel = "wkAMachine_"+tId;
                  fBox = $("#"+selectedAssignment).get(0);
                  selectedAssignment = "";
                  wkASetMachine(fBox);
                }
                if(fId==""){
                  selectedAssignment = robj.id;
                  wkAUnSetAssignment();
                }else{
                  selectedPanel = "wkAMachine_"+fId;
                  wkASetMachine(robj);
                }
            }else if(robj.id.match(/^wkACargoWorker_/)){
                fId = $("#"+selectedAssignment+"_login_id").val();tId = $("#"+robj.id+"_login_id").val();
                fBox = $("#"+selectedAssignment).get(0);
                //一旦どちらもはがず
                wkAUnSetAssignment();
                selectedAssignment = robj.id;
                wkAUnSetAssignment();
                selectedAssignment = "";
                //再選択を実施
                if(tId!=""){
                  selectedPanel = "wkAUser_"+tId;
                  wkASetWorker(fBox);
                }
                if(fId!=""){
                  selectedPanel = "wkAUser_"+fId;
                  wkASetWorker(robj);
                }
                $("#wkAInfoBox").css("display","none");
            }
            selectedAssignment="";
            selectedPanel="";
            wkAUnSetChooseableUser();
            $("html").css("cursor","auto");
            ret = !(fId!="" || tId!="");
        }else{
            $("#"+selectedAssignment).css("backgroundColor","");
        }
        selectedAssignment = "";
    }
    return ret;
}
//配番から選択(共通)
function wkASelectAssignment(robj){
    if(selectedAssignment==robj.id){
        return false;
    }else{
        selectedAssignment = robj.id
        $("#"+selectedAssignment).css("backgroundColor","yellow");
        var flg = (robj.id.match(/^wkACargoWorker/) ? "Workers" : "Machines");
        if($("#wkA"+flg).css("display")=="none"){wkAViewPanelList(flg);}
        $("#wkAInfoBox").css("display","none");
        if(block = robj.id.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)/)){
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
    if(KeyboardEvent.altKey || event.altKey && selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]=="wkAMachine" && continuous==false){
      if(confirm(`選択済み機械${selectedPanelArr.length}個を一括貼り付けしますか？\n対象機械:${selectedPanelArr.map(robj=>{return `「${robj.innerHTML.substr(0,robj.innerHTML.indexOf("<"))}」`})}`)){
        if(!setAllSelectedPanel(robj,wkASetMachine,2)){return}
      }else{return}
    }
    if(wkAUnsetSelectAssignment(robj)){
        if(ck_result = selectedPanel.match(/^wkAMachine_(\w+)/)){
            var bc_machine_id = $("#"+robj.id+"_machine_id").val()
            var locked = $("#"+robj.id+"_lock_flg").val()
            if(locked!="1" || withoutLock){
                var strassignment="";
                if(bc_machine_id!="" && typeof bc_machine_id !=='undefined'){
                    var assignmentForm = $("input[name='wkAMachine_"+bc_machine_id+"[assignments]']");
                    if(assignmentForm.length){
                        assignmentForm.val(assignmentForm.val().replace("|"+robj.id+"|",""));
                        strassignment = assignmentForm.val();
                        if(strassignment==""){$("#wkAMachine_"+bc_machine_id).css("backgroundColor","");}
                    }
                    //else{console.log("!!"+bc_machine_id);}
                }
                $("#"+robj.id+"_machine_id").val(ck_result[1]);
                if(!withoutLock){$("#"+robj.id+"_lock_flg").val(0);}
                var root_Panel = $("#"+selectedPanel);
                if(root_Panel.length){
                    $("#"+robj.id+"_text").text(root_Panel.text());
                    robj.className = root_Panel.attr("class");
                    if($("#"+robj.id+"_lock_flg").val()=="1"){wkASetLockView(robj.id,1);}
                    root_Panel.css("backgroundColor","gray");
                    var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
                    if(assignmentForm.length){assignmentForm.val(assignmentForm.val()+"|"+robj.id+"|");}
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
                        wkASetWorker($("#wkACargoWorker_"+box_index+"_"+rkey+"_"+wk_index).get(0));
                      }
                      if(wk_index % 2 == 1){ //右隣
                        login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index+1)+"_login_id").val();
                        if(login_id!="" && login_id!=undefined){
                          selectedPanel = "wkAUser_"+login_id;
                          wkASetWorker($("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index+1)).get(0));
                        }
                      }else{//左隣
                        login_id = $("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index-1)+"_login_id").val();
                        if(login_id!="" && login_id!=undefined){
                          selectedPanel = "wkAUser_"+login_id;
                          wkASetWorker($("#wkACargoWorker_"+box_index+"_"+rkey+"_"+(wk_index-1)).get(0));
                        }
                      } 
                      $("#wkAInfoBox").css("display","none");
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
    }
}
//作業員にSet
function wkASetWorker(robj,withoutLock,continuous=false){
    // continuous=>true はselectedPanelArrのデータを連続処理している状態
    if(KeyboardEvent.altKey || event.altKey && selectedPanelArr.length>0 && selectedPanelArr[0].id.split("_")[0]=="wkAUser" && continuous==false){
      if(confirm(`選択済みユーザー${selectedPanelArr.length}名を一括貼り付けしますか？\n対象ユーザ:${selectedPanelArr.map(robj=>{return `「${robj.innerHTML.substr(0,3)}」`})}`)){
        if(!setAllSelectedPanel(robj,wkASetWorker,1)){return}
      }else{return}
    }
    if($("#"+robj.id+"_login_id").val() !=""){ //配番作業員パネルに割当済みの場合
      var onShiftKey = false;
      if(event){onShiftKey=event.shiftKey;}
      else if(KeyboardEvent){onShiftKey=KeyboardEvent.shiftKey;}
      if(onShiftKey){
        wkAViewMsgBox($("#"+robj.id+"_login_id").val());
        return false;
      }
      var onCtrlKey = false;
      if(event){onCtrlKey=event.ctrlKey ;}
      else if(KeyboardEvent){onCtrlKey=KeyboardEvent.ctrlKey ;}
      if(onCtrlKey){
        wkViewWorkerInfo(robj,"wk");
        return false;
      }
    }
    if(wkAUnsetSelectAssignment(robj)){
        //入れ替えでない場合
        if(ck_result = selectedPanel.match(/^wkAUser_(\w+)/)){
            $("#wkAInfoBox").css("display","none");
            var strassignment="";
            //もともと設定された値をはがす
            var bc_login_id = $("#"+robj.id+"_login_id").val();
            var locked = $("#"+robj.id+"_lock_flg").val()
            if(locked!="1" || withoutLock){
                if(bc_login_id!="" && typeof bc_login_id !=='undefined'){
                    var assignmentForm = $("input[name='wkAUser_"+bc_login_id+"[assignments]']");
                    if(assignmentForm.length){
                        assignmentForm.val(assignmentForm.val().replace("|"+robj.id+"|",""));
                        strassignment = assignmentForm.val();
                        if(strassignment==""){$("#wkAUser_"+bc_login_id).css("backgroundColor","");}
                    }
                }
                //値を設定
                $("#"+robj.id+"_login_id").val(ck_result[1]);
                if(!withoutLock){$("#"+robj.id+"_lock_flg").val(0);}
                var root_Panel = $("#"+selectedPanel);
                if(root_Panel.length){
                    $("#"+robj.id+"_text").text(root_Panel.text());
                    robj.className = root_Panel.attr("class");
                    if($("#"+robj.id+"_lock_flg").val()=="1"){wkASetLockView(robj.id,1);}
                    root_Panel.css("backgroundColor","gray");
                    $("#"+robj.id+"_user_id").val(root_Panel.find('input[id$="_user_id"]').val());
                    if(tmp = robj.id.match(/^wkACargoWorker_(\d+)_(\w+)_(\d+)$/)){
                        var box_index = tmp[1];
                        var rkey = tmp[2];
                        var wk_index = tmp[3];
                        if(!withoutLock){
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
                                  //↑わざわざクリアしない
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
                          var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
                          if(assignmentForm.length){
                            var work_index = 0;
                            $.each(assignmentForm.val().split("|"),function(index,val){
                              if(val!=""){work_index++;}
                            });
                            $("#"+robj.id+"_work_index").val(work_index);
                          }else{
                            $("#"+robj.id+"_work_index").val("0");
                          }
                          if($("#"+robj.id+"_work_index").val()-0 > 0){
                            $("#"+robj.id+"_text").text("("+root_Panel.text()+")");
                          }


                          //開始
                          var s_time;
                          if(["3","31","33","41"].includes(root_Panel.find('input[id$="_base_no"]').val())){s_time=root_Panel.find('input[id$="_leav_time"]').val();}
                          else{if(check_Time($("#cargo_"+box_index+"_i_time").get(0),1,"出勤予定時刻")==""){s_time=$("#cargo_"+box_index+"_i_time").val();}else{s_time=RegularSTime;setError($("#cargo_"+box_index+"_i_time").get(0),"OFF");}}
                          $("#"+robj.id+"_s_time").val(s_time);
                          //終了予定時刻
                          var e_time;
                          if(["2","32","34","42"].includes(root_Panel.find('input[id$="_base_no"]').val())){e_time=root_Panel.find('input[id$="_leav_time"]').val();}
                          else{if(check_Time($("#cargo_"+box_index+"_e_time").get(0),1,"終了予定時刻")==""){e_time=$("#cargo_"+box_index+"_e_time").val();}else{e_time=RegularETime;setError($("#cargo_"+box_index+"_e_time").get(0),"OFF");}}

                          //就業時間＆超過時間等を算出
                          // 法定 
                          var WorkTime = wkCalcWorkTime(s_time,e_time,$("#"+robj.id+"_bus_flg").val());
                          $("#"+robj.id+"_s_time").val(WorkTime["s_time"]);
                          $("#"+robj.id+"_e_time").val(WorkTime["e_time"]);
                          $("#"+robj.id+"_work_time").val(WorkTime["work_time"]);
                          $("#"+robj.id+"_orver_time").val(WorkTime["orver_time"]);
                          // 所定
                          var PWorkTime = wkCalcPWorkTime(s_time,e_time,$("#"+robj.id+"_bus_flg").val());
                          $("#"+robj.id+"_p_work_time").val(PWorkTime["work_time"]);
                          $("#"+robj.id+"_p_orver_time").val(PWorkTime["orver_time"]);

                          //インフォメーションフォーム表示
                          if(!withoutLock){wkViewWorkerInfo(robj,"wk");}

                        }
                    }
                    var assignmentForm = $("input[name='"+root_Panel.attr("id")+"[assignments]']");
                    if(assignmentForm.length){
                        assignmentForm.val(assignmentForm.val()+"|"+robj.id+"|");
                    }
                    selectedPanel = "";
                }
                //設定チェック
                if(!withoutLock){
                    wkACkAssignment(robj.id,true);
                    if(strassignment!=""){$.each(strassignment.split("|"),function(index,strid){if(strid!=""){wkACkAssignment(strid,true);}});}
                }
                robjIdA = robj.id.split("_");
                WkARowReCount(robjIdA[1],withoutLock);
            }
            if(!withoutLock){
                //可能ユーザ設定の解除
                wkAUnSetChooseableUser();
            }
        }else{
            wkASelectAssignment(robj)
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
//配番からはがす
function wkAUnSetAssignment(){
    if(selectedAssignment!=""){
        var locked = $("#"+selectedAssignment+"_lock_flg").val()
        var strassignments = ""
        if(locked!="1"){
            if(selectedAssignment.match(/^wkACargoMachine_/)){
                var machine_id = $("#"+selectedAssignment+"_machine_id").val();
                var assignments = $("input[name='wkAMachine_"+machine_id+"[assignments]'");
                if(assignments.length){
                    assignments.val(assignments.val().replace("|"+selectedAssignment+"|",""));
                    strassignments=assignments.val();
                    if(strassignments==""){$("#wkAMachine_"+machine_id).css("backgroundColor","");}
                }
                $("#"+selectedAssignment+" input").val("");
            }else if(selectedAssignment.match(/^wkACargoWorker_/)){
                var login_id = $("#"+selectedAssignment+"_login_id").val();
                var assignments = $("input[name='wkAUser_"+login_id+"[assignments]'");
                if(assignments.length){
                    assignments.val(assignments.val().replace("|"+selectedAssignment+"|",""));
                    strassignments=assignments.val();
                    if(strassignments==""){$("#wkAUser_"+login_id).css("backgroundColor","");}
                }
                $("#"+selectedAssignment+" input").val("");
                var tmp = selectedAssignment.split("_");if(tmp.length > 1){WkARowReCount((tmp[1] -0),false);}
            }
            $("#"+selectedAssignment).css("backgroundColor","").attr("class","wkAPanel");
            $("#"+selectedAssignment+"_text").text("");
            //再チェック
            wkACkAssignment(selectedAssignment,true);
            if(strassignments!=""){$.each(strassignments.split("|"),function(index,key){if(key!=""){wkACkAssignment(key,true);}});}
            wkAUnSetChooseableUser();
            selectedAssignment="";
        }
    }
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
//配番パネル選択時にcでコピー用に従業員／機械パネルを選択する
//行または行列選択時にcでコピー、vでペースト
function wkAChangeAssignmentToPanel(){
  if(selectedRow!=""){
    cpAria["tRow"]=selectedRow;
    wkASelectRow($("#wkAbody_no_"+selectedRow).get(0));  //行選択を解除
    cpAria["tCol"]=selectedCol;
    if(selectedCol!=""){
      $("div[id^='wkAbody_"+selectedCol+"_']").css("backgroundColor","");  //列選択を解除
      selectedCol = "";
      $("#wkAbody_"+cpAria["tCol"]+"_"+cpAria["tRow"]).css("backgroundColor","orange");
    }else{
      $("div[id^='wkAbody'][id$='_row_"+cpAria["tRow"]+"']").css("backgroundColor","orange");
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
//行または行列選択時にcでコピー、vでペースト
function wkAPasteAriaToPanel(){
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
            tForm = $("#wkACargoMachine_"+selectedRow+"_"+idx[1]+"_"+idx[2]+"_machine_id");
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAMachine_"+$(this).val();
                wkASetMachine(tForm.parent().get(0),false);
              }
            }
          }
        });
        //現業職行
        reg = new RegExp("^wkACargoWorker_"+cpAria["tRow"]+"_(.+)_(\\d+)_login_id$");
        $("input[id^='wkACargoWorker_"+cpAria["tRow"]+"'][id$='_login_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            tForm = $("#wkACargoWorker_"+selectedRow+"_"+idx[1]+"_"+idx[2]+"_login_id");
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAUser_"+$(this).val();
                wkASetWorker(tForm.parent().get(0),false);
              }
            }
          }
        });
        //後始末
        $("div[id^='wkAbody'][id$='_row_"+cpAria["tRow"]+"']").css("backgroundColor","");
      }else{                   //指定行列エリアのみコピー
        var fAria = $("#wkAbody_"+cpAria["tCol"]+"_"+cpAria["tRow"]);
        //機械行
        reg = new RegExp("^wkACargoMachine_"+cpAria["tRow"]+"_"+cpAria["tCol"]+"_(\\d+)_machine_id$");
        fAria.find("input[id^='wkACargoMachine_'][id$='_machine_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            tForm = $("#wkACargoMachine_"+selectedRow+"_"+cpAria["tCol"]+"_"+idx[1]+"_machine_id");
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAMachine_"+$(this).val();
                wkASetMachine(tForm.parent().get(0),false);
              }
            }
          }
        });
        //現業職行
        reg = new RegExp("^wkACargoWorker_"+cpAria["tRow"]+"_"+cpAria["tCol"]+"_(\\d+)_login_id$");
        fAria.find("input[id^='wkACargoWorker_'][id$='_login_id']").each(function(){
          if(idx = $(this).attr("id").match(reg)){
            tForm = $("#wkACargoWorker_"+selectedRow+"_"+cpAria["tCol"]+"_"+idx[1]+"_login_id");
            if(tForm.length){  //コピー先がある
              if($(this).val()=="" && tForm.val()!=""){  //未設定→配番パネルを選択してはがす
                selectedAssignment = tForm.parent().attr("id")
                wkAUnSetAssignment();
              }else if($(this).val()!=""){               //設定→機械パネルを選択して配番パネルに配置
                selectedPanel = "wkAUser_"+$(this).val();
                wkASetWorker(tForm.parent().get(0),false);
              }
            }
          }
        });
        //後始末
        fAria.css("backgroundColor","");
        $("div[id^='wkAbody_"+selectedCol+"_']").css("backgroundColor","");  //列選択を解除
        selectedCol = "";
        
      }
      wkASelectRow($("#wkAbody_no_"+selectedRow).get(0));  //行選択を解除
      cpAria = {"tRow":"","tCol":""};  //選択情報をクリア
      selectedAssignment = "";
      unSetting = false;
      wkAViewPanelList("dummy");
    }
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
//列選択
function wkASelectCol(robj){
    var col_key = robj.id.split("_").pop();
    if(selectedCol != ""){$("div[id^='wkAbody_"+selectedCol+"_']").css("backgroundColor","");}
    if(selectedCol == col_key){
        selectedCol = "";
    }else{
        selectedCol = col_key;
        $("div[id^='wkAbody_"+selectedCol+"_']").css("backgroundColor","yellow");
    }
}
//行選択
function wkASelectRow(robj){
    if(selectedRow != ""){$.each(boxKeys,function(index,boxKey){$("#wkAbody"+boxKey.toUpperCase()+"_row_"+selectedRow).css("backgroundColor","");});}
    var row_index = robj.id.split("_").pop();
    if(selectedRow == row_index){
        selectedRow = "";
    }else{
        selectedRow = row_index;
        $.each(boxKeys,function(index,boxKey){$("#wkAbody"+boxKey.toUpperCase()+"_row_"+selectedRow).css("backgroundColor","yellow");});
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
    //エラー表示
    if(tObj.attr("err")=="1"){tObj.css("color","red").css("border-color","red");}
    else{tObj.css("color","").css("border-color","");}
    //関連データチェック
    //if(ckAssignments){
    //$.each(assignments,function(index,strid){if(strid!=""){wkACkAssignment(strid,false)}});}
    //↑重複チェックしないので関連データチェックも行わない
    
    //メッセージ表示
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
    }).fail(function() {$("html").css("cursor","auto");alert('事前保存エラー');//console.log(data);
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

function syncChangeEventBetweenWindows(target){
  let childWindow = window
  let parentWindow = target
  childWindow.addEventListener('change',(e)=>{
    if(['INPUT','SELECT','TEXTAREA'].includes(e.target.tagName)){
      let targetName = e.target.name
      let targetInParent = parentWindow.document.querySelector(`${e.target.tagName}[name="${targetName}"]`)
      if(!targetInParent){return}
      // 親ウィンドウで同一の要素が見つかった場合。（${e.target.name}）
      if(targetInParent.value!=e.target.value){
        targetInParent.value = e.target.value
      }
    }
  })
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
  if(selectedPanelArr.length>0){
    $(`#${selectedPanelArr[selectedPanelArr.length-1].id}`).addClass('selectKeep')
  }
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
      // console.log(tobj.classList,robj.classList)
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
