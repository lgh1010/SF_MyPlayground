({
    init : function(component, event, helper) {

    },
    onkeypress : function(component, event, helper) {
        if(event.which == 13){
            component.search()
        }    
    },
    search : function(component, event, helper) {
        console.log('search')
    }

})
