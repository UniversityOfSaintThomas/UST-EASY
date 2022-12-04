/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(UrlMapping='/admissioncounselor/*')

global with sharing class LocateCounselorAPI {

    private class CounselorInfo {
        // SF API NAMES: Name, Email, College__c, Major__c, Hometown__c, About_Me__c, What_I_Love_About_St_Thomas__c, Words_of_Advice__c
        String name { get; set; }
        String title { get; set; }
        String email { get; set; }
        String phone { get; set; }
        String college { get; set; }
        String major { get; set; }
        String hometown { get; set; }
        String about { get; set; }
        String USTLove { get; set; }
        String advice { get; set; }
        String smallPhoto { get; set; }
        String largePhoto { get; set; }
        String address { get; set; }
    }

    @HttpGet
    global static void getAdmissionsCounselorLookup() {
        String serializedJSON = '';

        RestResponse res = RestContext.response;
        String callback = '';

        if (String.isNotBlank(RestContext.request.params.get('callback'))) {
            callback = String.escapeSingleQuotes(RestContext.request.params.get('callback'));
        }
        if (String.isNotBlank(RestContext.request.params.get('type'))) {
            type = String.escapeSingleQuotes(RestContext.request.params.get('type'));
        }
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state'));
        }
        if (String.isBlank(callback)) {
            res.addHeader('Content-Type', 'application/json');
            callback = '';
        } else {
            res.addHeader('Content-Type', 'application/javascript');
        }
        
        if (type == 'highSchools') {
            serializedJSON = getHighSchools(state);
        } 
        else if (type == 'colleges') {

            //TODO type ahead colleges query

        } else {
            String counselor_id = getCounselorId();
            System.debug('counselor Id: ' + counselor_id);
            CounselorInfo counselor_info = getCounselorInfo(counselor_id);
            System.debug(counselor_info);
            serializedJSON = JSON.serialize(counselor_info);
        }

        if (!String.isBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    
    }

    private static String getCounselorId() {
        String student_type;
        String state;
        String high_school;
        String citizenship;
        String country;
        String admit_type;
    
        //Get URL variables
        if (String.isNotBlank(RestContext.request.params.get('studentType'))) {
            student_type = String.escapeSingleQuotes(RestContext.request.params.get('studentType')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('schoolId'))) {
            high_school = String.escapeSingleQuotes(RestContext.request.params.get('schoolId')).toLowerCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('transferType'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('transferType')).toUpperCase();
        }

        //Populate flow variables
        switch on student_type {
            when 'High School Student' {
                citizenship = 'US Citizen';
                country = 'United States';
            }
            when 'Veteran' {
                citizenship = 'US Citizen';
            }
            when 'Transfer Student' {
                admit_type = 'Transfer';
            }
            when 'International Student' {
                citizenship = 'International';
            }
            when 'Bernardi Student' {
                citizenship = 'US Citizen';
                country = 'Italy';
            }
        }

        Flow.Interview flw = new Flow.Interview.Locate_Your_Counselor_Subflow(
            new Map<String, String>{
                'Citizenship' => citizenship,
                'Country' => country,
                'Admit_Type' => admit_Type,
                'State' => state,
                'High_School' => high_school,
                'College_of_Interest' => 'Undergrad'
            }
        );
        flw.start();
        String counselor_id = (String) flw.getVariableValue('Opportunity_Owner_Id');

        return counselor_id;
    }


    private static CounselorInfo getCounselorInfo(String counselor_id) {
        doCRUD CRUDToDO = new doCRUD();
        User new_counselor = new User();
        String cascadeUserImage = '';
        
        new_counselor = CRUDToDO.getCounselorById(counselor_id);

        CounselorInfo newCounselorInfo = new CounselorInfo();
        cascadeUserImage = new_counselor.Name.replace(' ', '_').toLowerCase();
        cascadeUserImage = cascadeUserImage.replace('\'', '');
        cascadeUserImage = cascadeUserImage + '.jpg'.replace('\'', '');
        newCounselorInfo.name = new_counselor.Name;
        newCounselorInfo.email = new_counselor.Email;
        newCounselorInfo.college = (String.isNotBlank(new_counselor.College__c) ? new_counselor.College__c : '');
        newCounselorInfo.major = (String.isNotBlank(new_counselor.Major__c) ? new_counselor.Major__c : '');
        newCounselorInfo.hometown = (String.isNotBlank(new_counselor.Hometown__c) ? new_counselor.Hometown__c : '');
        newCounselorInfo.about = (String.isNotBlank(new_counselor.About_Me__c) ? new_counselor.About_Me__c : '');
        newCounselorInfo.USTLove = (String.isNotBlank(new_counselor.What_I_Love_About_St_Thomas__c) ? new_counselor.What_I_Love_About_St_Thomas__c : '');
        newCounselorInfo.advice = (String.isNotBlank(new_counselor.Words_of_Advice__c) ? new_counselor.Words_of_Advice__c : '');
        newCounselorInfo.title = (String.isNotBlank(new_counselor.Title) ? new_counselor.Title : '');
        newCounselorInfo.phone = new_counselor.Phone;
        //newCounselorInfo.smallPhoto = 'https://' + myDomain + (String.isNotBlank(new_counselor.SmallPhotoUrl) ? new_counselor.SmallPhotoUrl : '');
        //newCounselorInfo.largePhoto = 'https://' + myDomain + (String.isNotBlank(u.FullPhotoUrl) ? u.FullPhotoUrl : '');
        newCounselorInfo.largePhoto = 'https://www.stthomas.edu/_media-library/_locate-counselor/' + cascadeUserImage;
                
             
        return newCounselorInfo;
    }

    private static List<Account> getHighSchools(String state) {
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
        List<Account> highSchools = [
            SELECT Id, Name
            FROM Account
            WHERE RecordTypeId =: educational_institution_id
            AND Type = 'High School'
            AND State IN ('MN', 'WI')
            ORDER BY Name
        ];
        return highSchools;
    }

    public static List<Account> searchHighSchools(String searchTerm){
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
        List<Account> colleges = [
            FIND :search_term 
            IN NAME FIELDS 
            RETURNING Account(
                            Id, 
                            Name 
                        WHERE Type =: 'College' 
                        AND RecordTypeId =: educational_institution_id
                        ORDER BY Name
        )];
        return colleges;
    }

    private without sharing class doCRUD {

        public User getCounselorById(String counselorId) {
            User cUser = [
                    SELECT Name,
                           Title,
                           Phone,
                           Email,
                           Address,
                           College__c,
                           Major__c,
                           Hometown__c,
                           About_Me__c,
                           What_I_Love_About_St_Thomas__c,
                           Words_of_Advice__c  
                    FROM User
                    WHERE Id = :counselorId
                    AND Admissions_Counselor__c = TRUE
            ];
            return cUser;
        }
    }
}