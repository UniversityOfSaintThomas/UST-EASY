/**
 * Created by dahl3702 on 11/26/2018.
 */
@IsTest
public with sharing class LocateCounselorAPITest {

    @IsTest static void testCounselorLookup() {
        createTestData();
        Test.startTest();
        //studentType, schoolId, state, transferType
        getLookupFeed( 'High School Student', '0014P00002DoYt6QAF', 'MN', 'SCHTYPE-4PUBM'); // Private 4 Year College MN, Private 4 Year College Non-Mn, Public 2 Year College, Public 4 Year College MN 
        getLookupFeed( 'High School Student', '', '', '');                                  // Public 4 Year College Non-MN
        getLookupFeed( 'High School Student', '', '', '');
        getLookupFeed( 'Transfer Student', '', '', 'SCHTYPE-4PUBM');
        getLookupFeed( 'Transfer Student', '', '', 'SCHTYPE-2PRI');
        getLookupFeed( 'Veteran', '', '', '');
        getLookupFeed( 'International Student', '', '', 'SCHTYPE-INTLC');
        getLookupFeed( 'Bernardi Student', '', '', '');
        Test.stopTest();
    }

    private static void getLookupFeed(String studentType, String schoolId, String state, String transferType) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/applicantportal/services/apexrest/admissioncounselor';
        req.params.put('studentType', studentType);
        req.params.put('schoolId', schoolId);
        req.params.put('state', state);
        req.params.put('transferType', transferType);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        System.debug(req);
        RestContext.request = req;
        RestContext.response = res;

        LocateCounselorAPI.getAdmissionsCounselorLookup();
    }

    public static void createTestData() {

        // Setup 11 Test Users
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      
        List<User> uu = new List<User>();
        List<String> codes = new List<String> {'U45', 'U15', 'U1', 'U24', 'U3', 'U4', 'U20', 'U10', 'U12', 'D05', 'U41'};
        for(String c : codes) {
            Blob b = Crypto.generateAesKey(128);
            String h = EncodingUtil.convertToHex(b);
            String uid = h.substring(0,8);
            User u = new User(Alias = uid, Email= uid + '@myorg.com',
                    EmailEncodingKey='UTF-8',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/New_York', Username= uid + '@myorg.com',
                    FirstName = 'Test: ' + c,
                    LastName = 'Counselor',
                    College__c = 'St. Thomas',
                    Major__c ='Poly Sci',
                    Hometown__c = 'St. Paul',
                    Admissions_Counselor__c = true,
                    About_Me__c =' I\'m just this guy',
                    What_I_Love_About_St_Thomas__c = 'Everything',
                    Words_of_Advice__c = 'Don\t eat yellow snow!');

            uu.add(u);
        }
        insert(uu);
        //Creates 11 Admission Territories
        List<Admission_Territory__c> territories = new List<Admission_Territory__c>();
        Integer territoryNum = 0;
        for(String c : codes) {
            
            Admission_Territory__c at = new Admission_Territory__c(
                Name = 'Test Admission Territory' + territoryNum,
                Assigned_User__c = uu[territoryNum].Id,
                Unique_Code__c = c
                
            );
            territories.add(at);
            territoryNum++;
        }
        insert territories;

        Account schoolData = new Account(
                Name = 'Blaine High School',
                Admission_Territory__c = territories[0].Id
        );
        insert schoolData;
    }
}