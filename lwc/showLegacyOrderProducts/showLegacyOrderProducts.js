import { api, LightningElement, wire } from 'lwc';
import callGetOrderProducts from '@salesforce/apex/OrderProductsInformation.GetOrderProducts';
import LOCALE from '@salesforce/i18n/locale';

export default class ShowLegacyOrderProducts extends LightningElement {
@api recordId;
OrderProducts;
errorMsg; 
@wire (callGetOrderProducts, {OrderId:'$recordId'})
OrderProductRecord({error,data}){  
  if(data){
  this.OrderProducts= JSON.parse(JSON.stringify(data));
  console.log('Data '+this.OrderProducts);
  for(let i=0;i<this.OrderProducts.length;i++){
  if(this.OrderProducts[i].Legacy_Start_Date__c!=undefined){
    this.OrderProducts[i].Legacy_Start_Date__c = new Intl.DateTimeFormat(LOCALE).format(new Date(this.OrderProducts[i].Legacy_Start_Date__c));
  }
    if(this.OrderProducts[i].Legacy_End_Date__c!=undefined){
    this.OrderProducts[i].Legacy_End_Date__c = new Intl.DateTimeFormat(LOCALE).format(new Date(this.OrderProducts[i].Legacy_End_Date__c));
    } 
  }
  }else{        
      console.log('Error '+JSON.stringify(error)); 
    this.errorMsg = error;
  }
}
}