public with sharing class P_SearchByIdController {
    
    @AuraEnabled
    public static Map<String, Object> search(String recordId) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            String sObjectName = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
            result = new Map<String, Object> {
                'sObjectName' => sObjectName
            };
        } catch (Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            result.put('ERROR_MSG', ERROR_MSG);
        }

        return result;
    }

}
