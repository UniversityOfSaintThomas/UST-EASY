/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(UrlMapping='/admissioncounselor/*')

global with sharing class AdmissionsCounselorLookup {

    private class CounselorInfo {
        //Name,Email, College__c,Major__c, Hometown__c,About_Me__c,What_I_Love_About_St_Thomas__c,Words_of_Advice__c
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
        if (String.isNotBlank(RestContext.request.params.get('type'))) {
            String feedType = String.escapeSingleQuotes(RestContext.request.params.get('type'));
            String serializedJSON = '';

            RestResponse res = RestContext.response;
            String callback = '';

            if (String.isNotBlank(RestContext.request.params.get('callback'))) {
                callback = String.escapeSingleQuotes(RestContext.request.params.get('callback'));
            }

            if (String.isBlank(callback)) {
                res.addHeader('Content-Type', 'application/json');
                callback = '';
            } else {
                res.addHeader('Content-Type', 'application/javascript');
            }

            if (!String.isBlank(feedType)) {
                if (feedType.toLowerCase() == 'counselor') {
                    String counselor_id = getCounselorId();
                    CounselorInfo counselor_info = getCounselorInfo(counselor_id);
                    serializedJSON = JSON.serialize(counselor_info);
                // } else if (feedType.toLowerCase() == 'bio') {
                //     String counselorName = RestContext.request.params.get('name');
                //     if (String.isNotBlank(counselorName)) {
                //         counselorName.replace('%20', ' ');
                //         counselorName.replace('+', ' ');
                //         serializedJSON = JSON.serialize(counselorByName(counselorName));
                //     }
                // } else if (feedType.toLowerCase() == 'intl') {
                //     doCRUD CRUDToDo = new doCRUD();
                //     Counselor_Role__c intlId = CRUDToDo.getIntlCounselorByRole();
                //     if (intlId != null) {
                //         List<Id> intlIds = new List<Id>();
                //         intlIds.add(intlId.Staff_Member_Holding_Role__r.Id);
                //         serializedJSON = JSON.serialize(grabCounselorList(intlIds));
                //     }

                }
            }

            if (!String.isBlank(callback)) {
                serializedJSON = callback + '(' + serializedJSON + ')';
            }
            res.responseBody = Blob.valueOf(serializedJSON);
        }
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
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('highSchool'))) {
            high_school = String.escapeSingleQuotes(RestContext.request.params.get('highSchool')).toLowerCase();
        }

        //Populate flow variables
        switch on student_type {
            when 'High School Student' {
                citizenship = 'US Citizen';
                country = 'United States';
            }
            when 'US Veteran' {
                citizenship = 'US Citizen';
            }
            when 'Transfer Student' {
                admit_type = 'Transfer';
            }
            when 'International Student' {
                citizenship = 'International';
            }
            when 'US Citizen Living Outside US' {
                citizenship = 'US Citizen';
            }
        }

        Flow.Interview flw = new Flow.Interview.Locate_Your_Counselor_Subflow(
            new Map<String, Object>{
                'Citizenship' => citizenship,
                'Country' => country,
                'Admit_Type' => admit_Type,
                'State' => state,
                'High_School' => high_school
            }
        );
        flw.start();
        String counselor_id = (String) flw.getVariableValue('Opportunity_Owner_Id');

        return(counselor_id);
    }

   

    // private static List<CounselorInfo> counselorByName(String counselorId) {
    //     String cUserId;
    //     User cUser = new User();

    //     doCRUD CRUDToDo = new doCRUD();
    //     cUser = CRUDToDo.getCounselorById(counselorId);

    //     return grabCounselorList(cUser);
    // }


    private static CounselorInfo getCounselorInfo(String counselor_id) {
        doCRUD CRUDToDO = new doCRUD();
        User new_counselor = new User();
        String cascadeUserImage = '';
        //Get list off all users that match gathered list from geo areas
        
        new_counselor = CRUDToDO.getCounselorById(counselor_id);

        CounselorInfo newCounselorInfo = new CounselorInfo();
        cascadeUserImage = new_counselor.Name.replace(' ', '_').toLowerCase();
        cascadeUserImage = cascadeUserImage.replace('\'', '');
        cascadeUserImage = cascadeUserImage + '.jpg'.replace('\'', '');
        addCounselor.name = new_counselor.Name;
        addCounselor.email = new_counselor.Email;
        addCounselor.college = (String.isNotBlank(new_counselor.College__c) ? new_counselor.College__c : '');
        addCounselor.major = (String.isNotBlank(new_counselor.Major__c) ? new_counselor.Major__c : '');
        addCounselor.hometown = (String.isNotBlank(new_counselor.Hometown__c) ? new_counselor.Hometown__c : '');
        addCounselor.about = (String.isNotBlank(new_counselor.About_Me__c) ? new_counselor.About_Me__c : '');
        addCounselor.USTLove = (String.isNotBlank(new_counselor.What_I_Love_About_St_Thomas__c) ? new_counselor.What_I_Love_About_St_Thomas__c : '');
        addCounselor.advice = (String.isNotBlank(new_counselor.Words_of_Advice__c) ? new_counselor.Words_of_Advice__c : '');
        addCounselor.title = (String.isNotBlank(new_counselor.Title) ? new_counselor.Title : '');
        if (String.isNotBlank(new_counselor.Extension)) {
            addCounselor.phone = u.Phone + ' ext ' + new_counselor.Extension;
        } else {
            addCounselor.phone = (String.isNotBlank(new_counselor.Phone) ? new_counselor.Phone : '');
        }
        addCounselor.address = (String.isNotBlank(new_counselor.Street) ? (new_counselor.Street.replace('\n', '<br>') + ' <br>' + new_counselor.city + ', ' + new_counselor.State + ' ' + new_counselor.PostalCode) : '');
        addCounselor.smallPhoto = 'https://' + myDomain + (String.isNotBlank(new_counselor.SmallPhotoUrl) ? new_counselor.SmallPhotoUrl : '');
        //addCounselor.largePhoto = 'https://' + myDomain + (String.isNotBlank(u.FullPhotoUrl) ? u.FullPhotoUrl : '');
        addCounselor.largePhoto = 'https://www.stthomas.edu/_media-library/_locate-counselor/' + cascadeUserImage;
                
            
        
        return newCounselorInfo;
    }

    private without sharing class doCRUD {

        public List<User> getCounselorById(String counselorId) {
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
                    LIMIT 1
            ];
            return cUser;
        }
    }
}