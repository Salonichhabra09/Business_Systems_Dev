import LightningDatatable from 'lightning/datatable';
import customLinkForActivities from './customLinkForActivities.html';

export default class CustomDatatbleForActivities extends LightningDatatable {

    static customTypes = {
        customLinkForActivities: {
            template: customLinkForActivities,
            typeAttributes: ['label','linkUrl','taskEvent']
        }
    };
}