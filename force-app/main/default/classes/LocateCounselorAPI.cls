/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(UrlMapping='/admissioncounselor/*')

global without sharing class LocateCounselorAPI {

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

        String state = '';

        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state')).toUpperCase();
        }

        if (String.isNotBlank(RestContext.request.params.get('callback'))) {
            callback = String.escapeSingleQuotes(RestContext.request.params.get('callback'));
        }
        if (String.isBlank(callback)) {
            res.addHeader('Content-Type', 'application/json');
            callback = '';
        } else {
            res.addHeader('Content-Type', 'application/javascript');
        }
        if (RestContext.request.requestUri.endsWith('/highschools')) {
            serialized_json = JSON.serialize(getHighschools(state));
            
        } 
        else if (RestContext.request.requestUri.endsWith('/colleges')) {
            serialized_json = JSON.serialize(getColleges(state));
        } 
        else {
            String counselor_id = getCounselorId();
            System.debug('counselor Id: ' + counselor_id);
            CounselorInfo counselor_info = getCounselorInfo(counselor_id);
            System.debug(counselor_info);
            serialized_json = JSON.serialize(counselor_info);
        }
        //serialized_json = JSON.serialize(getHighschools());
        if (!String.isBlank(callback)) {
            serialized_json = callback + '(' + serialized_json + ')';
        }
        res.responseBody = Blob.valueOf(serialized_json);
    
    }

    public static String getCounselorId() {
        String student_type = '';
        String high_school_or_college = '';
        String citizenship = '';
        String country = '';
        String admit_type = '';
        String state = '';
    
        //Get URL variables
        if (String.isNotBlank(RestContext.request.params.get('studentType'))) {
            student_type = String.escapeSingleQuotes(RestContext.request.params.get('studentType')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('schoolId'))) {
            high_school_or_college = RestContext.request.params.get('schoolId');
        }

        //Populate flow variables
        switch on student_type {
            when 'HIGH SCHOOL STUDENT' {
                citizenship = 'US Citizen';
                country = 'United States';
                admit_type = 'First-Year';
            }
            when 'TRANSFER STUDENT' {
                admit_type = 'Transfer';
            }
            when 'INTERNATIONAL STUDENT' {
                citizenship = 'International';
            }
            when 'BERNARDI STUDENT' {
                citizenship = 'US Citizen';
                country = 'Italy';
            }
        }

        Flow.Interview flw = new Flow.Interview.Locate_Your_Counselor_Subflow(
            new Map<String, String>{
                'Citizenship' => citizenship,
                //'Country' => '', Error occurs when passing blank country with intl student
                'Admit_Type' => admit_type,
                'HS_or_College' => high_school_or_college,
                'College_of_Interest' => '4 Year College',
                'State' => state
            }
        );
        flw.start();
        String counselor_id = (String) flw.getVariableValue('Opportunity_Owner_Id');
        System.debug('counselor Id: ' + counselor_id);
        return counselor_id;
        //return '005P0000009nndT';
    }


    public static CounselorInfo getCounselorInfo(String counselor_id) {
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

   

    public static Map<String, String> getHighschools(String state){
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
        Map<String, String> highschools_map = new Map<String, String>();
            List<Account> highschools = [
                SELECT Id, Name
                FROM Account
                WHERE RecordTypeId = :educational_institution_id
                AND Type =: 'High School'
                AND BillingState = :state
                ORDER BY NAME DESC
            ];
           
            for (Account highschool : highschools) {
                highschools_map.put(String.valueOf(highschool.Id), highschool.name);
            }
            
        //highschools_map.put('123456789', 'Blaine High School');   
        return highschools_map;
    }


    public static Map<String, String> getColleges(String state){
        Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
        Map<String, String> colleges_map = new Map<String, String>();
            List<Account> colleges = [
                SELECT Id, Name
                FROM Account
                WHERE RecordTypeId = :educational_institution_id
                AND Type =: 'College'
                AND BillingState = :state
                ORDER BY NAME DESC
            ];
           
            for (Account college : colleges) {
                colleges_map.put(String.valueOf(college.Id), college.name);
            }
            
        //highschools_map.put('123456789', 'Blaine High School');   
        return colleges_map;
    }

    public without sharing class doCRUD {

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
    // public static Map<String, String> getColleges(){
    //     String search_term = '';
    //     if (String.isNotBlank(RestContext.request.params.get('searchTerm'))) {
    //         search_term = String.escapeSingleQuotes(RestContext.request.params.get('searchTerm'));
    //     }
    //     Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
    //     Map<String, String> colleges_map = new Map<String, String>();
    //         List<List<Account>> colleges = [
    //             FIND :search_term 
    //             IN NAME FIELDS 
    //             RETURNING Account(
    //                             Id,
    //                             Name
    //                         WHERE Type =: 'College' 
    //                         AND RecordTypeId =: educational_institution_id
    //                         ORDER BY Name
    //         )];
    //         for (List<Account> account_list : colleges) {
    //             for (Account college : account_list) {
    //                 colleges_map.put(String.valueOf(college.Id), college.Name);
    //             }
    //         }
            
    //     return colleges_map;
    // }

     // public static Map<String, String> getHighschools(){
    //     String search_term = '';
    //     if (String.isNotBlank(RestContext.request.params.get('searchTerm'))) {
    //         search_term = String.escapeSingleQuotes(RestContext.request.params.get('searchTerm'));
    //     }
    //     Id educational_institution_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institution').getRecordTypeId();
    //     Map<String, String> highschools_map = new Map<String, String>();
    //         List<List<Account>> highschools = [
    //             FIND :search_term 
    //             IN NAME FIELDS 
    //             RETURNING Account(
    //                             Id,
    //                             Name
    //                         WHERE Type =: 'High School' 
    //                         AND RecordTypeId =: educational_institution_id
    //                         ORDER BY Name
    //         )];
    //         for (List<Account> account_list : highschools) {
    //             for (Account highschool : account_list) {
    //                 highschools_map.put(String.valueOf(highschool.Id), highschool.name);
    //             }
    //         }
            
    //     return highschools_map;
    // }
