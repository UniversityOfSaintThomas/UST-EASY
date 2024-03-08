/**
 * Created by nguy0092 on 3/8/2024.
 */

import {api, LightningElement, track, wire} from 'lwc';
import {refreshApex} from "@salesforce/apex";
import {getFieldValue, getRecord, notifyRecordUpdateAvailable} from "lightning/uiRecordApi";;

const COLUMNS = [
    {
        label: 'Button Label',
        fieldName: 'button_label',
        type: 'text',
        initialWidth: 250,
        wrapText: true,
        hideDefaultActions: true
    },
    {
        label: 'Button Link',
        fieldName: 'button_link',
        type: 'text',
        wrapText: true,
        hideDefaultActions: true
    },
    {
        type: "button-icon",
        initialWidth: 45,
        wrapText: true,
        typeAttributes: {
            name: 'up',
            title: 'Move Up',
            value: 'up',
            iconPosition: 'center',
            iconName: 'utility:arrowup'
        }
    },
    {
        type: "button-icon",
        initialWidth: 45,
        wrapText: true,
        typeAttributes: {
            name: 'down',
            title: 'Move Down',
            value: 'down',
            iconPosition: 'center',
            iconName: 'utility:arrowdown',
        }
    },
    {
        type: "button-icon",
        initialWidth: 45,
        wrapText: true,
        typeAttributes: {
            name: 'delete',
            title: 'Delete Item',
            value: 'delete',
            iconPosition: 'center',
            iconName: 'utility:delete',
        }
    }
];

export default class AddButtonTest1 extends LightningElement {

    columns = COLUMNS;



}