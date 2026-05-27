import { LightningElement, api, wire, track } from 'lwc';
import getOpportunityLine from '@salesforce/apex/TopUpOpportunityController.getOpportunityLine';
import createTopUpOpportunity from '@salesforce/apex/TopUpOpportunityController.createTopUpOpportunity';
import updateTopUpOpportunityLines from '@salesforce/apex/TopUpOpportunityController.updateTopUpOpportunityLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from "lightning/platformResourceLoader";
import modalPopupCss from "@salesforce/resourceUrl/CssForMoveToAccount";
import { refreshApex } from '@salesforce/apex';

const columnsInsert = [
    { label: 'Solution', fieldName: 'solutionName', wrapText: true, hideDefaultActions: true },
    { label: 'Basis of Fees', fieldName: 'basisOfFees', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    { label: 'Use-case', fieldName: 'usecase', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    { label: 'Platform', fieldName: 'platform', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    { label: 'Original Solution Cap', fieldName: 'solutionCapOnOriginal', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    {
        label: 'Solution Cap', fieldName: 'solutionId', fixedWidth: 130, type: 'customInput', wrapText: true, hideDefaultActions: true,
        typeAttributes: {
            type: 'solutionCapTopUp',
            value: { fieldName: 'solutionCap' },
            recordId: { fieldName: 'solutionId' },
            isDisabled: { fieldName: 'isDisabled' }
        }
    },
    { label: 'Total Value', fieldName: 'solutionTotalValue', wrapText: true, hideDefaultActions: true }
    //{ type: 'button-icon', typeAttributes: { iconName: 'utility:refresh', name: 'refresh' } }
];

const columnsUpdate = [
    { label: 'Solution', fieldName: 'solutionName', wrapText: true, hideDefaultActions: true },
    { label: 'Basis of Fees', fieldName: 'basisOfFees', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    { label: 'Use-case', fieldName: 'usecase', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    { label: 'Platform', fieldName: 'platform', fixedWidth: 130, wrapText: true, hideDefaultActions: true },
    {
        label: 'Solution Cap', fieldName: 'solutionId', fixedWidth: 130, type: 'customInput', wrapText: true, hideDefaultActions: true,
        typeAttributes: {
            type: 'solutionCapTopUp',
            value: { fieldName: 'solutionCap' },
            recordId: { fieldName: 'solutionId' },
            isDisabled: { fieldName: 'isDisabled' }
        }
    },
    { label: 'Total Value', fieldName: 'solutionTotalValue', wrapText: true, hideDefaultActions: true }
    //{ type: 'button-icon', typeAttributes: { iconName: 'utility:refresh', name: 'refresh' } }
];
export default class CreateTopUpOpportunity extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isInsert = false;
    @track currentlySelectedRows = [];
    @track selectedRows = [];
    sortBy;
    opportunityDetails;
    currencyIsoCode;
    alreadyTopUpAmount;
    topUpValueFormatted;
    totalTopUpValue;
    oppSolutionsAvailableToTopUp;
    oppSolutionsAvailableToTopUpOnOriginal;
    isTopUpModal = false;
    showOppLines = true;
    showSpinner = true;
    isSaveDisabled = true;

    sortDirection = 'desc';
    TopUp_Warning; //= TopUp_Warning;
    wiredData;
    @track columns = [];


    // Prefer platform-provided recordId via @api. Fallback to URL only if not set (e.g., AppPage navigation).
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (!this.recordId && currentPageReference && currentPageReference.state) {
            // Quick Actions and Record Pages provide recordId automatically; AppPage/Tab may not.
            this.recordId = currentPageReference.state.recordId || currentPageReference.attributes?.recordId;
        }
    }

    connectedCallback() {
        loadStyle(this, modalPopupCss);
        this.isLoading = true;
        this.openTopUpModal();
    }

    // computed to keep wire param stable
    get isUpdateFlag() {
        return !this.isInsert;
    }

    handleStartTopUp() {
        this.showSpinner = true;
        let detailsToSend = JSON.parse(JSON.stringify(this.opportunityDetails));
        detailsToSend.solutionList = JSON.parse(JSON.stringify(this.currentlySelectedRows));

        // Sanitize payload to match Apex TopUpInformationWrapper numeric expectations
        detailsToSend = this.sanitizePayload(detailsToSend);

        console.log('currently selected rows ', JSON.stringify(this.currentlySelectedRows));
        console.log('oppSolutionsAvailableToTopUp ', JSON.stringify(this.oppSolutionsAvailableToTopUp));
        console.log('selected rows ', JSON.stringify(this.selectedRows));
        console.log('isInsert  ', JSON.stringify(this.isInsert));
        if (!this.isInsert) {
            this.updateTopUpLines(detailsToSend);
        } else {
            this.createTopUp(detailsToSend);
        }
    }

    createTopUp(detailsToSend) {
        // Ensure sanitized before sending (defensive in case caller omits sanitize)
        //detailsToSend = this.sanitizePayload(JSON.parse(JSON.stringify(detailsToSend)));
        console.log('detailsToSend  ', JSON.stringify(detailsToSend));
        createTopUpOpportunity({ opportunityDetails: detailsToSend, opportunityId: this.recordId }).then(response => {
            debugger;
            if (response.MessageType == 'Success') {
                debugger;

                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Top-Up Opportunity created successfully',
                    variant: 'success'
                });
                this.dispatchEvent(event);

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: response.opportunityId,
                        actionName: 'view'
                    }
                });
                this.closeTopUpModal();
            } else {
                debugger;
                console.log('error createTopUpOpportunity: ', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: response.Message,
                        variant: 'error',
                    }),
                );
            }
        }).catch(error => {
            debugger;

            console.log('error createTopUpOpportunity: ', JSON.stringify(error));
            this.showSpinner = false;
            let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error',
                }),
            );
        }).finally(() => {
            if (this.isInsert) {
                this.sendEventToParent();
            }
            this.showSpinner = false;
        });
    }

    updateTopUpLines(detailsToSend) {
        // Ensure sanitized before sending (defensive in case caller omits sanitize)
        //detailsToSend = this.sanitizePayload(JSON.parse(JSON.stringify(detailsToSend)));
        updateTopUpOpportunityLines({ opportunityDetails: detailsToSend, opportunityId: this.recordId }).then(response => {
            debugger;
            if (response.MessageType == 'Success') {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Top-Up Opportunity updated successfully',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.closeTopUpModal();
            } else {
                console.log('error updateTopUpOpportunityLines: ', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: response.Message,
                        variant: 'error',
                    }),
                );
            }
        }).catch(error => {
            console.log('error updateTopUpOpportunityLines: ', error);
            this.showSpinner = false;
            let message = 'Unknown Error Occurred. Please refresh or contact System Administrator';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error',
                }),
            );
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    // Convert formatted strings to raw numbers and strip UI-only fields before sending to Apex
    sanitizePayload(details) {
        const toNumber = (val) => {
            if (val === null || val === undefined) return null;
            if (typeof val === 'number') return val;
            if (typeof val === 'string') {
                // remove grouping separators like "," and spaces
                const cleaned = val.replace(/,/g, '').trim();
                const n = Number(cleaned);
                return isNaN(n) ? null : n;
            }
            return null;
        };

        // Coerce top-level decimal fields if present
        if (details) {
            if ('totalSalesPrice' in details) details.totalSalesPrice = toNumber(details.totalSalesPrice);
            if ('totalSalesPriceOriginalOpp' in details) details.totalSalesPriceOriginalOpp = toNumber(details.totalSalesPriceOriginalOpp);
            if ('alreadyTopUpAmount' in details) details.alreadyTopUpAmount = toNumber(details.alreadyTopUpAmount);
        }

        if (details && Array.isArray(details.solutionList)) {
            details.solutionList = details.solutionList.map(sol => {
                const s = { ...sol };

                // Expected numeric fields
                s.solutionCap = toNumber(s.solutionCap);
                s.solutionCapOnOriginal = toNumber(s.solutionCapOnOriginal);
                s.solutionTotalValue = toNumber(s.solutionTotalValue);
                s.solutionTotalValueOnOriginal = toNumber(s.solutionTotalValueOnOriginal);

                // Remove purely UI fields that Apex doesn't need to deserialize
                delete s.isDisabled; // Boolean is acceptable, but not needed server-side
                // Keep identifiers/labels used by server logic
                // s.solutionId, s.solutionName, s.rowNum, etc. are fine

                if (Array.isArray(s.oppLines)) {
                    s.oppLines = s.oppLines.map(line => {
                        const l = { ...line };
                        l.oppProductTotalValue = toNumber(l.oppProductTotalValue);
                        l.oppProductQuantity = toNumber(l.oppProductQuantity);
                        l.oppProductSalesPrice = toNumber(l.oppProductSalesPrice);
                        l.oppProductTotalPrice = toNumber(l.oppProductTotalPrice);
                        l.oppProductTotalEquivalentUnits = toNumber(l.oppProductTotalEquivalentUnits);
                        l.oppProductSolutionCap = toNumber(l.oppProductSolutionCap);
                        return l;
                    });
                }

                return s;
            });
        }

        return details;
    }

    handleRowAction(event) {
        debugger;
        if (event.detail.action.name === 'refresh') {
            let row = event.detail.row;
            let tempOppLines = JSON.parse(JSON.stringify(this.oppSolutionsAvailableToTopUp));
            let index = tempOppLines.findIndex(x => x.solutionId === row.solutionId);
            tempOppLines[index].solutionCap = 0;
            tempOppLines[index].solutionTotalValue = 0;

            let indexOfSelected = this.currentlySelectedRows.findIndex(x => x.solutionId === row.solutionId);
            if (indexOfSelected != -1) {
                this.currentlySelectedRows[indexOfSelected].solutionCap = 0;
                this.currentlySelectedRows[indexOfSelected].solutionTotalValue = 0;
            }
            this.oppSolutionsAvailableToTopUp = tempOppLines;
        }
    }

    handleRowSelection(event) {
        debugger;
        let tempOppLines = JSON.parse(JSON.stringify(this.oppSolutionsAvailableToTopUp));
        switch (event.detail.config.action) {
            case 'selectAllRows':
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.currentlySelectedRows.push(event.detail.selectedRows[i]);
                    tempOppLines[i].isDisabled = false;
                    this.selectedRows.push(event.detail.selectedRows[i]);
                }
                break;
            case 'deselectAllRows':
                tempOppLines.forEach(element => {
                    element.isDisabled = true;
                });
                this.currentlySelectedRows = [];
                this.selectedRows = [];
                this.isSaveDisabled = true;
                break;
            case 'rowSelect':
                let indexForSelected = event.detail.selectedRows.findIndex(x => x.rowNum === event.detail.config.value);
                let indexForEnable = tempOppLines.findIndex(x => x.rowNum === event.detail.config.value);
                tempOppLines[indexForEnable].isDisabled = false;
                this.currentlySelectedRows.push(event.detail.selectedRows[indexForSelected]);
                this.selectedRows.push(event.detail.config.value);
                break;
            case 'rowDeselect':
                let indexForDeselected = this.currentlySelectedRows.findIndex(x => x.rowNum === event.detail.config.value);
                if (indexForDeselected !== -1) {
                    this.currentlySelectedRows.splice(indexForDeselected, 1);
                } if (this.currentlySelectedRows.length === 0) {
                    this.isSaveDisabled = true;
                    this.currentlySelectedRows = [];
                    this.selectedRows = [];
                }
                let indexForDisable = tempOppLines.findIndex(x => x.rowNum === event.detail.config.value);
                tempOppLines[indexForDisable].isDisabled = true;
                break;
            default:
                break;
        }

        this.oppSolutionsAvailableToTopUp = tempOppLines;

        let updatedTotal = 0;
        let isNegativePresent = false;
        let isInvalidSelected = false;
        let showDecimalWarningSolutionCap = false;
        debugger;
        if (this.currentlySelectedRows.length != 0) {
            this.currentlySelectedRows.forEach(element => {
                if (element.solutionCap < 0) {
                    isNegativePresent = true;
                } else if (element.solutionCap == 0 || element.solutionCap == '' || element.solutionCap == null) {
                    isInvalidSelected = true;
                    //} else if ((typeof element.solutionCap === 'string' && (element.solutionCap.includes('.') || element.solutionCap.includes(','))) || (typeof element.solutionCap === 'number' && !Number.isInteger(element.solutionCap))) {
                } else if (this.isNotInteger(element.solutionCap)) {
                    showDecimalWarningSolutionCap = true;
                }
            });
            // only calculate total if everything is valid
            //if (!isNegativePresent && !isInvalidSelected && !showDecimalWarningSolutionCap) {
            //updatedTotal = this.currentlySelectedRows.reduce((n, { solutionTotalValue }) => n + Number(solutionTotalValue), 0);
            //}
            //updatedTotal = this.currentlySelectedRows.filter(r => { const v = Number(r.solutionTotalValue); return (v > 0 && Number.isInteger(v)) }).reduce((n, { solutionTotalValue }) => n + Number(solutionTotalValue), 0);
            //updatedTotal = this.currentlySelectedRows.filter(r => { const v = Number(r.solutionTotalValue); return (v > 0 && (Number.isInteger(v) && typeof v === 'number') || (typeof v === 'string' && v.includes('.'))) }).reduce((n, { solutionTotalValue }) => n + Number(solutionTotalValue), 0);
            updatedTotal = this.currentlySelectedRows.filter(r => { const v = Number(r.solutionTotalValue); return (v > 0 && !this.isNotInteger(v)) }).reduce((n, { solutionTotalValue }) => n + Number(solutionTotalValue), 0);
            this.totalTopUpValue = Number(updatedTotal).toFixed(2);
            this.topUpValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));
            console.log('showDecimalWarningSolutionCap: ', showDecimalWarningSolutionCap);
            console.log('isInvalidSelected: ', isInvalidSelected);
            console.log('isNegativePresent: ', isNegativePresent);
            if (isNegativePresent || isInvalidSelected || showDecimalWarningSolutionCap) {
                this.isSaveDisabled = true;
            } else if (this.currentlySelectedRows.length === 0) {
                this.isSaveDisabled = true;
            } else {
                this.isSaveDisabled = false;
            }
            /*if (isNegativePresent) {
                this.handleNegativeToast();
            } else if (showDecimalWarningSolutionCap) {
                this.handleDecimalWarning();
            }*/
        }

    }

    isNotInteger(n) {
        return (n != '' && !(/^[0-9]\d*$/.test(n)));
    }

    handleUpdateValue(event) {
        debugger;
        let isNegativePresent = false;
        let isInvalidSelected = false;
        let showDecimalWarningSolutionCap = false;
        let updatedTotal = 0;
        let changes = event.detail;
        console.log('recordId: ', changes.recordId);
        let tempOppLines = JSON.parse(JSON.stringify(this.oppSolutionsAvailableToTopUp));
        let index = tempOppLines.findIndex(x => x.solutionId === changes.recordId);
        if (index != -1) {
            if (changes.type == 'solutionCapTopUp') {
                console.log('changes.currentValue: ', changes.currentValue);
                console.log('typeof changes.currentValue : ', typeof changes.currentValue);
                console.log('isNotInteger: ', this.isNotInteger(changes.currentValue));
                tempOppLines[index].solutionCap = changes.currentValue;
                tempOppLines[index].solutionTotalValue = 0;
                //if ((typeof changes.currentValue === 'string' && (changes.currentValue.includes('.') || changes.currentValue.includes(','))) || (typeof changes.currentValue === 'number' && !Number.isInteger(changes.currentValue))) {
                if (this.isNotInteger(changes.currentValue)) {
                    showDecimalWarningSolutionCap = true;
                } else if (changes.currentValue < 0) {
                    isNegativePresent = true;
                } else if (changes.currentValue == 0 || changes.currentValue == '' || changes.currentValue == null) {
                    isInvalidSelected = true;
                } else {
                    let currentSolutionTotalValue = tempOppLines[index].solutionTotalValueOnOriginal;
                    tempOppLines[index].solutionTotalValue = (currentSolutionTotalValue / tempOppLines[index].solutionCapOnOriginal) * changes.currentValue;
                }
                if (isNegativePresent) {
                    this.handleWarning('Solution Cap cannot be negative');
                } else if (showDecimalWarningSolutionCap) {
                    this.handleWarning('Solution Cap should be a whole number');
                } else if (isInvalidSelected) {
                    this.handleWarning('Solution Cap cannot be  zero or blank');
                }
            }
        }
        this.oppSolutionsAvailableToTopUp = tempOppLines;
        let indexOfSelected = this.currentlySelectedRows.findIndex(x => x.solutionId === changes.recordId);
        if (indexOfSelected != -1) {
            if (changes.type == 'solutionCapTopUp') {
                this.currentlySelectedRows[indexOfSelected].solutionCap = changes.currentValue;
                this.currentlySelectedRows[indexOfSelected].solutionTotalValue = 0;
                //if ((typeof changes.currentValue === 'string' && (changes.currentValue.includes('.') || changes.currentValue.includes(','))) || (typeof changes.currentValue === 'number' && !Number.isInteger(changes.currentValue))) {
                if (this.isNotInteger(changes.currentValue)) {
                    showDecimalWarningSolutionCap = true;
                } else if (changes.currentValue < 0) {
                    isNegativePresent = true;
                } else if (changes.currentValue == 0 || changes.currentValue === '' || changes.currentValue == null) {
                    isInvalidSelected = true;
                } else {
                    let currentSolutionTotalValue = tempOppLines[index].solutionTotalValueOnOriginal;
                    this.currentlySelectedRows[indexOfSelected].solutionTotalValue = (currentSolutionTotalValue / this.currentlySelectedRows[indexOfSelected].solutionCapOnOriginal) * changes.currentValue;
                }
            }
        }
        /*isNegativePresent = false;
        isInvalidSelected = false;
        showDecimalWarningSolutionCap = false;*/
        this.currentlySelectedRows.forEach(element => {
            //if ((typeof element.solutionCap === 'string' && (element.solutionCap.includes('.') || element.solutionCap.includes(','))) || (typeof element.solutionCap === 'number' && !Number.isInteger(element.solutionCap))) {
            if (this.isNotInteger(element.solutionCap)) {
                showDecimalWarningSolutionCap = true;
            } else if (element.solutionCap == 0 || element.solutionCap == '' || element.solutionCap == null) {
                isInvalidSelected = true;
            } else if (element.solutionCap < 0) {
                isNegativePresent = true;
            }
        });
        // only calculate total if everything is valid
        //if (!isNegativePresent && !isInvalidSelected && !showDecimalWarningSolutionCap) {
        //updatedTotal = this.currentlySelectedRows.filter(r => { const v = Number(r.solutionTotalValue); return (v > 0 && ((Number.isInteger(v) && typeof v === 'number') || (typeof v === 'string' && v.includes('.')))) }).reduce((n, { solutionTotalValue }) => n + Number(solutionTotalValue), 0);
        updatedTotal = this.currentlySelectedRows
            .filter(r => {
                const v = Number(r.solutionTotalValue); return (v > 0 && !this.isNotInteger(v))
            })
            .reduce((n, { solutionTotalValue }) => n + Number(solutionTotalValue), 0);

        console.log('updatedTotal: ', updatedTotal);
        this.totalTopUpValue = Number(updatedTotal).toFixed(2);
        console.log('this.totalTopUpValue: ', this.totalTopUpValue);
        this.topUpValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));
        console.log('this.topUpValueFormatted: ', this.topUpValueFormatted);
        if (isNegativePresent || isInvalidSelected || showDecimalWarningSolutionCap) {
            this.isSaveDisabled = true;
        } else if (this.currentlySelectedRows.length === 0) {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    handleWarning(message) {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: message,
            variant: 'warning'
        });
        this.dispatchEvent(event);
    }

    @wire(getOpportunityLine, { opportunityId: '$recordId', isUpdate: '$isUpdateFlag' })
    handleGetAvailableOppLines(value) {
        console.log('recordId: ', this.recordId);
        console.log('this.isInsert: ', this.isInsert);
        //getOpportunityLine({ opportunityId: this.recordId, isUpdate: !this.isInsert }).then(response => {
        this.wiredData = value;
        const { error, data } = value;
        if (data) {
            this.columns = this.isInsert === true ? columnsInsert : columnsUpdate;
            this.isLoading = true;
            this.showSpinner = true;
            debugger;
            this.isLoading = false;
            this.showSpinner = false;
            const response = data;
            this.opportunityDetails = response;
            this.currencyIsoCode = response.currencyIsoCode;
            this.oppSolutionsAvailableToTopUpOnOriginal = JSON.parse(JSON.stringify(response.solutionList));
            this.oppSolutionsAvailableToTopUp = JSON.parse(JSON.stringify(response.solutionList));
            this.showOppLines = this.oppSolutionsAvailableToTopUp.length > 0 ? true : false;
            this.currentlySelectedRows = [];
            if (!this.isInsert) {
                //this.currentlySelectedRows = JSON.parse(JSON.stringify(response.solutionList));
            } else {
                this.currentlySelectedRows = [];
            }
            //setTimeout(() => {
            if (this.isInsert) {
                this.sendEventToParent();
            }
            //}, 2000);
        } else if (error) {
            console.log('error getOpportunityLine: ', error);
            this.isLoading = false;
            if (this.isInsert) {
                this.sendEventToParent();
            }
            const event = new ShowToastEvent({
                title: 'Error',
                message: (error && (error.body?.message || JSON.stringify(error.body) || JSON.stringify(error))) || 'Unknown error',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.oppSolutionsAvailableToTopUp));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'desc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.oppSolutionsAvailableToTopUp = parseData;
    }

    handleReset() {
        this.currentlySelectedRows = [];
        let tempLines = JSON.parse(JSON.stringify(this.oppSolutionsAvailableToTopUpOnOriginal));
        this.oppSolutionsAvailableToTopUp = tempLines;
        this.isSaveDisabled = true;
    }

    openTopUpModal() {
        //this.handleGetAvailableOppLines();
        this.isTopUpModal = true;
    }

    closeTopUpModal() {
        this.isTopUpModal = false;
        if (this.isInsert) {
            this.sendEventToParent();
        } else {
            // Closes the quick action modal
            this.dispatchEvent(new CloseActionScreenEvent());
            refreshApex(this.wiredData);
            /*this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                }
            });*/
        }/*else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                    objectApiName: 'Opportunity', // API Name of Parent
                    relationshipApiName: 'OpportunityLineItems' // Relationship Name
                }
            });
        }*/
    }

    sendEventToParent() {
        const value = this.isTopUpModal;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value },
            composed: true,
            bubbles: true,
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }
}