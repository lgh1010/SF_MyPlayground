({
    getApexCallback : function(component, helper, methodName, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName)
            action.setParams(params)
            action.setCallback(helper, function(actionResult) {
                if(actionResult.getState() === 'SUCCESS') {
                    resolve({'c':component, 'h':helper, 'r':actionResult.getReturnValue()})
                } else {
                    let errors = actionResult.getError()
                    console.error(errors)
                }
            })
            $A.enqueueAction(action)
        }))
    }
})
