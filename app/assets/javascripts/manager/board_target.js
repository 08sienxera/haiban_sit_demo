/* ************************************************************************* */
/* 掲示板閲覧対象　設定用JS */
/* ************************************************************************* */
const SELECT_STATE = 'selected'
const LIST_EXPAND_STATE = 'close'
let userForm
let boardGroupForm
let selectedUserInput
// リクエスト送信
function goInput2(target){
    const boardTargets = document.getElementById('board_targets');
    // listにselectボックス内の全てのvalueを格納
    const list = []
    Array.from(boardTargets.options).forEach(opt=>list.push(opt.value))
    if(list.length<=0){alert("「公開対象」は１人以上選択してください。");return}
    var fobj=document.inform;
    if(iCheck(fobj)){
        // 掲示公開グループのIDをパラメータに追加
        let in_board_group = document.getElementById('in_board_group')
        let boardGroupId = in_board_group.options[in_board_group.selectedIndex].value
        setFormParam('name','inform',"board_group_id",boardGroupId,true)
        // 不要なパラメータを削除
        let unuseParamKeys = ["board_target","in_board_group"]
        unuseParamKeys.forEach((key)=>unsetFormParam('name','inform',key))
        // listをboard_targetsにセット
        setFormParam('name','inform',"board_targets",list,true)
        // DOMの更新を1秒待ち、リクエストを送信
        setTimeout(fobj.submit(),1000);

    }
    
}


function openForm(e,target){
    e.preventDefault();
    switch(target){
        case "user":
            userForm.style.display = 'block'
            boardGroupForm.style.display = 'none'
            initUserForm()
            recountSelectedUser()
            break;
        case "group":
            userForm.style.display = 'none'
            boardGroupForm.style.display = 'block'
            let boardGroupId = document.inform.querySelector("input[name=\"Board_in[board_group_id]\"]")
            if(boardGroupId==null || boardGroupId.value==""){boardGroupId.value="0"}
            break;
        default:
            return
    }
}
function initUserForm(){
    defSelectedUser = getSelectUser(selectedUserInput)
    let user_list = document.querySelectorAll(`#${userForm.id} li[id^="user_"]`)
    Array.from(user_list).forEach((user)=>{
        if(defSelectedUser.find(([nm,lid])=>user.id.split("_")[2]==lid)){
            user.classList.add('selected')
        }else{
            user.classList.remove('selected')
        }
    })
}
function getSelectUser(form){
    let selectedUserListElement
    let additionalUsers
    switch(form.id){
        case 'user_select_form' :
            selectedUserListElement = document.querySelectorAll("#user_select_form li[class='user selected']")
            additionalUsers = selectedUserListElement ?  Array.from(selectedUserListElement).map((ele)=>[ele.innerHTML,ele.id.split("_")[2]]) : []
            return additionalUsers
            break;
        case 'board_group_select_form' :
            let boardGroupId = in_board_group.options[in_board_group.selectedIndex].value
            if(boardGroupId==0){return [0,[]]}
            selectedUserListElement = document.querySelectorAll(`#board_group_select_form li[id^='user_${boardGroupId}_']`)
            additionalUsers = selectedUserListElement ?  Array.from(selectedUserListElement).map((ele)=>[ele.innerHTML,ele.id.split("_")[2]]) : []
            return [boardGroupId, additionalUsers]
            break;
        case 'board_targets' : 
            return Array.from(selectedUserInput.options).map((ele)=>[ele.innerHTML,ele.value])
            break;
    }
}
function closeForm(e,target){
    e.preventDefault();
    let additionalUsers
    switch(target){
        case "user":
            additionalUsers = getSelectUser(userForm)
            if(additionalUsers){
                let defOptions = selectedUserInput.options
                Array.from(defOptions).forEach((opt)=>{
                    let loginId = opt.value
                    const hasSameLoginId = Array.from(additionalUsers).find(([name,lid])=>lid==loginId)
                    if(hasSameLoginId){
                        // 後で削除するためのマーカーを付ける
                        hasSameLoginId[0] = 'remove'
                    }else{
                        // セレクトボックスから削除
                        opt.remove();
                    }
                })
                // 追加リスト内で削除マーカーがついているデータを除外
                additionalUsers = additionalUsers.filter(([nm,_])=>nm!='remove')
                // 追加リストに残っているユーザをセレクトボックスに追加
                additionalUsers.forEach(([nm,lid])=>{
                    const newOpt = document.createElement("option")
                    newOpt.innerHTML = nm
                    newOpt.value = lid
                    selectedUserInput.appendChild(newOpt)
                })
            }
            userForm.style.display = 'none'
            break;
        case "group":
            let boardGroupId
            [boardGroupId,additionalUsers] = getSelectUser(boardGroupForm)
            document.inform.querySelector("input[name=\"Board_in[board_group_id]\"]").value = boardGroupId
            if(boardGroupId!="0" && additionalUsers.length>=0){
                let defOptions = selectedUserInput.options
                Array.from(defOptions).forEach((opt)=>{opt.remove();})
                // 追加リストに残っているユーザをセレクトボックスに追加
                additionalUsers.forEach(([nm,lid])=>{
                    const newOpt = document.createElement("option")
                    newOpt.innerHTML = nm
                    newOpt.value = lid
                    selectedUserInput.appendChild(newOpt)
                })
            }
            boardGroupForm.style.display = 'none'
            break;
        default:
            return
    }
}

function updedateSelect(targets){
    const users = document.getElementsByClassName('user')
    Array.from(users).forEach((user)=>{
        const login_id = user.id.split("_")[2]
        user.classList.remove(SELECT_STATE)
        if(targets.includes(login_id)){
            user.classList.add(SELECT_STATE)
        }
    })
}

function recountSelectedUser(){
    let parentList = document.getElementsByClassName('parent_list')
    Array.from(parentList).forEach((ele)=>{
        let groupId = ele.id.split("_")[2]
        let selectedUser = document.querySelectorAll(`#user_select_form li[id^="user_${groupId}_"][class="user selected"]`)
        let humanCount = ele.getElementsByClassName('user_count')[0]
        humanCount.innerHTML = String(selectedUser.length)
        
    })
}
function toggleSelect(target,event=null){
    target.classList.toggle(SELECT_STATE);
    recountSelectedUser()
    if(event!=null){
        event.stopPropagation()
    }
}
function toggleTree(element){
    element.classList.toggle(LIST_EXPAND_STATE)
    if(element.classList.contains(LIST_EXPAND_STATE)){
        element.classList.remove('expand')
        element.querySelector('ul').style.display = 'none'

    }else{
        element.classList.add('expand')
        element.querySelector('ul').style.display = 'block'
    }
}


$(function() {
    // グローバル変数の初期設定
    userForm = document.getElementById('user_select_form')
    boardGroupForm = document.getElementById('board_group_select_form')
    selectedUserInput = document.getElementById('board_targets')

    // ユーザフォームの初期化（不要になる？
    const lists = document.querySelector('#user_select_form ul').children
    Array.from(lists).forEach((t)=>{toggleTree(t)})
    recountSelectedUser()


    
    const selectedUser = document.getElementById('board_targets')
    selectedUser.size = '5'
    selectedUser.addEventListener('keydown',(e)=>{
        e.preventDefault();
        if(e.key==="Backspace"||e.key==="Delete"){
            selectValue = String(e.target.value)
            if(selectValue==-1||selectValue==0){return}
            selectItem = e.target.options[e.target.selectedIndex]
            selectItem.remove();
        }
    })

    const bg_list = document.getElementById('in_board_group')
    bg_list.addEventListener('change',async (e)=>{
        e.preventDefault()
        selectedId = e.target.value
        const group_user = document.getElementsByClassName("bg_list")
        Array.from(group_user).forEach((el)=>{
            if(el.id.split("_")[1]===String(selectedId)){
                el.style.display = "block"
            }else{
                el.style.display = "none"
            }
        })
    })
    
});



