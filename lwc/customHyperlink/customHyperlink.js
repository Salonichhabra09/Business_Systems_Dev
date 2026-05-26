import { LightningElement,api } from 'lwc';

export default class CustomHyperlink extends LightningElement {

    @api label;
    @api linkUrl;
    @api isApproved;

}