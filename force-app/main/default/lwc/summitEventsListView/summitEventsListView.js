/**
 * Created by nguy0092 on 4/17/2024.
 */

import {LightningElement, api, wire} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";

const columns = [
    // {
    //     label: "Event Instance",
    //     fieldName: "EventInstance"
    // },
    {
        label: "Event Name",
        fieldName: "EventName"
    },
    {
        label: "Event Date",
        fieldName: "EventDate",
        type: "text"
        // typeAttributes: {
        //     weekday: "long",
        //     year: "numeric",
        //     month: "long",
        //     day: "2-digit"
        // }
    },
    {
        label: "Event Time",
        fieldName: "EventTime",
        type: "text"
        // typeAttributes: {
        //     hour: "2-digit",
        //     minute: "2-digit"
        // }
    },
    {
        label: "Event Date & Time",
        fieldName: "EventDateTime",
        type: "text"
        // typeAttributes: {
        //     hour: "2-digit",
        //     minute: "2-digit"
        // }
    },
];

export default class SummitEventsListView extends LightningElement {

    events;
    errors;

    @api contactId;

    columns = columns;

    dateOptions = {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    };

    timeOptions = {
        hour: "2-digit",
        minute: "2-digit"
    };

    @wire(graphql, {
        query: gql`
          query SummitEventRegistrations ($contactId: ID) {
            uiapi {
              query {
                summit__Summit_Events_Registration__c (where: {summit__Contact__c: { eq: $contactId } }) {
                  edges {
                    node {
                      Id
                      Name {value}
                      summit__Event_Name__c {value}
                      summit__Event_Instance__c {value}
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
        variables: "$variables",
    })
    graphqlQueryResult({data, errors}) {
        if (data) {
            // this.results = data.uiapi.query.summit__Summit_Events_Registration__c.edges.map((edge) => edge.node);
            this.events = data.uiapi.query.summit__Summit_Events_Registration__c.edges.map((edge) => ({
                Id: edge.node.Id,
                EventName: edge.node.summit__Event_Name__c.value,
                EventInstance: edge.node.summit__Event_Instance__c.value,
                EventDate: new Date(edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value+'T'+edge.node.summit__Event_Instance__r.summit__Instance_Start_Time__c.value.slice(0, -8)).toLocaleDateString("en-US", this.dateOptions),
                EventTime: new Date(edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value+'T'+edge.node.summit__Event_Instance__r.summit__Instance_Start_Time__c.value.slice(0, -8)).toLocaleTimeString("en-US", this.timeOptions)+' - '+
                           new Date(edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value+'T'+edge.node.summit__Event_Instance__r.summit__Instance_End_Time__c.value.slice(0, -8)).toLocaleTimeString("en-US", this.timeOptions),
                EventDateTime: new Date(edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value+'T'+edge.node.summit__Event_Instance__r.summit__Instance_Start_Time__c.value.slice(0, -8)).toLocaleDateString("en-US", this.dateOptions)+' '+
                               new Date(edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value+'T'+edge.node.summit__Event_Instance__r.summit__Instance_Start_Time__c.value.slice(0, -8)).toLocaleTimeString("en-US", this.timeOptions)+' - '+
                               new Date(edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value+'T'+edge.node.summit__Event_Instance__r.summit__Instance_End_Time__c.value.slice(0, -2)).toLocaleTimeString("en-US", this.timeOptions)
            }));
        }
        this.errors = errors;
    }

    get variables() {
        return {
            contactId: this.contactId,

        }
    }

}