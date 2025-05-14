/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/2/2023.
 */


public with sharing class ReusableLookupController {
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();

        if (inputWrapper != null) {
            if (String.isNotBlank(inputWrapper.fieldApiName)) {
                List<String> sanitizedAllOtherFields = new List<String>();
                List<String> sanitizedOtherFields = new List<String>();
                List<String> sanitizedOtherPickListFields = new List<String>();
                List<String> sanitizedOtherMultiPickListFields = new List<String>();
                try {
                    String fieldsToQuery = 'SELECT Id, ';
                    //Check object accessiblity
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                    SObjectType objectToQuery = Schema.getGlobalDescribe().get(inputWrapper.objectApiName);
                    Map<String, SObjectField> fieldsMap = objectToQuery.getDescribe().fields.getMap();
                    try {
                        if (String.isNotBlank(inputWrapper.otherFieldApiName)) {
                            //Can be comma separated
                            List<String> otherFields = inputWrapper.otherFieldApiName.split(',');

                            for (String oField : otherFields) {
                                oField = oField.replaceAll('\\s+', '');
                                DescribeFieldResult fieldDescribe = fieldsMap.get(oField).getDescribe();
                                if (fieldDescribe.isAccessible()) {
                                    if (fieldDescribe.getType().name() == 'PICKLIST') {
                                        sanitizedOtherPickListFields.add(oField);
                                    } else if (fieldDescribe.getType().name() == 'MULTIPICKLIST') {
                                        sanitizedOtherMultiPickListFields.add(oField);
                                    } else {
                                        sanitizedOtherFields.add(oField);
                                    }
                                }
                            }

                            sanitizedAllOtherFields.addAll(sanitizedOtherFields);
                            sanitizedAllOtherFields.addAll(sanitizedOtherPickListFields);
                            sanitizedAllOtherFields.addAll(sanitizedOtherMultiPickListFields);

                            if (sanitizedAllOtherFields.size() > 0) {
                                fieldsToQuery = fieldsToQuery + ', ' + String.join(sanitizedAllOtherFields, ',');
                            }
                        }
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    }

                    if (inputWrapper.searchString.trim().length() > 3) {
                        String searchString = inputWrapper.searchString.trim().escapeHtml4();
                        String searchLikeString = '%' + searchString + '%';
                        String recordTypeName = inputWrapper.recordTypeName.trim().escapeHtml4();
                        String type = inputWrapper.type.trim().escapeHtml4();
                        String query = fieldsToQuery + ' FROM ' + inputWrapper.objectApiName;
                        String filterCriteria = '';

                        switch on fieldsMap.get(inputWrapper.fieldApiName).getDescribe().getType().name() {
                            when 'PICKLIST' {
                                filterCriteria = inputWrapper.fieldApiName + ' = :searchString ';
                            }
                            when 'MULTIPICKLIST' {
                                filterCriteria = inputWrapper.fieldApiName + ' INCLUDES (:searchString) ';
                            }
                            when else {
                                filterCriteria = inputWrapper.fieldApiName + ' LIKE :searchLikeString ';
                            }
                        }

                        for (String f : sanitizedOtherFields) {
                            filterCriteria += ' OR ' + f + ' LIKE :searchLikeString ';
                        }

                        for (String f : sanitizedOtherPickListFields) {
                            filterCriteria += ' OR ' + f + ' = :searchString ';
                        }

                        for (String f : sanitizedOtherMultiPickListFields) {
                            filterCriteria += ' OR ' + f + ' INCLUDES (:searchString) ';
                        }

                        if (String.isNotBlank(inputWrapper.selectedRecordId)) {
                            query += ' WHERE Id = : inputWrapper.selectedRecordId ';
                        } else if (String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)) {
                            query += ' WHERE ' + inputWrapper.parentFieldApiName + ' = \'' + inputWrapper.parentRecordId + '\'';
                            query += ' AND (' + filterCriteria + ')';
                        } else {
                            query += ' WHERE (' + filterCriteria + ')';
                        }

                        if (String.isNotBlank(recordTypeName)) {
                            query += ' AND RecordType.Name = :recordTypeName';
                        }

                        if (String.isNotBlank(type)) {
                            query += ' AND Type = :type';
                        }

                        if (String.isNotBlank(inputWrapper.andCriteria)) {
                            query += ' '+inputWrapper.andCriteria.trim();
                        }

                        if (String.isNotBlank(inputWrapper.orderByCriteria)) {
                            query += ' '+inputWrapper.orderByCriteria.trim();
                        }

                        query += ' LIMIT 50';
                        System.debug(query);

                        for (SObject s : Database.query(query)) {
                            ResultWrapper wrap = new ResultWrapper();
                            wrap.mainField = (String) s.get(inputWrapper.fieldApiName);
                            List<String> fieldValues = new List<String>();
                            for (String otherField : sanitizedAllOtherFields) {
                                if (String.isNotBlank((String) s.get(otherField))) {
                                    fieldValues.add((String) s.get(otherField));
                                }
                            }
                            wrap.subField = String.join(fieldValues, ', ');
                            wrap.id = (String) s.get('id');
                            returnWrapperList.add(wrap);
                        }
                    }
                    return returnWrapperList;

                } catch (Exception err) {
                    System.debug(err.getMessage());
                    throw new AuraHandledException(err.getMessage());
                }
            }

        }
        return returnWrapperList;
    }

    public class ResultWrapper {
        @AuraEnabled public String mainField { get; set; }
        @AuraEnabled public String subField { get; set; }
        @AuraEnabled public String id { get; set; }
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public String fieldApiName { get; set; }
        @AuraEnabled public String otherFieldApiName { get; set; }
        @AuraEnabled public String searchString { get; set; }
        @AuraEnabled public String selectedRecordId { get; set; }
        @AuraEnabled public String parentRecordId { get; set; }
        @AuraEnabled public String parentFieldApiName { get; set; }
        @AuraEnabled public String recordTypeName { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String andCriteria { get; set; }
        @AuraEnabled public String orderByCriteria { get; set; }
    }
}