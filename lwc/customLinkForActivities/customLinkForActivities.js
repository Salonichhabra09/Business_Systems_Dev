import { LightningElement,api } from 'lwc';

export default class CustomLinkForActivities extends LightningElement {

    @api label;
    @api linkUrl;
    @api taskEvent;

}