//eventに修飾キーの押下を含むか
function isModifiedEvent(event) {
  if(typeof(event)=='undefined') return false;
  return event.ctrlKey || event.shiftKey || event.altKey || event.metaKey;
}
function isAltEvent(event){
  if(typeof(event)=='undefined') return false;
  return event.altKey
}
function isShiftEvent(event){
  if(typeof(event)=='undefined') return false;
  return event.shiftKey
}
function isCtrlEvent(event){
  if(typeof(event)=='undefined') return false;
  return event.ctrlKey
}