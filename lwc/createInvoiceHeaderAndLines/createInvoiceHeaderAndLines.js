import { api, LightningElement, track, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import ProductBillingFrequency_Field from "@salesforce/schema/Order.Product_Billing_Frequency__c";
import ServiceBillingFrequency_Field from "@salesforce/schema/Order.Service_billing_frequency__c";
import PaymentTerms_Field from "@salesforce/schema/Order.Contract.Payment_terms__c";
import callCreateInvoiceHeaders from '@salesforce/apex/InvoiceHeaderCreation.CreateInvoiceHeaders';
import callCountNonPSNonZeroOrderProducts from '@salesforce/apex/InvoiceHeaderCreation.CountNonPSNonZeroOrderProducts';
import getOrder from '@salesforce/apex/OrderTriggerManager.getOrder';
import pickListValueDynamically from '@salesforce/apex/InvoiceHeaderCreation.pickListValueDynamically';
import updateOrderRecord from '@salesforce/apex/InvoiceHeaderCreation.updateOrderRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [ProductBillingFrequency_Field, ServiceBillingFrequency_Field, PaymentTerms_Field];

export default class CreateInvoiceHeaderAndLines extends LightningElement {
    isLoading = false;
    @track isConfirmationBox = false;
    @track ProductBillingFrequencyValue;
    @track ServiceBillingFrequencyValue;
    paymentTerms;
    @api recordId;
    NonPSNonZeroOrderProductsCount;
    ProductBillingFrequencyValues;
    ServiceBillingFrequencyValues;
    @track isPicklistDisabled = true;
    isPicklistValueChanged = false;
    // @wire(getRecord, { recordId: '$recordId', fields })
    // order;
    // get ProductBillingFrequency() {
    //     return getFieldValue(this.order.data, ProductBillingFrequency_Field);
    // }
    // get ServiceBillingFrequency() {
    //     return getFieldValue(this.order.data, ServiceBillingFrequency_Field);
    // }
    // get PaymentTerms(){
    //     return getFieldValue(this.order.data, PaymentTerms_Field);
    // }

    async handle_CreateInvoice() {
        this.isLoading = true;
        /* try{
         this.NonPSNonZeroOrderProductsCount = await callCountNonPSNonZeroOrderProducts({OrderId : this.recordId,ServiceBillingFrequency : this.ServiceBillingFrequency});
         }
         catch(error){
             console.log('error '+error);
         }
         console.log('NonPSNonZeroOrderProductsCount ',this.NonPSNonZeroOrderProductsCount); */
        // if(this.NonPSNonZeroOrderProductsCount!=0){

        if (this.isPicklistValueChanged) {
            updateOrderRecord({
                orderId: this.recordId,
                productBillingFrequency: this.ProductBillingFrequencyValue,
                serviceBillingFrequency: this.ServiceBillingFrequencyValue
            })
                .then(result => {

                    this.callInvoiceHeaderCreation();
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('Error ' + JSON.stringify(error));
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'An Error has occured. Please contact your admin.',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                })
        } else {
            console.log('this.callInvoiceHeaderCreation();: ');
            this.callInvoiceHeaderCreation();
            console.log('this.callInvoiceHeaderCreation();: ');
        }

        //  }
        /*  else{
              this.isLoading = false;
              const event = new ShowToastEvent({
                  title : 'No Valid Invoice Lines',
                  message : 'There are no valid Invoice lines to be created automatically so no Invoice header can be generated. ',
                  variant : 'error'
              });
              this.dispatchEvent(event);
          } */

    }

    callInvoiceHeaderCreation() {
        console.log('callInvoiceHeaderCreation: ');
        callCreateInvoiceHeaders({
            OrderId: this.recordId,
            ProductBillingFrequency: this.ProductBillingFrequencyValue,
            ServiceBillingFrequency: this.ServiceBillingFrequencyValue,
            PaymentTerms: this.paymentTerms
        })
            .then(result => {
                this.isLoading = false;
                const event = new ShowToastEvent({
                    title: 'Invoice created',
                    message: 'Invoice Header record has been created successfully.',
                    variant: 'success'
                });
                this.dispatchEvent(event);

                location.reload();
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error ' + JSON.stringify(error));
                let message = '';
            if(error.body.fieldErrors.Invoice_Contact__c){
                message = error.body.fieldErrors.Invoice_Contact__c[0].message;
            }else{
                message = error.body.pageErrors[0].message;
            }
            const event = new ShowToastEvent({
                title : 'Error',
                message : message,
                //message : 'An Error has occured. Please contact your admin.',
                variant : 'error',
                mode: 'Sticky',
            });
            this.dispatchEvent(event);

                setTimeout(function () {
                    location.reload();
                }, 10000);
            })
    }

    connectedCallback() {
        // this.ProductBillingFrequencyValue = this.ProductBillingFrequency;
        // this.ServiceBillingFrequencyValue = this.ServiceBillingFrequency;
    }

    fetchOrderDetails() {

        getOrder({ OrdId: this.recordId })
            .then(data => {
                this.ProductBillingFrequencyValue = data.Product_Billing_Frequency__c;
                this.ServiceBillingFrequencyValue = data.Service_billing_frequency__c;
                this.paymentTerms = data.Contract && data.Contract.Payment_terms__c ? data.Contract.Payment_terms__c : null;
                this.orderYear = data.Order_Year__c;

                if (data && data.Order_Year__c && data.Order_Year__c != 1) {
                    this.isPicklistDisabled = false;
                } else {
                    this.isPicklistDisabled = true;
                }

                this.isConfirmationBox = true;
            })
            .catch(error => {
                console.log('Error---', error);
            });
    }

    hideConfirmationBox() {
        this.isConfirmationBox = false;
    }

    showConfirmationBox() {

        this.fetchOrderDetails();
    }


    @wire(pickListValueDynamically, {
        objectApiName: 'Order',
        selectPicklistApi: 'Product_Billing_Frequency__c'
    })
    wiredProductBillingFrequencyValues({ error, data }) {
        if (data) {
            this.ProductBillingFrequencyValues = data.map(objPL => {
                return {
                    label: objPL.label,
                    value: objPL.value
                };
            });
        } else if (error) {
            console.log('error---', error);
        }
    }

    @wire(pickListValueDynamically, {
        objectApiName: 'Order',
        selectPicklistApi: 'Service_Billing_Frequency__c'
    })
    wiredServiceBillingFrequencyValues({ error, data }) {
        if (data) {
            this.ServiceBillingFrequencyValues = data.map(objPL => {
                return {
                    label: objPL.label,
                    value: objPL.value
                };
            });
        } else if (error) {
            console.log('error---', error);
        }
    }

    productBillingFrequencyChangeValue(event) {
        this.ProductBillingFrequencyValue = event.target.value;
        this.isPicklistValueChanged = true;
    }

    serviceBillingFrequencyChangeValue(event) {
        this.ServiceBillingFrequencyValue = event.target.value;
        this.isPicklistValueChanged = true;
    }

}