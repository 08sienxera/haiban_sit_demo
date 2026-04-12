/* ************************************************************************* */
/* 掲示板コメント用JS */
/* ************************************************************************* */
function showCommentForm(commentId){
    event.preventDefault();
    let boardCommentId = document.forms['update_comment_form'].elements['board_comment_id'];
    let commentArea = document.getElementById("commentArea");
    let clrBtn = document.getElementById("clear-btn");
    boardCommentId.value = null;
    commentArea.value = null;
    clrBtn.style.display = "none";

    if (commentId !== undefined) {
        clrBtn.style.display = "inline-block";
        let comment = document.getElementById(`board_comment_${commentId}`);
        let comment_text = comment.querySelector("span").innerHTML;
        commentArea.value = comment_text;
        boardCommentId.value = commentId;  
    }  ;
    document.getElementById("commentFormBox").classList.remove("deactive");
};
function closeCommentForm(){
    event.preventDefault();
    document.getElementById("commentFormBox").classList.add("deactive");
};
function doSubmit(){
    event.preventDefault();
    let boardCommentId = document.forms['update_comment_form'].elements['board_comment_id'];
    let commentArea = document.getElementById("commentArea");
    if(boardCommentId.value == ""){
        let createForm = document.forms['create_comment_form'];
        createForm.elements['board_comment_body'].value = commentArea.value;
        createForm.submit();
    }else{
        let updateForm = document.forms['update_comment_form'];
        updateForm.elements['board_comment_body'].value = commentArea.value;
        updateForm.submit();
    };
};
function doClear(){
    event.preventDefault();
    document.getElementById("commentArea").value = null;
    doSubmit();
};