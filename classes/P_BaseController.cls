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
                }
            }
        } catch(Exception e) {
            result = '==ERROR==';
        }

        return result;
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
