/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 12/1/2022.
 */


public with sharing class CounselorInfoWidgetComponentController {

    public EASYApplicationInfo appInfoParam { get; set; }

    public class counselorWrap {
        //Name,Email, College__c,Major__c, Hometown__c,About_Me__c,What_I_Love_About_St_Thomas__c,Words_of_Advice__c
        public String CounselorName { get; set; }
        public String email { get; set; }
        public String title { get; set; }
        public String phone { get; set; }
        public String college { get; set; }
        public String major { get; set; }
        public String hometown { get; set; }
        public String about { get; set; }
        public String USTLove { get; set; }
        public String advice { get; set; }
        public String smallPhoto { get; set; }
        public String largePhoto { get; set; }
        public String address { get; set; }
        public String message { get; set; }
    }

    public CounselorInfoWidgetComponentController() {

    }

    public counselorWrap getAdmissionsCounselor() {

        counselorWrap cw = new counselorWrap();

        //Get app owner and app Message to applicant
        if (String.isNotBlank(appInfoParam.appId)) {
            Application__c app = [
                    SELECT OwnerId, Message_To_Applicant__c
                    FROM Application__c
                    WHERE Id = :appInfoParam.appId
            ];

            System.debug('APP ID:' + appInfoParam.appId);

            if (app != null) {
                //Get app owner user record
                doCRUD crud = new doCRUD();
                if (String.isNotBlank(app.OwnerId)) {
                    User u = crud.readUserById(app.OwnerId);

                    if (u != null) {

                        String cascadeUserImage;
                        cascadeUserImage = u.Name.replace(' ', '_').toLowerCase();
                        cascadeUserImage = cascadeUserImage.replace('\'', '');
                        cascadeUserImage = cascadeUserImage + '.jpg'.replace('\'', '');

                        cw.message = app.Message_To_Applicant__c;
                        cw.CounselorName = u.Name;
                        cw.email = u.Email;
                        cw.college = (String.isNotBlank(u.College__c) ? u.College__c : '');
                        cw.major = (String.isNotBlank(u.Major__c) ? u.Major__c : '');
                        cw.hometown = (String.isNotBlank(u.Hometown__c) ? u.Hometown__c : '');
                        cw.about = (String.isNotBlank(u.About_Me__c) ? u.About_Me__c : '');
                        cw.USTLove = (String.isNotBlank(u.What_I_Love_About_St_Thomas__c) ? u.What_I_Love_About_St_Thomas__c : '');
                        cw.advice = (String.isNotBlank(u.Words_of_Advice__c) ? u.Words_of_Advice__c : '');
                        cw.title = (String.isNotBlank(u.Title) ? u.Title : '');
                        if (String.isNotBlank(u.Extension)) {
                            cw.phone = u.Phone + ' ext ' + u.Extension;
                        } else {
                            cw.phone = (String.isNotBlank(u.Phone) ? u.Phone : '');
                        }
                        cw.address = (String.isNotBlank(u.Street) ? (u.Street.replace('\n', '<br>') + ' <br>' + u.City + ', ' + u.State + ' ' + u.PostalCode) : '');
                        cw.smallPhoto = '';
                        cw.largePhoto = 'https://www.stthomas.edu/_media-library/_locate-counselor/' + cascadeUserImage;
                    }
                }
            }
        }
        return cw;
    }

    private without sharing class doCRUD {

        private User readUserById(Id userId) {
            try {
                System.debug('OWNER ID: ' + userId);
                User cUser = [
                        SELECT Name, Email, College__c, Major__c, Hometown__c, About_Me__c, What_I_Love_About_St_Thomas__c, Words_of_Advice__c,
                                SmallPhotoUrl, FullPhotoUrl, Title, Phone, Street, State, City, PostalCode, Extension, Admissions_Counselor__c
                        FROM User
                        WHERE Id = :userId
                        AND Admissions_Counselor__c = TRUE
                ];
                return cUser;
            } catch (Exception e) {
                return null;
            }
        }

    }
}