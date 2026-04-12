function gotoTDate(yyyymmdd){
    let redirectPath = new URL(window.location.href); 
    let params = redirectPath.searchParams;

    if (params.has('t_date')) {
        params.set('t_date', yyyymmdd);
    } else {
        params.append('t_date', yyyymmdd);
    }

    redirectPath.search = params.toString();
    window.location.href = redirectPath.toString();
}


$(function() {
    const tDateBox = document.getElementById('tdatebox')
    let manualInput = false
    tDateBox.addEventListener('keydown',function(event){
        manualInput = true        
        if(event.key==='Enter'){
            tDateBox.blur();
        }
    })
    tDateBox.addEventListener('blur',function(){
        if(manualInput){
            const inStr = tDateBox.value
            const date = new Date(inStr)
            const yyyy = String(date.getFullYear())
            const mm = date.getMonth()
            const dd = date.getDate()
            if(ckDate(yyyy,mm,dd)){
                const yyyymmdd = inStr.replaceAll("-","")
                gotoTDate(yyyymmdd)
            }else{
                alert("入力した日付は無効です")
            }
        }
        manualInput = false
    })
    tDateBox.addEventListener('change',function(event){
        const inStr = tDateBox.value
        const yyyymmdd = inStr.replaceAll("-","")
        if(!manualInput){
            gotoTDate(yyyymmdd)
        }
        manualInput = false
    })
});
