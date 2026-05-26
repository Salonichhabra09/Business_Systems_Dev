({
    listPDF_Res:[],
    listPDF:[],
    send: true,
    removeLogo: true,
    MAX_FILE_SIZE: 40000,
    
    handleInit: function(component, event, helper) { 
        var self = this;
        
        self.listPDF_Res = [];
        self.listPDF = [];
        window.jsPDF = window.jspdf.jsPDF;
        
        // let reloadFlag = component.get('v.reloadFlag'); 
        
        // if(!reloadFlag){
        self.helperCheckUserAccess(component, event, helper); 
        // }
        
    },
    
    helperCheckUserAccess: function(component, event, helper){
        let self = this;
        
        self.listPDF_Res = [];
        self.listPDF = [];
        window.jsPDF = window.jspdf.jsPDF;
        
        var action = component.get("c.checkUserPermissions");
        action.setCallback(component, function(response) {
            
            let msg = '';
            let title = '';
            let variant = '';
            let state = response.getState();
            let result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                if(result === 'ALL'){
                    
                    self.helperDisableOptions(component, false, false, false, false, false, false, false);
                    
                    self.helperGetData(component, event, helper);
                    
                } else if(result === 'PREVIEW ONLY'){
                    
                    self.helperDisableOptions(component, true, true, false, false, false, true, true);
                    self.send=false;
                    self.removeLogo = false;
                    self.helperGetData(component, event, helper);
                    
                } else if(result === 'NONE'){
                    
                    self.helperDisableOptions(component, true, true, true, true, true, true, true);
                    self.removeLogo = false;
                    self.send=false;
                    
                    msg = 'Your system User does not have the required permissions to use the Certificate Options.';
                    title = 'Warning';
                    variant = 'warning';
                    component.set("v.showSpinner", false);
                } else {
                    
                    self.helperDisableOptions(component, true, true, true, true, true, true, true);
                    self.removeLogo = false;
                    self.send=false;
                    
                    title = 'Error';
                    msg = 'Something went wrong! Please contact your System Administrator.';
                    variant = 'error';
                    component.set("v.showSpinner", false);
                }
            } else {
                
                self.helperDisableOptions(component, true, true, true, true, true, true, true);
                self.removeLogo = false;
                
                msg = 'Something went wrong! Please contact your System Administrator.'; //$A.log("Errors", response.getError());
                title = 'Error';
                variant = 'error';
                component.set("v.showSpinner", false);
            }
            
            if(title != '' || msg != ''){
                component.find('notify').showToast({
                    "variant": variant,
                    "title": title,
                    "message": msg,
                    "mode": 'dismissible',
                    "duration": 20000
                })                
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    
    helperGetData: function(component, event, helper){
        var self = this;
        
        var action = component.get("c.getPdfData");
        action.setParams({"courseId": component.get("v.recordId")});
        action.setCallback(component, function(response) {
            
            self.listPDF_Res = [];
            self.listPDF = [];
            
            let msg = '';
            let title = '';
            let variant = '';
            let state = response.getState();
            let body = response.getReturnValue();
            console.log('Praaachiiii ---> ' , body);
            
            let result = body[0].resultMessage;
            let body_length = body.length;
            
            if(state === "SUCCESS"){
                if((body_length == 1 && result === "SUCCESS") || body_length > 1 ){
                    
                    if(self.send){
                        if(body[0].DeliveryMode == 'FACE'){
                            component.set('v.disabledSend', true); 
                        } else {
                            component.set('v.disabledSend', false);
                        }                        
                    }
                    
                    if(self.removeLogo){
                        if(body[0].fileExtension == '' || body[0].fileExtension == null ) {
                            component.set('v.disabledRemovePartnerLogo', false);
                        } else {
                            component.set('v.disabledRemovePartnerLogo', true);
                        }
                    }
                    
                    let countToSend = 0;
                    let countToDownload = 0;
                    for(var i = 0; i<body_length; i++){
                        countToDownload++;
                        self.helperCreateSinglePDF(body[i], component);
                        
                        if(body[i].sendDate == 'NULL'){
                            countToSend++; 
                        }
                        
                    }
                    component.set('v.sendListSize_onInit',countToSend );
                    component.set('v.downloadListSize_onInit',countToDownload );
                    component.set("v.showSpinner", false);
                } else if(result === 'NO COURSE'){
                    
                    msg = 'An error occured while getting the Course information! Plaese try again or contact your System Administrator.';
                    title = 'Error';
                    variant = 'error';
                    
                    self.helperDisableOptions(component, true, true, true, true, true, true, true);
                    component.set("v.showSpinner", false);
                } else if(result === 'NO SHL LOGO'){
                    
                    msg = 'SHL logo does not exist in the system. Please ask your System Administrator to add the SHL Logo to email template "Certificate_SHL_Logo".';
                    title = 'Error';
                    variant = 'error';
                    
                    self.helperDisableOptions(component, true, true, true, true, false, true, true);  
                    component.set("v.showSpinner", false);
                } else if(result === 'NO CB'){
                    msg = 'This Course has no Course Bookings!';
                    title = 'Information';
                    variant = 'information';
                    
                    self.helperDisableOptions(component, true, true, true, true, false, true, true);
                    component.set("v.showSpinner", false);
                } else if(result === 'FAILURE'){
                    msg = 'This Course has no Course Bookings whith the needed requirements to generate a certificate!';
                    title = 'Information';
                    variant = 'information';
                    
                    self.helperDisableOptions(component, true, true, true, true, false, true, true);
                    component.set("v.showSpinner", false);
                } else {
                    self.helperDisableOptions(component, true, true, true, true, true, true, true);
                    
                    title = 'Error!'; 
                    msg = 'Something went wrong! Please contact your System Administrator.';
                    variant = 'error';
                    component.set("v.showSpinner", false);
                }
            } else {
                self.helperDisableOptions(component, true, true, true, true, true, true, true);
                
                title = 'Error!'; 
                msg = 'Something went wrong! Please contact your System Administrator.';
                variant = 'error';
                component.set("v.showSpinner", false);
            }
            
            if(title != '' || msg != ''){
                component.find('notify').showToast({
                    "variant": variant,
                    "title": title,
                    "message": msg,
                    "mode": 'dismissible',
                    "duration": 20000 
                })                
            }
            
        });
        $A.enqueueAction(action);
    },
    
    helperDisableOptions: function(component, disabledDownloadAll, disabledSend, disabledInputCBNumber, disabledPreview, disabledRefreshData, disabledRemovePartnerLogo, disabledSavePartnerLogo){
        component.set('v.disabledDownloadAll', disabledDownloadAll);
        component.set('v.disabledSend', disabledSend);
        component.set('v.disabledInputCBNumber', disabledInputCBNumber);
        component.set('v.disabledPreview', disabledPreview); 
        component.set('v.disabledRefreshData', disabledRefreshData);
        component.set('v.disabledRemovePartnerLogo', disabledRemovePartnerLogo);
        component.set('v.disabledSavePartnerLogo', disabledSavePartnerLogo);
    },
    
    helperCreateSinglePDF: function(body, component){
        var self = this;
        
        self.helper_ratioImage(body,component, function(result){
            
            window.jsPDF = window.jspdf.jsPDF;
            var doc = new jsPDF();
            let font = '';
            
            /*if(body.Language != 'Chinese (Mandarin/Simplified)'){
                font = "helvetica";
            } else if {
                var profUrl = $A.get('$Resource.jspdfFont');
                doc.addFont(profUrl,"chinese","normal");
                font = "chinese";
            }*/
            
            if(body.Language == 'Chinese (Mandarin/Simplified)'){
                var profUrl = $A.get('$Resource.jspdfFont');
                doc.addFont(profUrl,"chinese","normal");
                font = "chinese";
            } else if(body.Language == 'Japanese') {
                var profUrl = $A.get('$Resource.JapaneseFont');
                //var profUrl = "https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap";
                doc.addFont(profUrl+'/JapaneseFont.ttf',"japanese","normal");
                font = "japanese";
            } else{
                
                font = "helvetica";
            }
            
            if(body.logoURL != ''){
                component.set('v.imageError', false);
                if(result != 'ERROR'){
                    component.set('v.loadImageError', false);
                    doc.addImage(body.logoURL, body.fileExtension, 15, 10, result.width, result.height);
                    
                } else {
                    component.set('v.loadImageError', true);
                    doc.setTextColor(0,0,0);
                    doc.setFont("helvetica", "normal");
                    doc.setFontSize(12);
                    doc.text("[ERROR loading logo]", 10, 30);
                }
            } else {
                component.set('v.imageError', true);
            }
            
            doc.setDrawColor(120,214,75);
            doc.setFillColor(120,214,75);
            doc.circle(170, 35, 25, "FD");
            
            doc.setTextColor(255,255,255);
            doc.setFont("helvetica", "bold");
            doc.setFontSize(18);
            doc.text("SHL", 164, 33);
            
            doc.setTextColor(255,255,255);
            doc.setFont("helvetica", "bold");
            doc.setFontSize(18);
            doc.text("Learning", 157, 43);
            
            doc.setTextColor(120,214,75);
            doc.setFont(font, "normal");
            doc.setFontSize(36);
            doc.text(body.ReplaceCertificateTitle_Label, 105, 80, null, null, "center");
            
            doc.setDrawColor(100);
            doc.setLineWidth(1);
            doc.line(10, 95, 200, 95);
            
            if(font!='japanese'){
                doc.setTextColor(0,0,0);
            	doc.setFont(font, "normal");
            	doc.setFontSize(10);
            	doc.text(body.ReplaceCertifyThat_Label, 105, 110, null, null, "center");
            }
            
            doc.setTextColor(120,214,75);
            doc.setFont(font, "normal");
            doc.setFontSize(36);
            
            var contName;
            contName = doc.splitTextToSize(body.ReplaceName, 190);
            
            doc.text(contName, 105, 130, null, null, "center");
            
            var lineY = 145;
            var successCompletedY = 160;
            var count = 0;
            if(contName != '') {
                contName.forEach(linetxt => {
                    count ++;
                    if(count > 1){
                    lineY = lineY + 8;
                }
                })
                    
                    if(count > 1){
                    successCompletedY = lineY + 12;  
                }
                }
                    doc.setDrawColor(100);
                    doc.setLineWidth(1);
                    doc.line(10, lineY, 200, lineY);
                    
                    if(font!='japanese'){
                        doc.setTextColor(0,0,0);
                        doc.setFont(font, "normal");
                        doc.setFontSize(10);
                        doc.text(body.ReplaceSuccessfullyCompleted_Label, 105, successCompletedY, null, null, "center");
                    }
                    
                    doc.setTextColor(120,214,75);
                    doc.setFont(font, "normal");
                    doc.setFontSize(24);
                    
                    var certName ;
                    var replaceDateY = 210;
                    var replaceLinesY = 230;
                    var replaceRegisNumberY = 250;
                    var replacePointsY = 255;
                    
                    if(body.ReplaceCourseName != ''){
                    component.set('v.displayCourseNameErrorMessage', 'display: none');
                    component.set('v.courseNameError', false);
                    component.set('v.courseNameErrorMessage', '');
                    certName = doc.splitTextToSize(body.ReplaceCourseName, 190);
                    doc.text(certName, 105, 180, null, null, "center");
                    
                    var counter = 0;
                    certName.forEach(lineText => {
                    counter ++;
                    if(counter >= 3){
                    replaceDateY = replaceDateY + 8;
                }
                })
                    if(counter >= 3){
                    replaceLinesY = replaceDateY + 14;  
                    replaceRegisNumberY = replaceLinesY + 11;
                    replacePointsY = replaceRegisNumberY + 5;
                }
                    
                } else {
                    component.set('v.courseNameError', true);
                    component.set('v.displayCourseNameErrorMessage', '/*display: none*/');
                    component.set('v.courseNameErrorMessage', 'The Course Name is not set for the generated certificates! Please provide a value on field "Course Name on Certificate".');
                    doc.text('{{Add a value to field "Course Name on Certificate" }}', 105, 180, null, null, "center");
                }
                    
                    doc.setTextColor(120,214,75);
                    doc.setFont(font, "normal");
                    doc.setFontSize(14);
                    doc.text(body.ReplaceDate, 105, replaceDateY, null, null, "center");
                    
                    doc.setTextColor(0,0,0);
                    
                    doc.setFont(font, "normal");
                    doc.setFontSize(10);
                    var lines = doc.splitTextToSize(body.ReplaceAppropriateTraining_Label, 190);
                    doc.text(lines, 10, replaceLinesY);
                    
                    doc.setFont(font, "normal");
                    doc.setFontSize(10);
                    let width = 10 + Math.ceil(doc.getTextWidth(body.ReplaceResgistrationNumber_Label));
                    doc.text(body.ReplaceResgistrationNumber_Label, 10, replaceRegisNumberY);
                    
                    doc.setFont("helvetica", "normal");
                    doc.setFontSize(10);
                    doc.text(body.ReplaceResgistrationNumber, width, replaceRegisNumberY);
                    
                    if(font!='japanese'){
                    	doc.setFont("helvetica", "normal");
                    	doc.setFontSize(10);
                    	doc.text(body.ReplaceCPDCEUPoints, 10, replacePointsY);
                	}
                    
                    if(font=='japanese'){
                    	doc.setFont(font, "normal");
                	}else{
                    	doc.setFont("helvetica", "normal");
                	}   
             
                    doc.setTextColor(150);
                    doc.setFontSize(8);
                    doc.text(body.ReplaceRightsReserved_Label, 10, doc.internal.pageSize.height - 10);
                    doc.text(body.ReplaceTermsConditions_Label, 10, doc.internal.pageSize.height - 15);
                    
                    
                    self.listPDF.push({'pdf': doc, 'cbNumber': body.cbNumber,'pdfName': body.delegateName + ' Certificate.pdf' });
                var pdfBlob = doc.output('blob');
                self.helperGetPdfBase64String(pdfBlob, body);
                console.log('done');
            });
            component.set("v.showSpinner", false);
        },
                               
                               helper_ratioImage: function(body, component, callback){
            var self = this;
            
            if(body.logoURL != ''){
                var img = new Image();
                let sourceImage = '';
                
                if(body.fileExtension == ''){
                    sourceImage ='data:'+ body.DataType + ';base64,' + body.logoURL;
                } else {
                    sourceImage = body.logoURL;
                }
                
                img.src = sourceImage;
                console.log('img'+img.src);
                img.onload = function() {
                    var result = self.helper_CalculateAspectRatioFit(this.width,this.height,59,40 );            
                    callback(result);
                };
                
                img.onerror = function() {
                    var result = 'ERROR';
                    callback(result);
                };
                
                component.set('v.displayLogoErrorMessage', 'display: none');
                if(self.send){
                    if(body.DeliveryMode != 'FACE'){
                        component.set('v.disabledSend', false);  
                    }  
                }
            } else {
                callback(body.logoURL);
                
                if(self.send){
                    component.set('v.disabledSend', true);
                }
                component.set('v.displayLogoErrorMessage', '/*display: none*/');
                component.set('v.logoErrorMessage', 'There is no SHL logo defined in the system and no Course Partner logo was provided! Please contact your system administrator for the SHL logo or provide a Partner logo image in field "Course Partner Logo"');
            }
        },
            
            helperGetPdfBase64String: function(pdfBlob,body){
                var self = this;
                var reader = new FileReader();
                reader.readAsDataURL(pdfBlob);
                reader.onloadend = function () {
                    var base64String = reader.result;    
                    var base64StringClean = base64String.replace('data:application/pdf;base64,','');
                    
                    if(body.sendDate == 'NULL'){
                        self.listPDF_Res.push({'cbId': body.cbId, 'pdfBase64String': base64StringClean, 'cbNumber': body.cbNumber });
                    } 
                }
            },
                
                helper_CalculateAspectRatioFit: function(srcWidth, srcHeight, maxWidth, maxHeight) {  
                    var ratio = Math.min(maxWidth / srcWidth, maxHeight / srcHeight);
                    return { width: srcWidth*ratio, height: srcHeight*ratio };
                },
                    
                    handleFilesChangeHelper: function(component, event, helper){
                        var files = event.getSource().get("v.files");
                        var file = files[0];
                        let self = this;
                        
                        if (file) {
                            if(file.size < self.MAX_FILE_SIZE){
                                var reader = new FileReader();
                                reader.readAsDataURL(file);
                                reader.onload = function (evt) {
                                    var image = evt.target.result;
                                    
                                    let typeEndIndex = image.indexOf(';');
                                    let typeStartIndex = image.indexOf('/') + 1;
                                    let type = image.substring(typeStartIndex,typeEndIndex);
                                    let name = 'certificatePartnerLogo';
                                    
                                    var base64 = 'base64,';
                                    var fileStart = image.indexOf(base64) + base64.length;
                                    
                                    var base64File = image.substring(fileStart);
                                    
                                    var action = component.get("c.savePartnerLogo");
                                    action.setParams({
                                        "partnerLogoData" : base64File,
                                        "name": name,
                                        "fileType": type,
                                        "courseId": component.get('v.recordId')
                                    });
                                    action.setCallback(component, function(response) {
                                        let msg = '';
                                        let title = '';
                                        let variant = '';
                                        let state = response.getState();
                                        let result = response.getReturnValue();
                                        
                                        if (state === "SUCCESS"){
                                            
                                            if (result === "SUCCESS") {
                                                $A.get('e.force:refreshView').fire();
                                                component.set('v.disabledRemovePartnerLogo', false);
                                            } else {
                                                msg = 'Something went wrong uploading the partner logo! Please contact your System administrator and provide the following message: ' + result ;
                                                title = 'Error';
                                                variant = 'error'; 
                                            } 
                                        } else {
                                            msg = 'Something went wrong! Please contact your System administrator.';
                                            title = 'Error';
                                            variant = 'error'; 
                                        }
                                        
                                        if( msg != '' || title != ''){
                                            component.find('notify').showToast({
                                                "variant": variant,
                                                "title": title,
                                                "message": msg,
                                                "mode": 'dismissible',
                                                "duration": 20000
                                            })
                                        }
                                        
                                        component.set("v.showSpinner", false);
                                    });
                                    $A.enqueueAction(action);
                                }
                            } else {
                                component.find('notify').showToast({
                                    "variant": "error",
                                    "title": "Partner logo image size error!",
                                    "message": 'Please upload a partner logo image under ' + (self.MAX_FILE_SIZE/1000) + ' KB',
                                    "mode": 'dismissible',
                                    "duration": 20000
                                })
                                component.set("v.showSpinner", false);
                            }
                        } 
                        
                    },    
                        
                        handleRemovePartnerLogoHelper: function(component, event, helper){
                            var action = component.get("c.deletePartnerLogo");
                            action.setParams({
                                "courseId": component.get('v.recordId')
                            });
                            action.setCallback(component, function(response) {
                                let msg = '';
                                let title = '';
                                let variant = '';
                                let state = response.getState();
                                let result = response.getReturnValue();
                                
                                if (state === "SUCCESS"){
                                    
                                    if (result === "SUCCESS") {
                                        $A.get('e.force:refreshView').fire();
                                        component.set('v.disabledRemovePartnerLogo', true);
                                    } else {
                                        msg = 'Something went wrong deleting the partner logo! Please contact your System administrator and provide the following message: ' + result ;
                                        title = 'Error';
                                        variant = 'error'; 
                                    } 
                                } else {
                                    msg = 'Something went wrong deleting the partner logo! Please contact your System administrator.';
                                    title = 'Error';
                                    variant = 'error'; 
                                }
                                
                                if( msg != '' || title != ''){
                                    component.find('notify').showToast({
                                        "variant": variant,
                                        "title": title,
                                        "message": msg,
                                        "mode": 'dismissible',
                                        "duration": 20000
                                    })
                                }
                                component.set("v.showSpinner", false);
                            });
                            $A.enqueueAction(action);
                        },
                            
                            handleSendHelper: function(component, event, helper){
                                var self = this;
                                let loadImageError = component.get('v.loadImageError');
                                let courseNameError = component.get('v.courseNameError');
                                let imageError = component.get('v.imageError');
                                let errorList = [];
                                let successList = [];
                                let errorCount = 0;
                                let successCount = 0;
                                
                                let initSendCount = component.get('v.sendListSize_onInit');
                                
                                if(initSendCount == self.listPDF_Res.length){
                                    if(!imageError && !courseNameError && !loadImageError){
                                        
                                        if(self.listPDF_Res.length != 0){
                                            
                                            let originalList = self.listPDF_Res;
                                            let originalListSize = (self.listPDF_Res).length;
                                            const splitValue = 3;
                                            let splitSize = Math.ceil(originalListSize/splitValue);
                                            
                                            let listRemaining = [];
                                            let listToSend = []; 
                                            let listFinal = [];
                                            let listToSplit = self.listPDF_Res;
                                            
                                            if(originalListSize > splitValue){
                                                
                                                let j = 1;
                                                let end = 1;
                                                
                                                for(let i = 1; i <= originalListSize; i++){
                                                    listToSend.push(originalList[i-1]);
                                                    
                                                    if(i == j*splitValue){
                                                        listFinal.push(listToSend);
                                                        listToSend = [];
                                                        j++;
                                                        end = i;
                                                    }
                                                }
                                                
                                                if(end < originalListSize){
                                                    let startIndex = end;
                                                    let stoptIndex = originalListSize - startIndex;
                                                    
                                                    listRemaining = listToSplit.splice(startIndex,stoptIndex);
                                                    
                                                    listFinal.push(listRemaining);
                                                }
                                                
                                            } else {
                                                listFinal.push(originalList)
                                            }
                                            
                                            for(let k = 0; k < listFinal.length; k++){
                                                
                                                //timeout needed to treat each action individually and avoid payload error
                                                window.setTimeout(
                                                    $A.getCallback(function() {
                                                        
                                                        this["action"+k] = component.get("c.sendPDF");
                                                        (this["action"+k]).setParams({
                                                            "pdfDataObj_List" : listFinal[k]
                                                        });
                                                        
                                                        (this["action"+k]).setCallback(component, function(response) {
                                                            let msg = '';
                                                            let title = '';
                                                            let variant = '';
                                                            let state = response.getState();
                                                            let result = response.getReturnValue();
                                                            
                                                            if (state === "SUCCESS"){
                                                                
                                                                if (result === "SUCCESS") {
                                                                    successList.push(listFinal[k]);
                                                                } else if (result === "ERROR") {
                                                                    errorList.push(listFinal[k]);
                                                                } else {
                                                                    errorList.push(listFinal[k]);
                                                                }
                                                                
                                                            } else {
                                                                var errors = response.getError();
                                                                if(errors){
                                                                    if(errors[0] && errors[0].message) {
                                                                        console.log("Error: " , errors[0].message );
                                                                    }
                                                                }
                                                                errorList.push(listFinal[k]);
                                                            }
                                                            
                                                            let successListLength = successList.length;
                                                            let errorListLength = errorList.length;                                    
                                                            
                                                            if(listFinal.length == (successListLength + errorListLength)){
                                                                self.listPDF_Res = [];
                                                                self.listPDF = [];
                                                                self.handleRefreshData(component, event, helper);
                                                                
                                                                if(successListLength > 0 ){
                                                                    for(let z = 0 ; z < successListLength; z++){
                                                                        for(let w = 0; w < successList[z].length; w++ ){
                                                                            successCount++;
                                                                        }
                                                                    }
                                                                    msg = successCount + ' Certificates successfully sent!';
                                                                    title = 'Success';
                                                                    variant = 'success';
                                                                    
                                                                    component.find('notify').showToast({
                                                                        "variant": variant,
                                                                        "title": title,
                                                                        "message": msg,
                                                                        "mode": 'dismissible',
                                                                        "duration": 25000
                                                                    })
                                                                    
                                                                }
                                                                if(errorListLength > 0){
                                                                    let cbNumbers = '';
                                                                    for(let x = 0 ; x < errorListLength; x++){
                                                                        for(let y = 0; y < errorList[x].length; y++ ){
                                                                            cbNumbers = cbNumbers + errorList[x][y].cbNumber;
                                                                            errorCount++;
                                                                            if(y == (errorList[x].length)-1){
                                                                                cbNumbers = cbNumbers + '.\n';
                                                                            } else {
                                                                                cbNumbers = cbNumbers + ', ';
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    variant = 'error';
                                                                    title = 'Issue sending ' + errorCount +' Certificates!';
                                                                    msg = 'Something went wrong sending the certificates for the following CB:\n'+cbNumbers+' \n '+ 'Please click the "Refresh Data" button and try again.\n If the error persists, please contact your System Adminstrator.';
                                                                    
                                                                    component.find('notify').showToast({
                                                                        "variant": variant,
                                                                        "title": title,
                                                                        "message": msg,
                                                                        "mode": 'sticky'
                                                                    })
                                                                }
                                                                component.set("v.showSpinner", false);
                                                            }
                                                        });
                                                        $A.enqueueAction(this["action"+k]);
                                                        
                                                    }), 1
                                                );
                                                
                                            }              
                                            
                                        } else {
                                            component.find('notify').showToast({
                                                "variant": 'warning',
                                                "title": 'Warning!',
                                                "message": 'There are no Certificates that meet the requirements to be sent!',
                                                "mode": 'dismissible',
                                                "duration": 25000 
                                            });
                                            component.set("v.showSpinner", false)
                                        }           
                                    } else {
                                        let message = 'Please address the following issues before sending the certificate(s): \r\n';
                                        if(loadImageError){
                                            message = message + '- Error Loading Logo Image! Please Contact your System Administrator. \r\n';
                                        }
                                        if(courseNameError){
                                            message = message + '- Course Name on Certificate missing. \r\n';
                                        }
                                        if(imageError){
                                            message = message + '- Logo missing! Add a partner logo or request your System Administrator to provide the SHL logo in the system.'
                                        }
                                        
                                        component.find('notify').showToast({
                                            "variant": 'warning',
                                            "title": 'Warning!',
                                            "message": message,
                                            "mode": 'sticky',
                                        });
                                        component.set("v.showSpinner", false);
                                    }
                                    
                                } else {
                                    component.find('notify').showToast({
                                        "variant": 'warning',
                                        "title": 'Please click button "Refresh Data" before Send! ',
                                        "message": 'Data needs to be refreshed before sending.',
                                        "mode": 'dismissible',
                                        "duration": 25000 
                                    });
                                    component.set("v.showSpinner", false);
                                }
                            },
                                
                                handlePreviewHelper: function(component, event, helper) { 
                                    let self = this;
                                    window.jsPDF = window.jspdf.jsPDF;
                                    var doc = new jsPDF();
                                    let pdfSrc = '';
                                    let inputField = '';
                                    let inputValue = '';
                                    //let doc = '';
                                    let file = '';
                                    let index = 0;
                                    let contains = false;
                                    
                                    inputField = component.find("inputCbNumber");
                                    inputValue = inputField.get("v.value");
                                    inputField.setCustomValidity("");
                                    let validity = '';
                                    if(inputValue) {
                                        
                                        let listLength = self.listPDF.length;
                                        for(var i = 0 ; i < listLength; i++){
                                            if((self.listPDF[i].cbNumber).toUpperCase() == inputValue.toUpperCase()){
                                                contains = true
                                                index = i;
                                            } 
                                        }
                                        
                                        if(!inputValue.match("[C|c][B|b][0-9]{6}")){
                                            inputField.setCustomValidity("Please insert a valid Booking Number!");
                                            validity = 'ISSUE';
                                        } else if(!contains){
                                            inputField.setCustomValidity("This Booking Number cannot be previewed!");
                                            validity = 'ISSUE';
                                        }            
                                    } 
                                    
                                    inputField.reportValidity(); 
                                    
                                    doc = self.listPDF[index].pdf;
                                    var blob = doc.output( 'blob' );
                                    let fileName = self.listPDF[index].pdfName;
                                    
                                    file = new File( [blob], fileName , { type: 'application/pdf' } );
                                    
                                    if(component.get('v.disabledDownloadAll')){
                                        pdfSrc = URL.createObjectURL( file )+'#toolbar=0';
                                    } else {
                                        pdfSrc = URL.createObjectURL( file );
                                    }
                                    
                                    component.set('v.pdf', pdfSrc);
                                    
                                    if(validity != ''){
                                        component.set('v.displayIframe', 'display: none');
                                    } else {
                                        component.set('v.displayIframe', '/*display: none*/');
                                    }
                                    
                                    
                                    component.set('v.showPreview', true);
                                    
                                    component.set("v.showSpinner", false); 
                                    
                                },
                                    
                                    handleClosePreviewHelper : function(component, event, helper){
                                        component.set('v.displayIframe', 'display: none');
                                        component.set('v.showPreview', false);
                                    },
                                        
                                        handleDownloadAllHelper : function(component, event, helper){
                                            let self = this;
                                            let listLength = self.listPDF.length;
                                            window.jsPDF = window.jspdf.jsPDF;
                                            var pdf = new jsPDF();
                                            
                                            
                                            let downloadCount = component.get('v.downloadListSize_onInit');
                                            
                                            if(downloadCount == listLength ){
                                                //to overcome browser limitation of stopping at 10 downloaded files
                                                for (let i = 0; i < listLength; i += 1) {
                                                    setTimeout(
                                                        () => {
                                                            let name = self.listPDF[i].pdfName;
                                                            pdf = self.listPDF[i].pdf;
                                                            pdf.save(name);
                                                        },
                                                        i * 150 // Delay download every 150ms
                                                    );
                                                }    
                                            } else {
                                                component.find('notify').showToast({
                                                    "variant": 'warning',
                                                    "title": 'Please click button "Refresh Data" before Download All! ',
                                                    "message": 'Data needs to be refreshed before downloading all certificates.',
                                                    "mode": 'dismissible',
                                                    "duration": 25000 
                                                });
                                            }
                                        },
                                            
                                            
                                            handleRefreshData: function(component, event, helper){
                                                let showPreview = component.get('v.showPreview');
                                                let self = this;
                                                
                                                if(showPreview) {
                                                    self.handleClosePreviewHelper(component, event, helper);
                                                    self.helperCheckUserAccess(component, event, helper);
                                                    //self.helperGetData(component, event, helper); 
                                                } else {
                                                    self.helperCheckUserAccess(component, event, helper);
                                                    //self.helperGetData(component, event, helper);
                                                }
                                            },
                                                
                                                
    })