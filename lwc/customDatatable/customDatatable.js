import LightningDatatable from 'lightning/datatable';
import customHyperlink from './customHyperlink.html';
import customCombobox from './customCombobox.html';
import customInput from './customInput.html';

export default class CustomDatatable extends LightningDatatable {

    static customTypes = {
        customHyperlink: {
            template: customHyperlink,
            typeAttributes: ['label','linkUrl','isApproved']
        },
        customCombobox: {
            template: customCombobox,
            typeAttributes : ['options','selectedRoles','relationshipId']
        },
        customInput: {
            template: customInput,
            typeAttributes : ['value','type','recordId','isDisabled']
        }
    };

}