import { LightningElement,api,wire } from 'lwc';
import uploadFile from '@salesforce/apex/CustomerRequestController.uploadFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAccountLogo from '@salesforce/apex/CustomerRequestController.relatedFiles';

export default class ImageUploader extends LightningElement {
    @api recordId;
  newFileWasUploaded = false;
  AccountLogo;
  uploadedFilesUrl = [];
  logoId;

  get acceptedFormats() {
      return ['.jpg','.png','.jpeg','.svg'];
  }

  connectedCallback(){
    //console.log('Inside Imageuploader ');
    getAccountLogo({ evaluatorId : this.recordId })
    .then(result =>{
        this.AccountLogo = result; 
      //console.log('DATA from WIRE '+this.AccountLogo);
    })
    .catch(error =>{

    })

    }
  /*@wire(getAccountLogo, { evaluatorId : '$recordId' })
  idPhotoDetails({ data, error }){
  if (data) {
      this.AccountLogo = data; 
      //console.log('DATA from WIRE '+this.AccountLogo);
   }else if(error){
  }
  }*/

  handleUploadFinished(event) {
      const uploadedFiles = event.detail.files;
      if(uploadedFiles && uploadedFiles.length > 0){
          this.newFileWasUploaded = true;
          this.uploadedFilesUrl = [];
          uploadedFiles.forEach(element => {
              this.uploadedFilesUrl.push({
                  id : '/sfc/servlet.shepherd/version/download/' + element.contentVersionId
              })
              uploadFile({ fileName:element.contentVersionId, recordId:this.recordId }).then(result=>{
                this.fileData = null
                let title = `${filename} uploaded successfully!!`;
                this.ShowToast('Success!', title, 'success', 'dismissable');
            }).catch(err=>{
                //console.log('Error '+JSON.stringify(err));
            }).finally(() => {
                this.handleSpinner();
            })
          });
          //console.log('Image url '+JSON.stringify(this.uploadedFilesUrl));
      }
  }


 /* @track showSpinner = false;
    @track fileData;
    @track fileName;
     // getting file 
    handleFileChange(event) {
        if(event.target.files.length > 0) {
            const file = event.target.files[0]
            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                this.fileName = file.name;
                this.fileData = {
                    'filename': this.fileName,
                    'base64': base64
                }
                //console.log(this.fileData)
            }
            reader.readAsDataURL(file)
        }
    }
 
    uploadFile() {
        this.handleSpinner();
        const {base64, filename} = this.fileData
 
        uploadFile({ fileName:this.fileName, base64Data : base64, recordId:this.recordId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`;
            this.ShowToast('Success!', title, 'success', 'dismissable');
            this.updateRecordView(this.recordId);
        }).catch(err=>{
            this.ShowToast('Error!!', err.body.message, 'error', 'dismissable');
        }).finally(() => {
            this.handleSpinner();
        })
    } */
 
    handleSpinner(){
        this.showSpinner = !this.showSpinner;
    } 
 
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    } 
 
    //update the record page
}