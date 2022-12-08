/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-05-2022
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
        String ust_love { get; set; }
        String advice { get; set; }
        String small_photo { get; set; }
        String large_photo { get; set; }
        String address { get; set; }
    }

    @HttpGet
    global static void getAdmissionsCounselorLookup() {
        String serialized_json = '';

        RestResponse res = RestContext.response;
        String callback = '';

        if (String.isNotBlank(RestContext.request.params.get('callback'))) {
            callback = String.escapeSingleQuotes(RestContext.request.params.get('callback'));
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
        if (RestContext.request.requestUri.endsWith('/high_schools')) {
            serialized_json = getHighschools(state);
        } 
        else if (RestContext.request.requestUri.endsWith('/colleges')) {
            serialized_json = getColleges(search_term);
        } 
        else {
            String counselor_id = getCounselorId();
            System.debug('counselor Id: ' + counselor_id);
            CounselorInfo counselor_info = getCounselorInfo(counselor_id);
            System.debug(counselor_info);
            serialized_json = JSON.serialize(counselor_info);
        }

        if (!String.isBlank(callback)) {
            serialized_json = callback + '(' + serialized_json + ')';
        }
        res.responseBody = Blob.valueOf(serialized_json);
    
    }

    private static String getCounselorId() {
        String student_type;
        String state;
        String high_school_or_college;
        String citizenship;
        String country;
        String admit_type;
    
        //Get URL variables
        if (String.isNotBlank(RestContext.request.params.get('studentType'))) {
            student_type = String.escapeSingleQuotes(RestContext.request.params.get('studentType')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('highschoolId'))) {
            high_school_or_college = String.escapeSingleQuotes(RestContext.request.params.get('highschoolId')).toLowerCase();
        }
        else if (String.isNotBlank(RestContext.request.params.get('collegeId'))) {
            high_school_or_college = String.escapeSingleQuotes(RestContext.request.params.get('collegeId')).toLowerCase();
        }

        //Populate flow variables
        switch on student_type {
            when 'High School Student' {
                citizenship = 'US Citizen';
                country = 'United States';
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
                'HS_or_College' => high_school_or_college,
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
        String cascade_user_image = '';
        
        new_counselor = CRUDToDO.getCounselorById(counselor_id);

        CounselorInfo new_counselor_info = new CounselorInfo();
        cascade_user_image = new_counselor.Name.replace(' ', '_').toLowerCase();
        cascade_user_image = cascade_user_image.replace('\'', '');
        cascade_user_image = cascade_user_image + '.jpg'.replace('\'', '');
        new_counselor_info.name = new_counselor.Name;
        new_counselor_info.email = new_counselor.Email;
        new_counselor_info.college = (String.isNotBlank(new_counselor.College__c) ? new_counselor.College__c : '');
        new_counselor_info.major = (String.isNotBlank(new_counselor.Major__c) ? new_counselor.Major__c : '');
        new_counselor_info.hometown = (String.isNotBlank(new_counselor.Hometown__c) ? new_counselor.Hometown__c : '');
        new_counselor_info.about = (String.isNotBlank(new_counselor.About_Me__c) ? new_counselor.About_Me__c : '');
        new_counselor_info.ust_love = (String.isNotBlank(new_counselor.What_I_Love_About_St_Thomas__c) ? new_counselor.What_I_Love_About_St_Thomas__c : '');
        new_counselor_info.advice = (String.isNotBlank(new_counselor.Words_of_Advice__c) ? new_counselor.Words_of_Advice__c : '');
        new_counselor_info.title = (String.isNotBlank(new_counselor.Title) ? new_counselor.Title : '');
        new_counselor_info.phone = new_counselor.Phone;
        new_counselor_info.large_photo = 'https://www.stthomas.edu/_media-library/_locate-counselor/' + cascade_user_image;
                     
        return new_counselor_info;
    }

    private static List<Account> getHighschools(String state) {
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
        List<Account> high_schools = [
            SELECT Id, Name
            FROM Account
            WHERE RecordTypeId =: educational_institution_id
            AND Type = 'High School'
            AND State IN ('MN', 'WI')
            ORDER BY Name
        ];
        return high_schools;
    }

    public static List<Account> getColleges(String searchTerm){
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

        public User getCounselorById(String counselor_id) {
            User counselor_user = [
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
                    WHERE Id = :counselor_id
                    AND Admissions_Counselor__c = TRUE
            ];
            return counselor_user;
        }
    }
}