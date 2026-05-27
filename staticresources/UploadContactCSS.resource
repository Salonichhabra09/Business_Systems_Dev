/* remove the "or drop files" label from the right of the lightning:input type file */
.slds-file-selector__dropzone .slds-file-selector__text{
	display: none !important;
}


/* remove the "Upload Files" text from the button of the lightning:input type file */
.slds-file-selector__dropzone .slds-file-selector__button{
    font-size: 0 !important;
}

/* insert the text "New Exam" into the button of the lightning:input type file */
.slds-file-selector__dropzone .slds-file-selector__button:after{
    content: 'Upload File' !important;
    font-size: .8125rem !important;
    color: rgba(27, 82, 151, 1.0) !important;
	
}

.slds-file-selector__dropzone{ /*the border around*/
    border: none;
}

