import { LightningElement,api,track } from 'lwc';
import getOpportunityLine from '@salesforce/apex/DebookingOpportunityController.getOpportunityLine';
import createDebookingOpportunity from '@salesforce/apex/DebookingOpportunityController.createDebookingOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Debooking_Warning from '@salesforce/label/c.Debooking_Warning'

export default class DebookingOpportunityComponent extends NavigationMixin(LightningElement) {

    @api recordId;
    opportunityDetails;
    isDebookingModal = false;
    isOppLinesAvailable = false;
    oppLinesAvailableToDebookOriginal;
    oppLinesAvailableToDebook;
    selectedRows;
    totalSalesPrice;
    inflationAmount;
    inflationAmountPercentage;
    currencyIsoCode;
    alreadyDebookedAmount;
    alreadyDebookedAmountPercentage;
    totalDebookedValue =0;
    debookedValueFormatted = 0;
    @track currentlySelectedRows = [];
    @track selectedRows =[];
    isSaveDisabled = true;
    isNegativePresent = false;
    showSpinner = true;
    showWarning = false;
    showDecimalWarning = false;
    showWarningSalesPrice = false;
    showWarningTotalPrice = false; // SSE-27840 changes
    showDecimalWarningTotalPrice = false; // SSE-27840 changes
    showWarningSolutionCap = false; // SSE-27840 changes
    showDecimalWarningSolutionCap = false; // SSE-27840 changes
    showDecimalWarningSalesPrice = false; 
    alreadyDebookedAmountIcon = true;
    error;
    showOppLines = true;
    selectedOption = ''
    isQuantityOrSalesPriceChecked = true;
    isPercentageChecked = false;
    isPercentageDisabled = true;
    percentageValue;
    sortBy;
    sortDirection = 'desc';
    Debooking_Warning = Debooking_Warning;


    columns = [
        { label: 'Product', fieldName: 'oppProductName',fixedWidth:120,wrapText:true,hideDefaultActions:true },
        { label: 'Opportunity', fieldName: 'oppNumber',fixedWidth:100,wrapText:true,hideDefaultActions:true},
        { label: 'Variation?', fieldName: 'isVariationOpp',sortable:true,fixedWidth:100,wrapText:true,hideDefaultActions:true},
        { label: 'Basis of Fees', fieldName: 'oppProductBasisOfFees',fixedWidth:100,wrapText:true,hideDefaultActions:true},
        { label: 'Offering Details', fieldName: 'oppProductOfferingDetails',fixedWidth:120,wrapText:true,hideDefaultActions:true},
        { label: 'No. of Service Deliveries', fieldName: 'oppProductNumberOfService',fixedWidth:170,wrapText:true,hideDefaultActions:true},
        { label: 'Solution Cap', fieldName: 'oppProductId',fixedWidth:120,type:'customInput',wrapText:true,hideDefaultActions:true,typeAttributes:{type:'solutionCap',value :{fieldName:'oppProductSolutionCap'},recordId:{fieldName:'oppProductId'},isDisabled:{fieldName:'isDisabled'}}},
        { label: 'Quantity', fieldName: 'oppProductId',fixedWidth:85,type:'customInput',wrapText:true,hideDefaultActions:true,typeAttributes:{type:'quantity',value :{fieldName:'oppProductQuantity'},recordId:{fieldName:'oppProductId'},isDisabled:{fieldName:'isDisabled'}}},
        //{ label: 'Sales Price', fieldName: 'oppProductId',fixedWidth:160,type:'customInput',wrapText:true,hideDefaultActions:true,typeAttributes:{type:'salesPrice',value :{fieldName:'oppProductSalesPrice'},recordId:{fieldName:'oppProductId'},isDisabled:{fieldName:'isDisabled'}}},
        { label: 'Debook Value', fieldName: 'oppProductId',fixedWidth:150,type:'customInput',wrapText:true,hideDefaultActions:true,typeAttributes:{type:'debookValue',value :{fieldName:'oppProductTotalPrice'},recordId:{fieldName:'oppProductId'},isDisabled:{fieldName:'isDisabled'}}},
        //{ label: 'Total Price', fieldName: 'oppProductTotalPrice',wrapText:true,hideDefaultActions:true},
        { label: 'Impact %',initalWidth:100 ,fieldName: 'percentageImpact',wrapText:true,hideDefaultActions:true},
        { type:'button-icon',typeAttributes:{iconName:'utility:refresh',name:'refresh'}}
    ];

    handleChange(event){
        this.selectedOption = event.currentTarget.name;
        if(this.selectedOption == 'Percentage'){
            this.isQuantityOrSalesPriceChecked = false;
            this.isPercentageChecked = true;
            this.isPercentageDisabled = false;
        }else{
            this.isQuantityOrSalesPriceChecked = true;
            this.isPercentageChecked = false;
            this.isPercentageDisabled = true;
            this.percentageValue = null;
        }
        this.handleReset();
    }

    handlePercentageChange(event){
        this.percentageValue = event.currentTarget.value;
        console.log(this.percentageValue);
        let percentageToUse = this.percentageValue;
        if(this.percentageValue>100 || this.percentageValue<=0){
            this.percentageValue = null;
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Please enter a valid percentage',
                variant:'warning'
            });
            this.dispatchEvent(event);
            percentageToUse = 100;
        }
            let tempOppLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
            tempOppLines.forEach(element => {
                element.oppProductSalesPrice = (element.oppProductSalesPriceMax * percentageToUse)/100;
                element.oppProductTotalPrice = Number(element.oppProductSalesPrice * element.oppProductQuantity).toFixed(2);
            });
            this.oppLinesAvailableToDebook = tempOppLines;
            this.currentlySelectedRows.forEach(element => {
                element.oppProductSalesPrice = (element.oppProductSalesPriceMax * percentageToUse)/100;
                element.oppProductTotalPrice = Number(element.oppProductSalesPrice * element.oppProductQuantity).toFixed(2);
            });
            let updatedTotal = this.currentlySelectedRows.reduce((n, {oppProductTotalPrice}) => n + Number(oppProductTotalPrice), 0);
            this.totalDebookedValue = Number(updatedTotal).toFixed(2);
            this.debookedValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));

    }

    handleRowAction(event) {
        if (event.detail.action.name === 'refresh') {
            console.log(event.detail.row);
            let row = event.detail.row ;
            let tempOppLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
            let index = tempOppLines.findIndex(x => x.oppProductId === row.oppProductId );
            tempOppLines[index].oppProductQuantity = row.oppProductQuantityMax;
            //tempOppLines[index].oppProductSalesPrice = row.oppProductSalesPriceMax;
            tempOppLines[index].oppProductTotalPrice = row.oppProductTotalPriceMax;
            tempOppLines[index].percentageImpact = '';
            
            let indexOfSelected = this.currentlySelectedRows.findIndex(x => x.oppProductId === row.oppProductId );
            if(indexOfSelected!=-1){
                tempOppLines[index].percentageImpact = '100 %';
                this.currentlySelectedRows[indexOfSelected].oppProductQuantity = row.oppProductQuantityMax;
                //this.currentlySelectedRows[indexOfSelected].oppProductSalesPrice = row.oppProductSalesPriceMax;
                this.currentlySelectedRows[indexOfSelected].oppProductTotalPrice = row.oppProductTotalPriceMax;
                this.currentlySelectedRows[indexOfSelected].percentageImpact = '100 %';
                let updatedTotal = this.currentlySelectedRows.reduce((n, {oppProductTotalPrice}) => n + Number(oppProductTotalPrice), 0);
                this.totalDebookedValue = Number(updatedTotal).toFixed(2);
                this.debookedValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));

            }
            this.oppLinesAvailableToDebook = tempOppLines;
        }
    }

    handleReset(){
        this.currentlySelectedRows = [];
        let tempLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebookOriginal));
        this.oppLinesAvailableToDebook = tempLines;
        this.totalDebookedValue = 0;
        this.isSaveDisabled = true;
        this.percentageValue = null;
    }

    handleSort(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'desc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.oppLinesAvailableToDebook = parseData;
    }    

    // handleUpdateValue(event){
    //     let changes = event.detail;
        
    //     let updatedTotal = 0;
    //     let tempOppLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
    //     let index = tempOppLines.findIndex(x => x.oppProductId === changes.recordId );
    //     if(index!=-1){
    //         if(changes.type=='quantity'){
    //             if(changes.currentValue> tempOppLines[index].oppProductQuantityMax){
    //                 this.showWarning = true;
    //                 tempOppLines[index].isInvalid = true;
    //             }else if(changes.currentValue.includes('.') && changes.currentValue.toString().split('.')[1].length>2){
    //                 this.showDecimalWarning = true;
    //                 tempOppLines[index].isInvalid = true;
    //             }else{
    //                 this.showWarning = false;
    //                 this.showDecimalWarning = false;
    //                 tempOppLines[index].isInvalid = false;
    //             }
    //             tempOppLines[index].oppProductQuantity = changes.currentValue;
    //             tempOppLines[index].oppProductTotalPrice = Number(changes.currentValue * Number(tempOppLines[index].oppProductSalesPrice)).toFixed(2);
                
    //         }    
    //         else if(changes.type=='salesPrice'){
    //             if(changes.currentValue> tempOppLines[index].oppProductSalesPriceMax){
    //                 this.showWarningSalesPrice = true;
    //                 tempOppLines[index].isInvalidSalesPrice = true;
    //             }else if(changes.currentValue.includes('.') && changes.currentValue.toString().split('.')[1].length>8){
    //                 this.showDecimalWarningSalesPrice = true;
    //                 tempOppLines[index].isInvalidSalesPrice = true;
    //             }else{
    //                 this.showWarningSalesPrice = false;
    //                 this.showDecimalWarningSalesPrice = false;
    //                 tempOppLines[index].isInvalidSalesPrice = false;
    //             }
    //             tempOppLines[index].oppProductSalesPrice = changes.currentValue;
    //             tempOppLines[index].oppProductTotalPrice = Number(changes.currentValue * Number(tempOppLines[index].oppProductQuantity)).toFixed(2);
                
    //         }        
    //     }
    //         this.oppLinesAvailableToDebook = tempOppLines;
    //     let indexOfSelected = this.currentlySelectedRows.findIndex(x => x.oppProductId === changes.recordId );
    //     if(indexOfSelected!=-1){
    //         if(changes.type=='quantity'){
    //             if(changes.currentValue> this.currentlySelectedRows[indexOfSelected].oppProductQuantityMax){
    //                 this.showWarning = true;
    //                 this.currentlySelectedRows[indexOfSelected].isInvalid = true;
    //             }else if(changes.currentValue.toString().includes('.') && changes.currentValue.toString().split('.')[1].length>2){
    //                 this.showDecimalWarning = true;
    //                 this.currentlySelectedRows[indexOfSelected].isInvalid = true;
    //             }else{
    //                 this.showWarning = false;
    //                 this.showDecimalWarning = false;
    //                 this.currentlySelectedRows[indexOfSelected].isInvalid = false;
    //             }
    //             this.currentlySelectedRows[indexOfSelected].oppProductQuantity = changes.currentValue;
    //             this.currentlySelectedRows[indexOfSelected].oppProductTotalPrice = Number(changes.currentValue * Number(this.currentlySelectedRows[indexOfSelected].oppProductSalesPrice)).toFixed(2);
                
    //         }    
    //         else if(changes.type=='salesPrice'){
    //             if(changes.currentValue> this.currentlySelectedRows[indexOfSelected].oppProductSalesPriceMax){
    //                 this.showWarningSalesPrice = true;
    //                 this.currentlySelectedRows[indexOfSelected].isInvalidSalesPrice = true;
    //             }else if(changes.currentValue.includes('.') && changes.currentValue.toString().split('.')[1].length>8){
    //                 this.showDecimalWarningSalesPrice = true;
    //                 this.currentlySelectedRows[indexOfSelected].isInvalidSalesPrice = true;
    //             }else{
    //                 this.showWarningSalesPrice = false;
    //                 this.showDecimalWarningSalesPrice = false;
    //                 this.currentlySelectedRows[indexOfSelected].isInvalidSalesPrice = false;
    //             }
    //             this.currentlySelectedRows[indexOfSelected].oppProductSalesPrice = changes.currentValue;
    //             this.currentlySelectedRows[indexOfSelected].oppProductTotalPrice = Number(changes.currentValue * Number(this.currentlySelectedRows[indexOfSelected].oppProductQuantity)).toFixed(2);
    //         }        
    //     }
    //     updatedTotal = this.currentlySelectedRows.reduce((n, {oppProductTotalPrice}) => n + Number(oppProductTotalPrice), 0);
    //     let isNegativePresent = false;
    //     this.currentlySelectedRows.forEach(element => {
    //         if(element.oppProductQuantity<=0 || element.oppProductSalesPrice<0){
    //             isNegativePresent = true;
    //         }
    //     });
    //     this.totalDebookedValue = Number(updatedTotal).toFixed(2);
    //     this.debookedValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));
    //     if(this.totalDebookedValue>0 && !isNegativePresent && !this.showWarning && !this.showDecimalWarning && !this.showWarningSalesPrice && !this.showDecimalWarningSalesPrice){
    //         this.isSaveDisabled = false;
    //         this.alreadyDebookedAmountIcon = false;
    //         setTimeout(() => {
    //             this.alreadyDebookedAmountIcon = true;
    //         }, 0);
    //     }else{
    //         this.isSaveDisabled = true;
    //         if(isNegativePresent){
    //             this.handleNegativeToast();
    //         }else if(this.showWarning || this.showWarningSalesPrice){
    //             this.handleIncrementToast();
    //         }else if(this.showDecimalWarning || this.showDecimalWarningSalesPrice){
    //             this.handleDecimalWarning(changes.type);
    //         }
    //     }
        
    // }

    // handleRowSelection(event){
    //     let tempOppLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
    //     switch (event.detail.config.action) {
    //         case 'selectAllRows':
    //             for (let i = 0; i < event.detail.selectedRows.length; i++) {
    //                 this.currentlySelectedRows.push(event.detail.selectedRows[i]);
    //                 if(this.selectedOption!='Percentage'){
    //                     tempOppLines[i].isDisabled = false;
    //                 }
    //                 this.selectedRows.push(event.detail.selectedRows[i]);
                
    //             }
    //             break;
    //         case 'deselectAllRows':
    //             tempOppLines.forEach(element => {
    //                 element.isDisabled = true;
    //             });
    //             this.currentlySelectedRows = [];
    //             this.selectedRows = [];
    //             break;
    //         case 'rowSelect':
    //             let indexForSelected = event.detail.selectedRows.findIndex(x => x.rowNum === event.detail.config.value );
    //             let indexForEnable = tempOppLines.findIndex(x => x.rowNum === event.detail.config.value); 
    //             if(this.selectedOption!='Percentage'){
    //                 tempOppLines[indexForEnable].isDisabled = false;
    //             }
    //             this.currentlySelectedRows.push(event.detail.selectedRows[indexForSelected]);
    //             this.selectedRows.push(event.detail.config.value);
    //             break;
    //         case 'rowDeselect':
    //             let indexForDeselected = this.currentlySelectedRows.findIndex(x => x.rowNum === event.detail.config.value );
    //             if (indexForDeselected !== -1) {
    //                 this.currentlySelectedRows.splice(indexForDeselected, 1);
    //             }
    //             let indexForDisable = tempOppLines.findIndex(x => x.rowNum === event.detail.config.value); 
    //             tempOppLines[indexForDisable].isDisabled = true;
    //             break;
    //         default:
    //             break;
    //     }
    //     this.oppLinesAvailableToDebook = tempOppLines;
    //     let updatedTotal = this.currentlySelectedRows.reduce((n, {oppProductTotalPrice}) => n + Number(oppProductTotalPrice), 0);
    //     let isNegativePresent = false;
    //     let isInvalidSelected = false;
    //     this.currentlySelectedRows.forEach(element => {
    //         if(element.oppProductQuantity<=0 || element.oppProductSalesPrice<0){
    //             isNegativePresent = true;
    //         }
    //         if(element.isInvalid || element.isInvalidSalesPrice){
    //             isInvalidSelected = true;
    //         }
    //     });
    //     this.totalDebookedValue = Number(updatedTotal).toFixed(2);
    //     this.debookedValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));
    //     if(this.totalDebookedValue>0 && (!isInvalidSelected || (!isNegativePresent && !this.showWarning && !this.showDecimalWarning && !this.showWarningSalesPrice && !this.showDecimalWarningSalesPrice))){
    //         this.isSaveDisabled = false;
    //         this.alreadyDebookedAmountIcon = false;
    //         setTimeout(() => {
    //             this.alreadyDebookedAmountIcon = true;
    //         }, 0);
    //     }else{
    //         this.isSaveDisabled = true;
    //         if(isNegativePresent){
    //             this.handleNegativeToast();
    //         }else if(this.showWarning || this.showWarningSalesPrice){
    //             this.handleIncrementToast();
    //         }else if(this.showDecimalWarning || this.showDecimalWarningSalesPrice){
    //             this.handleDecimalWarning();
    //         }
    //     }
        
    // }

    // SSE-27840 changes
    handleUpdateValue(event){
        let changes = event.detail;
        
        let updatedTotal = 0;
        let tempOppLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
        let index = tempOppLines.findIndex(x => x.oppProductId === changes.recordId );
        if(index!=-1){
            if(changes.type=='quantity'){
                if(changes.currentValue> tempOppLines[index].oppProductQuantityMax){
                    this.showWarning = true;
                    tempOppLines[index].isInvalid = true;
                }else if(changes.currentValue.includes('.') && changes.currentValue.toString().split('.')[1].length>2){
                    this.showDecimalWarning = true;
                    tempOppLines[index].isInvalid = true;
                }else{
                    this.showWarning = false;
                    this.showDecimalWarning = false;
                    tempOppLines[index].isInvalid = false;
                }
                tempOppLines[index].oppProductQuantity = changes.currentValue;                
            }    
            else if(changes.type=='debookValue'){
                if(changes.currentValue> tempOppLines[index].oppProductTotalPriceMax){
                    this.showWarningTotalPrice = true;
                    tempOppLines[index].isInvalidTotalPrice = true;
                }else if(changes.currentValue.includes('.') && changes.currentValue.toString().split('.')[1].length>2){
                    this.showDecimalWarningTotalPrice = true;
                    tempOppLines[index].isInvalidTotalPrice = true;
                }else{
                    this.showWarningTotalPrice = false;
                    this.showDecimalWarningTotalPrice = false;
                    tempOppLines[index].isInvalidTotalPrice = false;
                }
                tempOppLines[index].oppProductTotalPrice = changes.currentValue;      
                let percentageImpact = ((tempOppLines[index].oppProductTotalPrice/tempOppLines[index].oppProductTotalPriceMax)*100).toFixed(2);          
                tempOppLines[index].percentageImpact = percentageImpact + ' %';
            }  
            else if(changes.type=='solutionCap'){
                if(changes.currentValue> tempOppLines[index].oppProductSolutionCapMax){
                    this.showWarningSolutionCap = true;
                    tempOppLines[index].isInvalidSolutionCap = true;
                }else if(changes.currentValue.includes('.')){
                    this.showDecimalWarningSolutionCap = true;
                    tempOppLines[index].isInvalidSolutionCap = true;
                }else{
                    this.showWarningSolutionCap = false;
                    this.showDecimalWarningSolutionCap = false;
                    tempOppLines[index].isInvalidSolutionCap = false;
                }
                tempOppLines[index].oppProductSolutionCap = changes.currentValue;                
            }       
        }
            this.oppLinesAvailableToDebook = tempOppLines;
        let indexOfSelected = this.currentlySelectedRows.findIndex(x => x.oppProductId === changes.recordId );
        if(indexOfSelected!=-1){
            if(changes.type=='quantity'){
                if(changes.currentValue> this.currentlySelectedRows[indexOfSelected].oppProductQuantityMax){
                    this.showWarning = true;
                    this.currentlySelectedRows[indexOfSelected].isInvalid = true;
                }else if(changes.currentValue.toString().includes('.') && changes.currentValue.toString().split('.')[1].length>2){
                    this.showDecimalWarning = true;
                    this.currentlySelectedRows[indexOfSelected].isInvalid = true;
                }else{
                    this.showWarning = false;
                    this.showDecimalWarning = false;
                    this.currentlySelectedRows[indexOfSelected].isInvalid = false;
                }
                this.currentlySelectedRows[indexOfSelected].oppProductQuantity = changes.currentValue;                
            }    
            else if(changes.type=='debookValue'){
                if(changes.currentValue> this.currentlySelectedRows[indexOfSelected].oppProductTotalPriceMax){
                    this.showWarningTotalPrice = true;
                    this.currentlySelectedRows[indexOfSelected].isInvalidTotalPrice = true;
                }else if(changes.currentValue.includes('.') && changes.currentValue.toString().split('.')[1].length>2){
                    this.showDecimalWarningTotalPrice = true;
                    this.currentlySelectedRows[indexOfSelected].isInvalidTotalPrice = true;
                }else{
                    this.showWarningTotalPrice = false;
                    this.showDecimalWarningTotalPrice = false;
                    this.currentlySelectedRows[indexOfSelected].isInvalidTotalPrice = false;
                }
                this.currentlySelectedRows[indexOfSelected].oppProductTotalPrice = changes.currentValue;
                let percentageImpact = ((this.currentlySelectedRows[indexOfSelected].oppProductTotalPrice/this.currentlySelectedRows[indexOfSelected].oppProductTotalPriceMax)*100).toFixed(2);          
                this.currentlySelectedRows[indexOfSelected].percentageImpact = percentageImpact + ' %';
            }  
            else if(changes.type=='solutionCap'){
                if(changes.currentValue> this.currentlySelectedRows[indexOfSelected].oppProductSolutionCapMax){
                    this.showWarningSolutionCap = true;
                    this.currentlySelectedRows[indexOfSelected].isInvalidSolutionCap = true;
                }else if(changes.currentValue.includes('.')){
                    this.showDecimalWarningSolutionCap = true;
                    this.currentlySelectedRows[indexOfSelected].isInvalidSolutionCap = true;
                }else{
                    this.showWarningSolutionCap = false;
                    this.showDecimalWarningSolutionCap = false;
                    this.currentlySelectedRows[indexOfSelected].isInvalidSolutionCap = false;
                }
                this.currentlySelectedRows[indexOfSelected].oppProductSolutionCap = changes.currentValue;                
            }       
        }
        updatedTotal = this.currentlySelectedRows.reduce((n, {oppProductTotalPrice}) => n + Number(oppProductTotalPrice), 0);
        let isNegativePresent = false;
        this.currentlySelectedRows.forEach(element => {
            if(element.oppProductQuantity <= 0 || element.oppProductTotalPrice<=0 || element.oppProductSolutionCap<0){
                isNegativePresent = true;
            }
        });
        this.totalDebookedValue = Number(updatedTotal).toFixed(2);
        this.debookedValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));
        if(this.totalDebookedValue>0 && !isNegativePresent && !this.showWarning && !this.showDecimalWarning && !this.showWarningTotalPrice && !this.showDecimalWarningTotalPrice && !this.showDecimalWarningSolutionCap && !this.showWarningSolutionCap){
            this.isSaveDisabled = false;
            this.alreadyDebookedAmountIcon = false;
            setTimeout(() => {
                this.alreadyDebookedAmountIcon = true;
            }, 0);
        }else{
            this.isSaveDisabled = true;
            if(isNegativePresent){
                this.handleNegativeToast();
            }else if(this.showWarning || this.showWarningTotalPrice || this.showWarningSolutionCap){
                this.handleIncrementToast();
            }else if(this.showDecimalWarning || this.showDecimalWarningTotalPrice || this.showDecimalWarningSolutionCap){
                this.handleDecimalWarning(changes.type);
            }
        }
        
    }

    // SSE-27840 changes
    handleRowSelection(event){
        let tempOppLines = JSON.parse(JSON.stringify(this.oppLinesAvailableToDebook));
        switch (event.detail.config.action) {
            case 'selectAllRows':
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.currentlySelectedRows.push(event.detail.selectedRows[i]);
                    if(this.selectedOption!='Percentage'){
                        tempOppLines[i].isDisabled = false;
                    }
                    tempOppLines[i].percentageImpact = '100 %';
                    this.selectedRows.push(event.detail.selectedRows[i]);
                
                }
                break;
            case 'deselectAllRows':
                tempOppLines.forEach(element => {
                    element.isDisabled = true;
                    element.percentageImpact = null;
                });
                this.currentlySelectedRows = [];
                this.selectedRows = [];
                break;
            case 'rowSelect':
                let indexForSelected = event.detail.selectedRows.findIndex(x => x.rowNum === event.detail.config.value );
                let indexForEnable = tempOppLines.findIndex(x => x.rowNum === event.detail.config.value); 
                if(this.selectedOption!='Percentage'){
                    tempOppLines[indexForEnable].isDisabled = false;
                }
                tempOppLines[indexForEnable].percentageImpact = '100 %';
                this.currentlySelectedRows.push(event.detail.selectedRows[indexForSelected]);
                this.selectedRows.push(event.detail.config.value);
                break;
            case 'rowDeselect':
                let indexForDeselected = this.currentlySelectedRows.findIndex(x => x.rowNum === event.detail.config.value );
                if (indexForDeselected !== -1) {
                    this.currentlySelectedRows.splice(indexForDeselected, 1);
                }
                let indexForDisable = tempOppLines.findIndex(x => x.rowNum === event.detail.config.value); 
                tempOppLines[indexForDisable].isDisabled = true;
                tempOppLines[indexForDisable].percentageImpact = null;
                break;
            default:
                break;
        }
        this.oppLinesAvailableToDebook = tempOppLines;
        let updatedTotal = this.currentlySelectedRows.reduce((n, {oppProductTotalPrice}) => n + Number(oppProductTotalPrice), 0);
        let isNegativePresent = false;
        let isInvalidSelected = false;
        this.currentlySelectedRows.forEach(element => {
            if(element.oppProductQuantity < 0 || element.oppProductTotalPrice < 0 || element.solutionCap < 0){
                isNegativePresent = true;
            }
            if(element.isInvalidQuantity || element.isInvalidTotalPrice || element.isInvalidSolutionCap){
                isInvalidSelected = true;
            }
        });
        this.totalDebookedValue = Number(updatedTotal).toFixed(2);
        this.debookedValueFormatted = new Intl.NumberFormat().format(Number(updatedTotal).toFixed(2));
        if(this.totalDebookedValue>0 && (!isInvalidSelected || (!isNegativePresent && !this.showWarning && !this.showDecimalWarning && !this.showWarningTotalPrice && !this.showDecimalWarningTotalPrice && !this.showDecimalWarningSolutionCap && !this.showWarningSolutionCap))){
            this.isSaveDisabled = false;
            this.alreadyDebookedAmountIcon = false;
            setTimeout(() => {
                this.alreadyDebookedAmountIcon = true;
            }, 0);
        }else{
            this.isSaveDisabled = true;
            if(isNegativePresent){
                this.handleNegativeToast();
            }else if(this.showWarning || this.showWarningTotalPrice || this.showWarningSolutionCap){
                this.handleIncrementToast();
            }else if(this.showDecimalWarning || this.showDecimalWarningTotalPrice || this.showDecimalWarningSolutionCap){
                this.handleDecimalWarning();
            }
        }
        
    }

    // SSE-27840 changes
    handleNegativeToast(){
        let message = 'Quantity, Debook Value or Solution Cap cannot be negative. Quantity and Debook Value should also be greater than 0';
        const event = new ShowToastEvent({
            title: 'Warning',
            message:message,
            //message: 'Quantity or Sales Price cannot be negative. Quantity should also be greater than 0',
            variant:'warning'
        });
        this.dispatchEvent(event);
    }

    // SSE-27840 changes
    handleIncrementToast(){
        let message = 'Quantity, Debook Value or Solution Cap cannot be more than the original value';
        const event = new ShowToastEvent({
            title: 'Warning',
            message: message,
            //message: 'Quantity or Sales Price cannot be more than the original value',
            variant:'warning'
        });
        this.dispatchEvent(event);
    }

    handleShowInvalidWarning(){
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Please enter a valid value',
            variant:'warning'
        });
        this.dispatchEvent(event);
    }

    // SSE-27840 changes
    handleDecimalWarning(type){
        let message = '';
        if(type === 'quantity'){
            message = 'Quantity cannot have more than 2 decimal places';
        }else if(type === 'salesPrice'){
            message = 'Sales Price cannot have more than 8 decimal places';
        }else if(type === 'solutionCap'){
            message = 'Solution Cap should be a whole number';
        }else{
            message = 'Allowed decimal places for Quantity and Debook Value is 2. Please review the values to continue';
        }
        const event = new ShowToastEvent({
            title: 'Warning',
            message: message,
            variant:'warning'
        });
        this.dispatchEvent(event);
    }

    handleGetAvailableOppLines(){
         
        getOpportunityLine({opportunityId : this.recordId}).then(response => {
            
            this.showSpinner = false;
            this.opportunityDetails = response;
            this.oppLinesAvailableToDebook = response.oppLines;
            this.oppLinesAvailableToDebookOriginal = JSON.parse(JSON.stringify(response.oppLines));
            this.showOppLines = this.oppLinesAvailableToDebookOriginal.length>0?true:false;
            this.totalSalesPrice = new Intl.NumberFormat().format(response.totalSalesPrice);
            this.alreadyDebookedAmount = new Intl.NumberFormat().format(response.alreadyDebookedAmount);
            //this.alreadyDebookedAmountPercentage = Number((this.alreadyDebookedAmount/this.totalSalesPrice)*100).toFixed(2);
            this.currencyIsoCode = response.currencyIsoCode;
            this.inflationAmount = new Intl.NumberFormat().format(response.inflationAmount);
            //this.inflationAmountPercentage = Number((this.inflationAmount/response.totalSalesPriceOriginalOpp)*100).toFixed(2);
            this.totalDebookedValue = 0;
            this.debookedValueFormatted = 0;
            this.percentageValue = null;
            this.currentlySelectedRows = [];
            this.showDecimalWarning = false;
            this.showWarning = false; 
        }).catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message:JSON.stringify(error),
                variant:'error'
            });
            this.dispatchEvent(event);
        });
    }

    handleStartDebookingProcess(){
        if(Number(this.totalSalesPrice) < (Number(this.totalDebookedValue) + Number(this.alreadyDebookedAmount))){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Overall debooked amount cannot exceed the original opportunity amount',
                variant:'error'
            });
            this.dispatchEvent(event);
        }else{
            this.showSpinner = true;

        let detailsToSend = JSON.parse(JSON.stringify(this.opportunityDetails));
        detailsToSend.oppLines = this.currentlySelectedRows;
        createDebookingOpportunity({opportunityDetails : detailsToSend,opportunityId : this.recordId}).then(response => {
            if(response.MessageType=='Success'){
            const event = new ShowToastEvent({
                title: 'Success',
                message:'Debooking Opportunity created successfully',
                variant:'success'
            });
            this.dispatchEvent(event);

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: response.opportunityId,
                    actionName: 'view'
                }
            });
              this.closeDebookingModal();
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: response.Message,
                        variant: 'error',
                    }),
                );
            }
        }).catch(error => {
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
    }

    openDebookingModal(){
        this.handleGetAvailableOppLines();
        this.isDebookingModal = true;
    }

    closeDebookingModal(){
        this.isDebookingModal = false;
    }


}