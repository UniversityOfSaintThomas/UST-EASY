/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/22/2022.
 */

public with sharing class EASYApplicationInfo {
    public String at { get; set; }
    public Id appControlId { get; set; }
    public Id appId { get; set; }
    public Id contactId { get; set; }
    public Id requirementId { get; set; }
    public Boolean allowSubmit { get; set; }
    public Boolean isExternalUser { get; set; }
    public String citizenship { get; set; }
    public String appStatus { get; set; }
    public String appSubStatus { get; set; }
    public String appStartStatus { get; set; }
    public Boolean hideTermProgram { get; set; }
    public String template { get; set; }
    public String submitStatus { get; set; }
    public String withdrawStatus { get; set; }
    public String allowSubmitFrom { get; set; }
    public String allowCancelFrom { get; set; }
    public String allowWithdrawFrom { get; set; }
    public String academicLevel { get; set; }
    public String schoolCollege { get; set; }
}