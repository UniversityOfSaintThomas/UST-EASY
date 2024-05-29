/**
 * Created by nguy0092 on 4/17/2024.
 * Displays Summit Event Registration in Easy Widget.
 * Aura app helper: summitEventsListApp
 * Invoked in Component: SummitEventsList
 */

import {LightningElement, api, wire} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";

export default class SummitEventsListView extends LightningElement {

    events;
    errors;
    eventsLength = true;

    @api contactId;

    // @api dateFilter

    @wire(graphql, {
        query: gql`
          query SummitEventRegistrations ($contactIdGql: ID) {
            uiapi {
              query {
                summit__Summit_Events_Registration__c ( where: { summit__Contact__c: { eq: $contactIdGql } 
                                                                 summit__Event_Instance__r: { summit__Instance_Start_Date__c: { gte: {literal: TODAY } } } 
                                                                 summit__Status__c: { in: ["Registered", "Confirmed", "In Progress"] }
                                                               },
                                                        orderBy: { summit__Event_Instance__r: { summit__Instance_Start_Date__c: { order: ASC } } 
                                                                 } 
                                                       ) 
                    {
                  edges {
                    node {
                      Id                   
                      Name {value}
                      summit__Event_Name__c {value}
                      summit__Event_Instance__c {value}
                      summit__Event_Instance__r { summit__Instance_Start_Date__c {value} }
                      summit__Event_Instance__r { summit__Instance_Start_Time__c {value} }
                      summit__Event_Instance__r { summit__Instance_End_Time__c {value} }
                      summit__Event_Instance__r { summit__Registration_Link__c {value} }
                      summit__Contact__c {value}
                      summit__Status__c {value}
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

            this.events = data.uiapi.query.summit__Summit_Events_Registration__c.edges.map((edge) => ({
                Id: edge.node.Id,
                EventName: edge.node.summit__Event_Name__c.value,
                EventInstance: edge.node.summit__Event_Instance__c.value,
                EventStartDate: edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value,
                EventStartDateTime: edge.node.summit__Event_Instance__r.summit__Instance_Start_Date__c.value + 'T' + edge.node.summit__Event_Instance__r.summit__Instance_Start_Time__c.value,
                EventRegistrationLink: edge.node.summit__Event_Instance__r.summit__Registration_Link__c.value.split("\"")[1],
            }));

            this.eventsLength = this.events.length;
        }
        this.errors = errors;
    }

    get variables() {
        return {
            contactIdGql: this.contactId,
            // dateFilter: this.dateFilter,
        }
    }

}