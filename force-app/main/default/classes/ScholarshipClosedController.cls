/**
 * Created by jjheaney on 5/2/2022.
 */

public class ScholarshipClosedController {
    public Scholarship__c scholarship { get; set; }
    public boolean scholarshipNotYetOpen { get; set; }
    public boolean scholarshipAlreadyClosed { get; set; }
    public String displayOpenDateTime { get; set; }
    public String displayCloseDateTime { get; set; }

    public ScholarshipClosedController() {
        this.scholarship = ScholarshipSharedUtilities.getScholarshipInfo();
        if (scholarship != null) {

            Map<String, Datetime> openCloseDatetime = ScholarshipSharedUtilities.scholarshipOpenCloseDatetime(scholarship);

            Datetime openDatetime = openCloseDatetime.get('Open');
            if(openDatetime != null) {
                this.displayOpenDateTime = displayDateTimeTz(openDatetime, 'America/Chicago');
            }

            Datetime closeDatetime = openCloseDatetime.get('Close');
            if(closeDatetime != null) {
                this.displayCloseDateTime = displayDateTimeTz(closeDatetime, 'America/Chicago');
            }

            if (openDatetime >= ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now())) {
                this.scholarshipNotYetOpen = true;
            } else if (closeDatetime <= ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now())) {
                this.scholarshipAlreadyClosed = true;
            }

//            if (this.scholarship.Open_Date__c >= ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now())) {
//                this.scholarshipNotYetOpen = true;
//            } else if (this.scholarship.Close_Date__c <= ScholarshipSharedUtilities.adjustForCentralTime(Datetime.now())) {
//                this.scholarshipAlreadyClosed = false;
//            }
        }
    }

    public static String displayDateTimeTz(Datetime scholarshipDatetime, String offSetTimeZone) {
        String dateTimeTzOffsetFormat = '';

        TimeZone tz = TimeZone.getTimeZone(offSetTimeZone);
        Integer TzOffset = tz.getOffset(scholarshipDatetime);
        Datetime dateTimeTzOffset = scholarshipDatetime.addSeconds(-(TzOffset/1000));
        dateTimeTzOffsetFormat = dateTimeTzOffset.format('EEEE MMMM dd, yyyy h:mm aa z', offSetTimeZone);

        return dateTimeTzOffsetFormat;
    }
}