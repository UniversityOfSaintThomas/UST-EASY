/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/22/2022.
 */

public with sharing class EASYApplicationInfo {
    public Id appControlId { get; set; }
    public Id appId { get; set; }
    public Id contactId { get; set; }
    public Id requirementId { get; set; }
    public Boolean allowSubmit { get; set; }
    public Boolean allowConfirm { get; set; }
    public Boolean hideTermProgram { get; set; }
    public Boolean isExternalUser { get; set; }
    public String appStatus { get; set; }
    public String appSubStatus { get; set; }
    public String appStartStatus { get; set; }
    public String at { get; set; }
    public String citizenship { get; set; }
    public String submitStatus { get; set; }
    public String confirmStatus { get; set; }
    public String template { get; set; }
    public String withdrawStatus { get; set; }
    public String academicLevel { get; set; }
    public String allowCancelFrom { get; set; }
    public String allowSubmitFrom { get; set; }
    public String allowWithdrawFrom { get; set; }
    public String allowConfirmFrom { get; set; }
    public String intendedProgram { get; set; }
    public String intendedTerm { get; set; }
    public String schoolCollege { get; set; }

}