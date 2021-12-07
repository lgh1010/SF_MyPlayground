({
    init : function(component, event, helper) {
        helper.getApexCallback(component, helper, 'getInit', {})
        .then($A.getCallback(result => {
            console.log('result : ', result.r)
            component.set("v.userInfo", result.r.userInfo)
        }))
    }
})
