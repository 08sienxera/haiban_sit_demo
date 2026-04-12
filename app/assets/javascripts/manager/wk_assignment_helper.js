//  -- Note --
//  クラス名の取得
//    object.constructor.name --> 'AssignmentPanel'
//  スーパークラスの取得
//    Object.getPrototypeOf(object)



class Panel {
    constructor(panel){
        this.root = panel
    }
    myId(){return this.root.id}
    assign(){throw new Error("assign()はサブクラスで実装してください")}
    unassign(){throw new Error("unassign()はサブクラスで実装してください")}
    isAssign(){throw new Error("isAssign()はサブクラスで実装してください")}
    getAssignPanel(){return this.assignPanel}
}
class AssignmentPanel extends Panel{
    constructor(panel){
        super(panel)
    }
    setValue(key,value){
        let tChildNode = document.getElementById(this.myId() + "_" + String(key));
        if(tChildNode==null){return null};
        tChildNode.value = value;
        return tChildNode.value;
    };
    getValue(key){
        let tChildNode = document.getElementById(this.myId() + "_" + String(key));
        if(tChildNode==null){return null};
        return tChildNode.value;
    };
    getText(){
        let tChildNode = document.getElementById(this.myId() + "_text");
        if(tChildNode==null){return null};
        return tChildNode.innerText;
    };
    setText(value){
        let tChildNode = document.getElementById(this.myId() + "_text");
        if(tChildNode==null){return null};
        tChildNode.innerText = value;
        return tChildNode.innerText;
    };
}

class ResourcePanel extends Panel{
    static STATUS_COLORS = {
        "assigned": "gray",
    };
    constructor(panel){
        super(panel)
    }
    setValue(key,value){
        let tChildNode = document.getElementById(this.myId() + "_" + String(key));
        if(tChildNode==null){return null};
        tChildNode.value = value;
        return tChildNode.value;
    };
    getValue(key){
        let tChildNode = document.getElementById(this.myId() + "_" + String(key));
        if(tChildNode==null){return null};
        return tChildNode.value;
    };
    getText(){
        return this.root.innerText;
    };
    setText(value){
        this.root.innerText = value;
        return this.root.innerText;
    };
    getAssignPanel(){
        const assignment_ids = this.getValue('assignments').replaceAll("||",",").replaceAll("|","")
        if(assignment_ids==='') return [];
        const assignment_panels = assignment_ids.split(",").map((id)=>{
            let element = document.getElementById(id);
            return element!=null ? new AssignmentPanel(element) : null;
        })
        return assignment_panels;
    }
        
    

}



class Observer {
    constructor(){
        this.observers = [];
    }
    addObserver(window){
        const alreadyIn = this.observers.some((win)=>{return win===window});
        if(alreadyIn) return;
        this.observers.push(window);
    }
    removeObserver(window){
        this.observers = this.observers.filter((win)=>{return win!==window});
    }

    forceSyncHTML(window){
        for (let win of this.observers) {
            if(win!==window){
                win.document.body.innerHTML = window.document.body.innerHTML;
            }
        }
    };
    
    observerFunction(originalFunction, reqWindow, shouldPropagate=()=>true, globalContext = []) {
        if (!this.observers.some(win => win === reqWindow)) return null;
        if (typeof originalFunction !== 'function') return null;
        const self = this;

        return function (window,context=null,...args) {
            const valueMap = {}
            const propagate = typeof(shouldPropagate)==='function' ? shouldPropagate(context) : true;
            // グローバル変数の更新（fireWindow → win）
            globalContext.forEach((key) => {
                const value = window[key];
                try {
                    valueMap[key] = structuredClone(value);
                } catch (error) {
                    valueMap[key] = JSON.parse(JSON.stringify(value));
                }
            });

            if(propagate){
                for (let win of self.observers) {
                    globalContext.forEach((key) => {
                        if(win===window)return;
                        if (typeof(win[key]) !== 'undefined') {
                            win[key] = valueMap[key];
                        }
                    });
                    // 関数の実行
                    if (typeof win[originalFunction.name] === 'function') {
                        win[originalFunction.name](...args);
                    }
                }
            }else{
                if (typeof window[originalFunction.name] === 'function') {
                    window[originalFunction.name](...args);
                }
            }
        };
    }



}