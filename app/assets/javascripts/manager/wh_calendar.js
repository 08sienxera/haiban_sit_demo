//OnLoadイベント
$(function(){$("html").css("cursor","wait");whCalendarInit();$("html").css("cursor","auto");});
//データチェック＆取得
function whCalendarInit(){
  var defUrl = getUrl("wh_calendars")+"/wh_calendars/mkCol?";
  $("div[id^='whCalendarTbl_']").each(function(){
    if($(this).find("td.err").length){ //未設定
      var tmp = $(this).attr("id").split("_");
      var msgBox = $("#msgBox");
      msgBox.html(msgBox.html()+tmp[1]+"年"+tmp[2]+"月度の初期データを作成しています。しばらくお待ちください。<br />");
      msgBox.css("display","block");
      var url = defUrl+"t_year="+tmp[1]+"&t_month="+tmp[2];
      $.ajax({
        url: url,
        type: "GET",
        cache: false,
        dataType: 'html',
      }).done(function(data) {
        msgBox.css("display","none");
        $("#"+tmp.join("_")).html(data);
        whCalendarInit();
      }).fail(function() {
        alert('エラー');
      }).always(function() {
      });
      return false;
    }
  });
}
//休日／昼食注文先クリック||平日公休出勤上限数変更→適宜画面修正＆update
function changeCalendar(robj){
    var tmp = robj.id.split("_");
    var ymd = tmp.pop();
    var tkey = tmp.pop();
    var tCol,nVal,tVal,nextVal,calendarStr;
    switch(tkey){
    case "wh":
        tCol = "wh_flg";
        nVal = $('input[name="'+robj.id+'"]').val();
        nextVal = getNextVal(WhList,(nVal-0));
        calendarStr = getCalendarStr(ymd,nextVal);
        $('#'+robj.id).text(calendarStr).attr("class","selectCell whBox whBox"+nextVal[0]);
        tVal = nextVal[0];
        $('input[name="'+robj.id+'"]').val(tVal);
        var tbl = $(robj).parents("div[id^='whCalendarTbl_']");
        tbl.find("span[id^='sunday_num_']").text(tbl.find("input[id^='wh_'][value='1']").length);
        break;
    case "vd":
        tCol = "lunch_vendor_id";
        nVal = $('input[name="'+robj.id+'"]').val();
        nextVal = getNextVal(Vendors,nVal);
        $('#'+robj.id).text(nextVal[1]);
        tVal = nextVal[0];
        $('input[name="'+robj.id+'"]').val(tVal);
        break;
    case "hsettingmin":
        tCol = "h_setting_min";
        tVal = robj.value;
        break;
    }
    var fobj = document.inform;
    fobj.t_date.value = ymd;
    fobj.t_col.value = tCol;
    fobj.t_val.value = tVal;
    fobj.submit();
}

// カレンダー表記文字列を取得
function getCalendarStr(yyyymmdd,nextVal){
  var yyyy = yyyymmdd.slice(0,4) - 0;
  var mm = yyyymmdd.slice(4,6) - 0;
  var dd = yyyymmdd.slice(6,8) - 0;
  var wDate = new Date(yyyy, mm-1, dd);
  if(wDate.getDay()!==0 && nextVal[0]===1){
    return "所定休日";
  }
  return nextVal[1];
}

//ハッシュのリストから次の値をとる
function getNextVal(list,val){
    var tIndex = 0;
    $.each(list,function(index, value){
        if(value[0] === val){
            tIndex = (index+1);
        }
    });
    if(list[tIndex]){return list[tIndex];}
    else{return list[0];}
}