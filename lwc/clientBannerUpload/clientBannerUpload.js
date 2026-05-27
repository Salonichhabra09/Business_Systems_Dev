import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import BANNER_IMAGE_FIELD from '@salesforce/schema/Job__c.BannerImage__c';
import ID_FIELD from '@salesforce/schema/Job__c.Id';
import uploadBannerImage from '@salesforce/apex/CustomerRequestController.uploadBannerImage';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class JobBannerUploader extends LightningElement {
    @api recordId; // Job__c record ID
    imageUrl; // Stores existing banner image URL
    newImageUrl; // Stores newly uploaded image preview URL
    fileData;
    showUploadButton = false; // Controls upload button visibility
    isUploading = false; // Shows spinner during upload

    // Fetch Job__c record and get BannerImage__c field value
    @wire(getRecord, { recordId: '$recordId', fields: [BANNER_IMAGE_FIELD] })
    wiredJob({ data, error }) {
        if (data) {
            const bannerImageId = data.fields.BannerImage__c.value;
            if (bannerImageId) {
                this.imageUrl = `/sfc/servlet.shepherd/document/download/${bannerImageId}`;
            }
        } else if (error) {
            console.error('Error fetching existing banner:', error);
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0];

        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                let img = new Image();
                img.onload = () => {
                    if (img.width === 1310 && img.height === 190) {
                        this.fileData = { fileName: file.name, base64: reader.result.split(',')[1] };
                        this.newImageUrl = reader.result; // Show preview of uploaded image
                        this.showUploadButton = true;
                    } else {
                        this.showToast('Error', 'Image size must be 1310 x 190 pixels.', 'error');
                    }
                };
                img.src = reader.result;
            };
            reader.readAsDataURL(file);
        }
    }

    async uploadImage() {
        if (!this.fileData) return;

        this.isUploading = true; // Show spinner

        try {
            const fileId = await uploadBannerImage({
                jobId: this.recordId,
                fileName: this.fileData.fileName,
                base64Data: this.fileData.base64
            });

            this.imageUrl = `/sfc/servlet.shepherd/document/download/${fileId}`;
            this.showUploadButton = false;

            // Update the record UI to reflect new image without refresh
            await updateRecord({
                fields: {
                    [ID_FIELD.fieldApiName]: this.recordId,
                    [BANNER_IMAGE_FIELD.fieldApiName]: fileId
                }
            });

            this.showToast('Success', 'Banner image uploaded successfully.', 'success');
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            this.showToast('Error', 'Failed to upload banner image.', 'error');
            console.error('Upload error:', error);
        } finally {
            this.isUploading = false; // Hide spinner
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}