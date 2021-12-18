public with sharing class P_BaseController {
    private static String language = System.UserInfo.getLanguage();

    public P_BaseController() {

    }

    @AuraEnabled
    public Map<String, String> getLoginUserInfo() {
        Map<String, String> result = new Map<String, String>();

        try {
            User u = [
                SELECT Id,
                       Name,
                       Profile.Name,
                       Username,
                       Email
                FROM   User
                WHERE  Id = :UserInfo.getUserId()
            ];

            result.putAll(new Map<String, String> {
                'Id'       => u.Id,
                'Name'     => u.Name,
                'Profile'  => u.Profile.Name,
                'Username' => u.Username,
                'Email'    => u.Email
            });
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Map<String, String> getUserInfo(String userId) {
        Map<String, String> result = new Map<String, String>();

        try {
            User u = [
                SELECT Id,
                       Name,
                       LastName,
                       FirstName,
                       ContactId,
                       AccountId,
                       CommunityNickname,
                       Profile.Name,
                       Country,
                       Email
                FROM   User
                WHERE  Id = :userId
            ];

            result = new Map<String, String> {
                'Id' => u.Id,
                'FirstName' => u.FirstName,
                'LastName' => u.LastName,
                'ContactId' => u.ContactId,
                'AccountId' => u.AccountId,
                'CommunityNickname' => u.CommunityNickname,
                'Profile' => u.Profile.Name,
                'Country' => u.Country,
                'Email' => u.Email
            };
        } catch(Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            result.put('ERROR_MSG', ERROR_MSG);
            System.debug(ERROR_MSG);
        }

        return result;
    }

    public static String getSObjectNameByRecordId(String recordId) {
        String result = '';

        try {
            result = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        } catch(Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
        }

        return result;
    }

    public List<SelectOption> getPicklistOptions(String sObjectName, String fieldName, Boolean activeOnly) {
        List<SelectOption> result = new List<SelectOption>();

        try {
            for(Schema.PicklistEntry e : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if(activeOnly && e.isActive()) {
                    result.add(new SelectOption(e.getLabel(), e.getValue()));
                }
            }
        } catch(Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
        }

        return result;
    }

    public String translate(String language, String label, String en, String ko, String cn, String jp) {
        String result = label;

        try {
            Map<String, Boolean> translateIsExistMap = new Map<String, Boolean> {
                'label' => String.isNotBlank(label),
                'en' => String.isNotBlank(en),
                'ko' => String.isNotBlank(ko),
                'cn' => String.isNotBlank(cn),
                'jp' => String.isNotBlank(jp)
            };

            switch on language {
                when 'en_US' {
                    if(translateIsExistMap.get('en')) {
                        result = en;
                    } else {
                        result = label;
                    }
                } when 'ko' {
                    if(translateIsExistMap.get('ko')) {
                        result = ko;
                    } else {
                        result = label;
                    }
                } when 'cn' {
                    if(translateIsExistMap.get('cn')) {
                        result = cn;
                    } else {
                        result = label;
                    }
                } when 'jp' {
                    if(translateIsExistMap.get('jp')) {
                        result = jp;
                    } else {
                        result = label;
                    }
                } when else {
                    result = label;
                }
            }

            if(String.isBlank(result)) {
                if(translateIsExistMap.get('en')) {
                    result = en;
                } else {
                    result = '???';
                }
            }
        } catch(Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
            result = '==ERROR==';
        }

        return result;
    }

    public List<Object> getSObjectHistory(String recordId, List<String> fields, List<String> dataTypes) {
        List<Object> result = new List<Object>();

        String soql = 'SELECT Id, '
                    + '       Field, '
                    + '       OldValue, '
                    + '       NewValue, '
                    + '       DataType, '
                    + '       CreatedDate ';
        String query_from = '';
        String query_where = ' WHERE Id != null ';
        String query_order = ' ORDER BY Created DESC ';

        try {
            String sObj = String.valueOf(Id.valueOf(recordId).getSobjectType());

            String historyObj = sObj + 'History';
            if(sObj.endsWith('__c')) {
                historyObj = sObj.replace(sObj.substring(sObj.length() - 3, sObj.length()), '__History');
                query_where += ' AND ParentId = :recordId ';
            }
            query_from = ' FROM ' + historyObj;
            
            if(!fields.isEmpty()) {
                query_where += ' AND Field IN :fields ';
            }
            if(!dataTypes.isEmpty()) {
                query_where += ' AND DataType IN :dataTypes ';
            }

            result.addAll(Database.query(soql + query_from + query_where + query_order));
        } catch(Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
        }

        return result;
    }

    @AuraEnabled
    public static Map<String, List<String>> getReferenceFields(String recordId) {
        Map<String, List<String>> result = new Map<String, List<String>>();

        try {
            String sObjName = getSObjectNameByRecordId(recordId);
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();
            for(String label : fieldMap.keySet()) {
                if(!label.endsWith('id') && fieldMap.get(label).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
                    for(Schema.SObjectType objType : fieldMap.get(label).getDescribe().getReferenceTo()) {
                        String parentObj = objType.getDescribe().getName();
                        if(result.containsKey(parentObj) && !result.get(parentObj).isEmpty()) {
                            result.put(parentObj, (List<String>)result.get(parentObj).add(label));
                        } else {
                            result.put(parentObj, new List<String>{label});
                        }
                    }
                }
            }
        } catch (Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
        }

        return result;
    }

    @AuraEnabled
    public static String getLead(String recordId) {
        String result = '';

        try {
            for(Lead l : [SELECT Id, Name FROM Lead WHERE Id = :recordId]) {
                result += l.Name + ' ';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static string getDateSinceCreation(String recordId) {
        String result = '';

        try {
            String soql = 'SELECT {0} FROM {1} WHERE {2}';
            String fields = 'CreatedDate';
            String objName = getSObjectNameByRecordId(recordId);
            String condition = 'Id = ' + recordId;

            for(SObject obj : Database.query(String.format(soql, new List<Object>{fields, objName, condition}))) {
                switch on objName {
                    when 'Lead' {
                        Lead target = (Lead)obj;
                        result = target.CreatedDate.format('yyyy-MM-dd');
                    }
                }
            }
        } catch (Exception e) {
            String ERROR_MSG = '[' + e.getLineNumber() + '] ' + e.getMessage();
            System.debug(ERROR_MSG);
        }

        return result;
    }

    @AuraEnabled
    public static Date getToday() {
        return Date.today();
    }

    public class SelectOption {
        @AuraEnabled public String label       {get;set;}
        @AuraEnabled public String value       {get;set;}
        @AuraEnabled public String description {get;set;}

        public SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
        
        public SelectOption(String label, String value, String description) {
            this.label = label;
            this.value = value;
            this.description = description;
        }
    }

}