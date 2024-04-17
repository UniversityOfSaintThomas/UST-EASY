/**
 * Created by nguy0092 on 4/17/2024.
 */

import {LightningElement, api, wire} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";

const columns = [
    {
        label: "Event",
        fieldName: "EventName"
    },
    {
        label: "End Date",
        fieldName: "EndDate",
        type: "date"
    },
    {
        label: "End Time",
        fieldName: "EndTime",
        type: "date",
        typeAttributes: {
            hour: "2-digit",
            minute: "2-digit"
        }
    },
];

export default class SummitEventsListView extends LightningElement {

    events;
    errors;

    columns = columns;

    @wire(graphql, {
        query: gql`
      query SummitEventRegistrations {
        uiapi {
          query {
            summit__Summit_Events_Registration__c {
              edges {
                node {
                  Id
                  Name {value}
                  summit__Event_Name__c {value}
                  summit__Event_Instance__r { summit__Instance_Start_Date__c {value} }
                  summit__Event_Instance__r { summit__Instance_Start_Time__c {value} }
                  summit__Event_Instance__r { summit__Instance_End_Time__c {value} }
                }
              }
            }
          }
        }
      }
    `,
    })
    graphqlQueryResult({data, errors}) {
        if (data) {
            // this.results = data.uiapi.query.summit__Summit_Events_Registration__c.edges.map((edge) => edge.node);
            this.events = data.uiapi.query.summit__Summit_Events_Registration__c.edges.map((edge) => ({
                Id: edge.node.Id,
                EventName: edge.node.summit__Event_Name__c.value,
                StartDate: edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value,
                StartTime: edge.node.summit__Event_Instance__r.summit__Instance_Start_Time__c.value,
                EndTime: edge.node.summit__Event_Instance__r.summit__Instance_End_Time__c.value,
            }));
        }
        this.errors = errors;
    }

}