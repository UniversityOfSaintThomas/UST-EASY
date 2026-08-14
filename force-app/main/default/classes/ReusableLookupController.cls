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
                    //Check object accessibility
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                    SObjectType objectToQuery = Schema.getGlobalDescribe().get(inputWrapper.objectApiName);
                    if (objectToQuery == null) {
                        throw new AuraHandledException('Unknown or inaccessible object: ' + inputWrapper.objectApiName);
                    }
                    Map<String, SObjectField> fieldsMap = objectToQuery.getDescribe().fields.getMap();

                    // The primary/search field is user-supplied — validate it against the object's field
                    // map (the map acts as the allow-list) before it is used in SELECT, WHERE, or the type switch.
                    if (!isAccessibleField(fieldsMap, inputWrapper.fieldApiName)) {
                        throw new AuraHandledException('Search field is not accessible: ' + inputWrapper.fieldApiName);
                    }
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

                    if (String.isNotBlank(inputWrapper.searchString) && inputWrapper.searchString.trim().length() > 3) {
                        String searchString = inputWrapper.searchString.trim().escapeHtml4();
                        String searchLikeString = '%' + searchString + '%';
                        String recordTypeName = String.isNotBlank(inputWrapper.recordTypeName) ? inputWrapper.recordTypeName.trim().escapeHtml4() : null;
                        String type = String.isNotBlank(inputWrapper.type) ? inputWrapper.type.trim().escapeHtml4() : null;
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

                        // Parse and criteria. NOTE: this is a free-form predicate that cannot be
                        // generically whitelisted, so it MUST originate from trusted admin configuration
                        // (design attributes / metadata) and never from end-user input.
                        if (String.isNotBlank(inputWrapper.andCriteria)) {
                            String andCriteria = inputWrapper.andCriteria.trim();
                            andCriteria = andCriteria.startsWithIgnoreCase('AND ') ? andCriteria : 'AND ' + andCriteria;
                            query += ' ' + andCriteria;
                        }

                        query += ' WITH USER_MODE';

                        // Parse order by criteria — validate the field against the object's field map
                        // (the allow-list) before appending, to prevent SOQL injection via the sort clause.
                        if (String.isNotBlank(inputWrapper.orderByCriteria)) {
                            String orderByInput = inputWrapper.orderByCriteria.trim();
                            String orderByField = orderByInput.replaceAll('(?i)^ORDER BY\\s+', '').trim().split('\\s+')[0];
                            if (isAccessibleField(fieldsMap, orderByField)) {
                                query += orderByInput.startsWithIgnoreCase('ORDER BY ') ? ' ' + orderByInput : ' ORDER BY ' + orderByInput;
                            }
                        }

                        query += ' LIMIT 50';

                        System.debug('searchLikeString: ' + searchLikeString);
                        System.debug(query);

                        for (SObject s : Database.query(query)) {
                            ResultWrapper wrap = new ResultWrapper();
                            System.debug('database return: ' + JSON.serializePretty(s));
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
                    System.debug('returnWrapperList: ' + returnWrapperList);
                    return returnWrapperList;

                } catch (Exception err) {
                    System.debug(err.getMessage());
                    throw new AuraHandledException(err.getMessage());
                }
            }

        }
        return returnWrapperList;
    }

    /**
     * @description Null-safe, case-insensitive check that a field exists on the object and is
     *              accessible to the running user. Used as the allow-list for every user-supplied
     *              field name that is concatenated into the dynamic SOQL string.
     *
     * @param fieldsMap  Field map from Schema.SObjectType.fields.getMap()
     * @param fieldName  The candidate field API name
     * @return true when the field exists and is FLS-accessible
     */
    private static Boolean isAccessibleField(Map<String, SObjectField> fieldsMap, String fieldName) {
        if (String.isBlank(fieldName)) {
            return false;
        }
        SObjectField token = fieldsMap.get(fieldName.trim());
        return token != null && token.getDescribe().isAccessible();
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