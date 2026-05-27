import {LightningElement, api} from 'lwc';
import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './comboBox.html';
import inputText from './inputText.html';
import inputCheck from './checkBox.html';

export default class CustomDataTable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'isdisabled'],
        },
        input: {
            template: inputText,
            typeAttributes: ['value', 'context'],
        },
        checkbox: {
            template: inputCheck,
            typeAttributes: ['value', 'context'],
        },
    };
}