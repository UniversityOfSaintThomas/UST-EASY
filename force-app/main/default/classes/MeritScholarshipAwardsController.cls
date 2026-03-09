/**
 * Created by nguy0092 on 10/13/2025.
 */

public without sharing class MeritScholarshipAwardsController {

    public class MeritScholarshipWrapper {
        @AuraEnabled public AwardInfoWrapper AwardInfo;
        @AuraEnabled public List<DomesticScholarshipsWrapper> DomesticScholarshipsList;
        @AuraEnabled public InternationalScholarshipWrapper InternationalScholarship;
        @AuraEnabled public OpportunityWrapper OpportunityFafsa;
    }

    public class AwardInfoWrapper {
        @AuraEnabled public String awardStatus;
        @AuraEnabled public Decimal awardAmount;
        @AuraEnabled public Decimal awardAdjAmount;
        @AuraEnabled public String awardAdjReason;
        @AuraEnabled public String scholarshipControllerName;
    }

    public class DomesticScholarshipsWrapper {
        @AuraEnabled public String scholarshipName;
        @AuraEnabled public Decimal scholarshipAmount;
        @AuraEnabled public Decimal scholarshipAdjAmount;
    }

    public class InternationalScholarshipWrapper {
        @AuraEnabled public Decimal scholarshipPercent;
        @AuraEnabled public Decimal scholarshipAdjPercent;
    }

    public class OpportunityWrapper {
        @AuraEnabled public Boolean fafsaFiled;
        @AuraEnabled public Boolean mnDreamActFiled;
        @AuraEnabled public Boolean notificationOfAward;

        public OpportunityWrapper(Boolean fafsaFiled, Boolean mnDreamActFiled, Boolean notificationOfAward) {
            this.fafsaFiled = fafsaFiled;
            this.mnDreamActFiled = mnDreamActFiled;
            this.notificationOfAward = notificationOfAward;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static MeritScholarshipWrapper getMeritAwards(String appId/*, String term, String domesticApplicant*/) {
        MeritScholarshipWrapper meritScholarshipWards = new MeritScholarshipWrapper();
        AwardInfoWrapper awardInfo = new AwardInfoWrapper();
        List<DomesticScholarshipsWrapper> domesticScholarshipsList = new List<DomesticScholarshipsWrapper>();
        InternationalScholarshipWrapper internationalScholarship = new InternationalScholarshipWrapper();
        OpportunityWrapper opportunityFafsa = new OpportunityWrapper(false, false, false);
        String term;

        List<Application__c> selectedApp = [
                SELECT Id,
                        Generic_Filter_4__c
                FROM Application__c
                WHERE Id = :appId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];

        if (!selectedApp.isEmpty()) {
            term = selectedApp[0].Generic_Filter_4__c;

            List<Award__c> award = [
                    SELECT Award_Status__c,
                            Award_Amount__c,
                            Adj_Award_Amount__c,
                            Scholarship_Award_Adjust_Reason__c,
                            Base_Merit_Amount__c,
                            Adj_Base_Merit_Amount__c,
                            Catholic_High_School_Scholarship__c,
                            Adj_Catholic_High_School_Scholar__c,
                            California_Pathway_Scholarship__c,
                            Adj_California_Pathway_Scholarship__c,
                            Colorado_Pathway_Scholarship__c,
                            Adj_Colorado_Pathway_Scholarship__c,
                            Cristo_Rey_Scholarship__c,
                            Adj_Cristo_Rey_Scholarship__c,
                            Illinois_Pathway_Scholarship__c,
                            Adj_Illinois_Pathway_Scholarship__c,
                            Kansas_Pathway_Scholarship__c,
                            Adj_Kansas_Pathway_Scholarship__c,
                            Milwaukee_Area_Pathway_Scholarship__c,
                            Adj_Milwaukee_Area_Pathway_Scholar__c,
                            Missouri_Pathway_Scholarship__c,
                            Adj_Missouri_Pathway_Scholarship__c,
                            Nebraska_Pathways_Scholarship__c,
                            Adj_Nebraska_Pathways_Scholarship__c,
                            Sauer_Cristo_Rey_Scholarship__c,
                            Adj_Sauer_Cristo_Rey_Scholarship__c,
                            Transfer_PTK_Scholarship__c,
                            Adj_Transfer_PTK_Scholarship__c,
                            INTL_Student_Scholarship_Percent__c,
                            ADJ_INTL_Student_Scholarship_Percent__c,
                            Related_Scholarship_Name__c
                    FROM Award__c
                    WHERE Admissions_Application_Id__c = :appId
                    AND (Related_Scholarship_Name__c LIKE 'UG Merit Scholarship%'
                    OR Related_Scholarship_Name__c LIKE 'UG INTL Merit Scholarship%'
                    OR Related_Scholarship_Name__c LIKE 'UG TR Merit Scholarship%')
                    AND Application_Term__c = :term
                    WITH SECURITY_ENFORCED
                    ORDER BY CreatedDate ASC
                    LIMIT 1
            ];

            for(Award__c a : award) {
                awardInfo.awardStatus = String.isNotBlank(a.Award_Status__c) ? a.Award_Status__c : '';
                awardInfo.awardAmount = a.Award_Amount__c != null ? a.Award_Amount__c : 0;
                awardInfo.awardAdjAmount = a.Adj_Award_Amount__c != null ? a.Adj_Award_Amount__c : 0;
                awardInfo.awardAdjReason = String.isNotBlank(a.Scholarship_Award_Adjust_Reason__c) ? a.Scholarship_Award_Adjust_Reason__c : '';
                awardInfo.scholarshipControllerName = String.isNotBlank(a.Related_Scholarship_Name__c) ? a.Related_Scholarship_Name__c : '';

                domesticScholarshipsList.add(createDomesticScholarships('St. Thomas Scholarship', a.Base_Merit_Amount__c, a.Adj_Base_Merit_Amount__c));
                domesticScholarshipsList.add(createDomesticScholarships('Catholic High School Scholarship', a.Catholic_High_School_Scholarship__c, a.Adj_Catholic_High_School_Scholar__c));
                domesticScholarshipsList.add(createDomesticScholarships('California Pathway Scholarship', a.California_Pathway_Scholarship__c, a.Adj_California_Pathway_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Colorado Pathway Scholarship', a.Colorado_Pathway_Scholarship__c, a.Adj_Colorado_Pathway_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Cristo Rey Scholarship', a.Cristo_Rey_Scholarship__c, a.Adj_Cristo_Rey_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Illinois Pathway Scholarship', a.Illinois_Pathway_Scholarship__c, a.Adj_Illinois_Pathway_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Kansas Pathway Scholarship', a.Kansas_Pathway_Scholarship__c, a.Adj_Kansas_Pathway_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Milwaukee Area Pathway Scholarship', a.Milwaukee_Area_Pathway_Scholarship__c, a.Adj_Milwaukee_Area_Pathway_Scholar__c));
                domesticScholarshipsList.add(createDomesticScholarships('Missouri Pathway Scholarship', a.Missouri_Pathway_Scholarship__c, a.Adj_Missouri_Pathway_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Nebraska Pathways Scholarship', a.Nebraska_Pathways_Scholarship__c, a.Adj_Nebraska_Pathways_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Sauer Cristo Rey Scholarship', a.Sauer_Cristo_Rey_Scholarship__c, a.Adj_Sauer_Cristo_Rey_Scholarship__c));
                domesticScholarshipsList.add(createDomesticScholarships('Transfer PTK Scholarship', a.Transfer_PTK_Scholarship__c, a.Adj_Transfer_PTK_Scholarship__c));

                internationalScholarship.scholarshipPercent = a.INTL_Student_Scholarship_Percent__c != null ? a.INTL_Student_Scholarship_Percent__c : 0;
                internationalScholarship.scholarshipAdjPercent = a.ADJ_INTL_Student_Scholarship_Percent__c != null ? a.ADJ_INTL_Student_Scholarship_Percent__c : 0;
            }

//            System.debug(awardInfo);
//            System.debug(domesticScholarshipsList);
//            System.debug(internationalScholarship);

            List<Opportunity> opportunities = [
                    SELECT Id,
                            FAFSA_Filed__c,
                            MN_Dream_Act_Filed__c,
                            Notification_of_Award_Date__c
                    FROM Opportunity
                    WHERE Admissions_Application__c = :appId
                    AND StageName IN ('Admit', 'Confirmed')
                    WITH SECURITY_ENFORCED
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
            ];

            for (Opportunity o : opportunities) {
                opportunityFafsa.fafsaFiled = o.FAFSA_Filed__c;
                opportunityFafsa.mnDreamActFiled = o.MN_Dream_Act_Filed__c;
                opportunityFafsa.notificationOfAward = o.Notification_of_Award_Date__c != null;
            }
        }

        meritScholarshipWards.AwardInfo = awardInfo;
        meritScholarshipWards.DomesticScholarshipsList = domesticScholarshipsList;
        meritScholarshipWards.InternationalScholarship = internationalScholarship;
        meritScholarshipWards.OpportunityFafsa = opportunityFafsa;

//        System.debug(meritScholarshipWards);

        return meritScholarshipWards;
    }

    public static DomesticScholarshipsWrapper createDomesticScholarships(String scholarshipName, Decimal scholarshipAmount, Decimal scholarshipAdjAmount) {
        DomesticScholarshipsWrapper domesticScholarships = new DomesticScholarshipsWrapper();
        domesticScholarships.scholarshipName = scholarshipName;
        domesticScholarships.scholarshipAmount = scholarshipAmount != null ? scholarshipAmount : 0;
        domesticScholarships.scholarshipAdjAmount = scholarshipAdjAmount != null ? scholarshipAdjAmount : 0;

        return domesticScholarships;
    }

}