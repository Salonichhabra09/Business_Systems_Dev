import { LightningElement,api,track,wire } from 'lwc';
import getDataForPDF from '@salesforce/apex/GenerateAccountPlanPDF.getDataForPDF';
import savePDF from '@salesforce/apex/GenerateAccountPlanPDF.saveAccountPlanPDF';
import updatecheckPDF from '@salesforce/apex/GenerateAccountPlanPDF.updatecheckPDF';
import jsPDF from '@salesforce/resourceUrl/jsPDF';
import jspdfAutotable from '@salesforce/resourceUrl/jspdfAutotable';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CreateAccountPlanPDF extends LightningElement {
    @api recordId;
    @api imgUrl;
    @api pdfFromButton;
    wiredData;
    strategyData;
    currentOppData;
    showSpinner = false;
    systemData;
    BDA;
    competitorData;
 

    OppBeforeReview;
    ContactBeforeReview
    accountPlanData;
    data;
    error;
    AccountName;
    LastUpdate;
    LastReview;
    AccountManager;
    SalesManager;
    BU;
    GlobalHQ;
    Territory;
    Segment;
    RADType;
    TargetTier;
    SummaryCurrentSHLRelation = '';
    Website;
    Industry;
    GlobalFTE;
    RegionalFTE;
   // BusinessOverview;
    ClientStrategy;
    RiskExposure;
    CurrentSituation;
    RelationHistory;
    accordianName;
    StrategicGoals;
    LastAccountReview;
    PDFheader;
    acountPlanName;
    ContentDocumentID;
    Contacts;
    Contacts12Month;
    Cases;
    Opportunities;
    OppValue;
    Cases12Months;
    ContactRelation = '';
    HistoryTrend = '';
    historyimage;
    contactimage;
    WhiteSpaceData;
    ContractList;
    Name;
    checkPDF;
    FiscalYear;
    BusinessOverview;
    totalPotential;
    totalSales;
    incumbentDate;
    jsPdfInitialized
    strategyDataOpen = [];
    strategyDataCompleted =[];
    buyingCentreId;
    accountPlanType;
    dNumber;

    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }
        this.showSpinner=true;
        this.jsPdfInitialized = true;
        try {

            Promise.all([

                loadScript(this, jsPDF),
                loadScript(this, jspdfAutotable)
            ]).then(() => {

                getDataForPDF({ recordID: this.recordId }).then(data => {

                    let year = new Date().getFullYear();
                    let month = new Date().getMonth();
                    let quarter ;

                    if(0 == month || month == 1 || month == 2){
                        quarter='Q1';
                    }
                    
                   else if( month==3  || month ==4 || month == 5){
                        quarter='Q2';
                    }
                    
                   else if(month==6 || month ==7 || month == 8){
                        quarter='Q3';
                    }
                    else if(month==9  || month ==10 || month == 11){
                        quarter='Q4';
                    }

                    
                    this.accountId = data.AccountId;
                    this.PDFheader = "SHL " + quarter + '/' +year + " Account Plan- " + data.AccountName;
                    this.Name = data.Name;
                    this.AccountName = data.AccountName;
                    this.AccountManager = data.AccountManager;
                    this.SalesManager = data.SalesManager;
                    this.BU = data.BU;
                    this.Territory = data.TerritoryType;
                    this.Segment = data.Segment;
                    this.RADType = data.RADType;
                    this.Website = data.Website;
                    this.Industry = data.Industry;
                    this.GlobalFTE = data.GlobalFTE;
                    this.RegionalFTE = data.RegionalFTE;
                    this.BusinessOverview = data.BusinessOverview;
                    this.ClientStrategy = data.ClientStrategy;
                    this.CurrentSituation = data.CurrentSituation;
                    this.RelationHistory = data.RelationHistory;
                    this.RiskExposure = data.RiskExposure;
                    this.LastAccountReview = data.LastAccountReviewed;
                    this.SummaryCurrentSHLRelation = data.SummaryCurrentSHLRelation;
                    this.GlobalHQ = data.GlobalHQ;
                    this.LastUpdate = data.LastUpdated;
                    this.LastReview = data.LastReviewed;
                    this.acountPlanName = data.Name;
                    this.ContentDocumentID = data.ContentDocumentID;
                    this.Contacts = data.Contacts;
                    this.Contacts12Month = data.Contacts12Month;
                    this.Cases = data.Cases;
                    this.Opportunities = data.Opportunities;
                    this.OppValue = data.OppValue;
                    this.Cases12Months = data.Cases12Months;
                    //this.HistoryTrend = data.HistoryTrend;
                    //this.WhiteSpaceData = data.whiteSpaceWrapper.listWrapper;
                    //this.WhiteSpaceData = data.whiteSpaceWrapper.detailsWrapper.whiteSpaceOppList;
                    this.strategyDataCompleted = data.strategyWrapperCompleted;
                    this.strategyDataOpen = data.strategyWrapperOpen;
                    this.currentOppData = data.currentOppWrapper.currentPipeline;
                    //this.systemData = data.systemWrapper.aiData;
                    //this.competitorData = data.competitorWrapper;
                    this.ContractList = data.contractWrapper;
                    this.checkPDF = data.checkPDF;
                    this.ContactBeforeReview = data.ContactBeforeReview;
                    this.OppBeforeReview = data.OppBeforeReview;
                    this.FiscalYear = data.FiscalYear;
                    this.TargetTier = data.TargetTier;
                    this.BDA = data.BDA;
                    this.buyingCentreId = data.buyingCentreId;
                    this.accountPlanType = data.accountPlanType;
                    this.dNumber = data.dNumber;
                    this.totalSales=data.currentOppWrapper.totalSalesValue;
            
                    if (this.checkPDF == true || this.pdfFromButton == true) {
                        this.generatePDF();

                    }

                }).catch(Error => {
                    console.log('Error -->', JSON.stringify(Error));
                })


           

            }).catch(error => {
                console.error("Error " + JSON.stringify(error));
            });
        } catch (error) {

            this.showSpinner = false;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: "Error occured while generating Account Plan.Please contact System Admin." + "\n" + error.message,

            });
            this.dispatchEvent(event);
        }
    }

    generatePDF() {

        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('l');

           

            //PDF Header
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(15);

            doc.text(this.PDFheader, 150, 20, null, null, "center");
            doc.setFillColor(242, 242, 242);
            doc.rect(10, 30, 280, 8, 'F');
            //doc.rect(152, 15, 140, 8, 'F');


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
           doc.text(127, 35.5, 'Account Plan Details');
           //doc.text('Account Plan Details', 50, 20.5, null, null, "center");

            //doc.text(200, 20.5, 'Customer Profile');




            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, 55, 'Account Name : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var AccountNameText = (typeof (this.AccountName) != 'undefined') ? this.AccountName : '';
            var AccountName = doc.splitTextToSize(AccountNameText, 70);
            let x1 = 15 + Math.ceil(doc.getTextWidth('Business Defined Attribute  : '));
            doc.text(x1, 55, AccountName);

            let y1 = 55;
            let c1 = 0;
            if (AccountName != '') {
                AccountName.forEach(linetxt => {
                    c1++;
                    if (c1 > 1) {
                        y1 = y1 + 4;
                    }
                });
            }

           doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, 55, 'Date Plan Last Updated :');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var LastUpdate = (typeof (this.LastUpdate) != 'undefined') ? this.LastUpdate : '';
            let x2 = 175+x1-8;
            doc.text(x2, 55, LastUpdate);
            
            y1 = 65;
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);

            doc.text(13, y1, 'Account Manager : ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var AccountManagerText = (typeof (this.AccountManager) != 'undefined') ? this.AccountManager : '';
            var AccountManager = doc.splitTextToSize(AccountManagerText, 70);
            doc.text(x1, y1, AccountManager);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y1, 'Date of Last Plan Review : ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var LastReview = (typeof (this.LastReview) != 'undefined') ? this.LastAccountReview : '';
            doc.text(x2, y1, LastReview);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);

            doc.text(13, y1+10, 'Sales Manager : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
           
            var SalesManagerText = (typeof (this.SalesManager) != 'undefined') ? this.SalesManager : '';

            var SalesManager = doc.splitTextToSize(SalesManagerText, 70);
            doc.text(x1, y1+10, SalesManager);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y1+10, 'Date for Next Plan Review :');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

           
           
            var LastAccountReview = (typeof (this.LastAccountReview) != 'undefined') ? this.LastAccountReview : '';
            doc.text(x2, y1+10, LastAccountReview);

            let y3 = y1 + 20;
            let c3 = 0;
            if (SalesManager != '') {
                SalesManager.forEach(linetxt => {
                    c3++;
                    if (c3 > 1) {
                        y3 = y3 + 4;
                    }
                });
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y3, 'BU : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var BUText = (typeof (this.BU) != 'undefined') ? this.BU : '';

            doc.text(x1, y3, BUText);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y3, 'Website : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
           
            var WebsiteText = (typeof (this.Website) != 'undefined') ? this.Website : '';
            var Website = doc.splitTextToSize(WebsiteText, 85);
            doc.text(x2, y3, Website);

            let y4 = y3 + 10;
            let c7 = 0;
            if (Website != '') {
                Website.forEach(linetxt => {
                    c7++;
                    if (c7 > 1) {
                        y4 = y4 + 4;
                    }
                });
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y4, 'Territory Type : ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var TerritoryText = (typeof (this.Territory) != 'undefined') ? this.Territory : '';

            var Territory = doc.splitTextToSize(TerritoryText, 70);
            doc.text(x1, y4, Territory);

            let y5 = y4 + 10;
            let c4 = 0;
            if (Territory != '') {
                Territory.forEach(linetxt => {
                    c4++;
                    if (c4 > 1) {
                        y5 = y5 + 4;
                    }
                });
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y4, 'Industry : ');

            doc.setFont('helvetica', 'normal');

            doc.setFontSize(10);
            
            var IndustryText = (typeof (this.Industry) != 'undefined') ? this.Industry : '';
            var Industry = doc.splitTextToSize(IndustryText, 85);
            doc.text(x2, y4, Industry);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);


            doc.text(13, y5, 'RAD Strategy : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            let x6 = 9 + Math.ceil(doc.getTextWidth('RAD Strategy : '));
            var RADTypeText = (typeof (this.RADType) != 'undefined') ? this.RADType : '';

            var RADType = doc.splitTextToSize(RADTypeText, 40);
            doc.text(x1, y5, RADType);

            let y6 = y5 + 10;
            let c5 = 0;
            if (RADType != '') {
                RADType.forEach(linetxt => {
                    c5++;
                    if (c5 > 1) {
                        y6 = y6 + 4;
                    }
                });
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y5, 'Fiscal Year End : ');

            doc.setFont('helvetica', 'normal');

            doc.setFontSize(10);

            var FiscalYearText = (typeof (this.FiscalYear) != 'undefined') ? this.FiscalYear : '';
            var FiscalYear = doc.splitTextToSize(FiscalYearText, 85);
            doc.text(x2, y5, FiscalYear);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y6, 'Segment : ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

           
            var SegmentText = (typeof (this.Segment) != 'undefined') ? this.Segment : '';
            var Segment = doc.splitTextToSize(SegmentText, 70);
            doc.text(x1, y6, Segment);

            let y7 = y6 + 10;
            let c6 = 0;
            if (Segment != '') {
                Segment.forEach(linetxt => {
                    c6++;
                    if (c6 > 1) {
                        y7 = y7 + 4;
                    }
                });
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y6, 'Global #FTE : ');

            doc.setFont('helvetica', 'normal');


            doc.setFontSize(10);
            var GlobalFTEText = (typeof (this.GlobalFTE) != 'undefined') ? this.GlobalFTE.toString() : '';
            doc.text(x2, y6, GlobalFTEText);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y7, 'Target Tier : ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

           
            var TargetTierText = (typeof (this.TargetTier) != 'undefined') ? this.TargetTier : ''; 
            doc.text(x1, y7, TargetTierText);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y7, 'Regional #FTE : ');

            doc.setFont('helvetica', 'normal');

            doc.setFontSize(10);
            
            var RegionalFTEText = (typeof (this.RegionalFTE) != 'undefined') ? this.RegionalFTE.toString() : '';
            doc.text(x2, y7, RegionalFTEText);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y7+10, 'Open Strategies : ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var openStrategies = (this.strategyDataOpen) ? this.strategyDataOpen.length.toString() : '0'; 
            doc.text(x1, y7+10, openStrategies);


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y7 +10, 'Location of Global HQ :');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var GlobalHQText = (typeof (this.GlobalHQ) != 'undefined') ? this.GlobalHQ : '';
            var GlobalHQ = doc.splitTextToSize(GlobalHQText, 40);
            doc.text(x2, y7+10, GlobalHQ);

            let y8 = y7 + 20;
            let c8 = 0;
            if (GlobalHQ != '') {
                GlobalHQ.forEach(linetxt => {
                    c8++;
                    if (c8 > 1) {
                        y8 = y8 + 2;
                    }
                });
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y8, 'Completed Strategies :');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var completedStrategies = (this.strategyDataCompleted) ?  this.strategyDataCompleted.length.toString() : '0';
        
            doc.text(x1, y8, completedStrategies);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y8, 'D Number :');
    
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var dNumber = (this.dNumber) ?  this.dNumber : '';
        
            doc.text(x2, y8, dNumber);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);

            let y9 = y8+10;
            doc.text(13, y9, 'Account Plan Type: ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var typeText = (typeof (this.accountPlanType) != 'undefined') ? this.accountPlanType : '';
            var accountPlanType = doc.splitTextToSize(typeText, 70);
            doc.text(x1, y9, accountPlanType);

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(175, y9, 'Buying Centre Id ');

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var buyingCentreId = (typeof (this.buyingCentreId) != 'undefined') ? this.buyingCentreId : '';
            doc.text(x2, y9, buyingCentreId);

            let y26 = y9+10;
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y26, 'Business Defined Attribute :');
    
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);

            var BDAText = (typeof (this.BDA) != 'undefined') ? this.BDA : '';
            var BDA = doc.splitTextToSize(BDAText, 190);
            doc.text(x1, y26, BDA);
            let c13 = 0;
            if (BDA != '') {
                BDA.forEach(linetxt => {
                    c13++;
                    if (c13 > 1) {
                        y26 = y26 + 4;
                    }
                 });
            }

            y9 = y26+15;

            //if (y9 >= 185) {
                doc.addPage();
                y9 = 15;
            //}

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(15);

            doc.setFillColor(242, 242, 242);
            doc.rect(10, y9, 280, 8, 'F');
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(128, y9+5.5, 'Customer Profile');

            let y10 = y9+5.5+9.5;
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y10, "Client's Strategy : ");

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var ClientStrategyText = (typeof (this.ClientStrategy) != 'undefined') ? this.ClientStrategy : '';
            var ClientStrategy = doc.splitTextToSize(ClientStrategyText, 220);
            let y11 = y10;
            let cord = y11 - 5;
            let count = 0;
            if (ClientStrategy != '') {
                ClientStrategy.forEach(linetxt => {
                    count++;
                    if (count > 1) {
                        cord = cord + 4;
                        if (cord >= 190) {
                           /* doc.setDrawColor(221, 219, 218)
                            doc.setLineWidth(0.3)
                            doc.line(151, 23, 151, 200);*/
                            doc.addPage();
                            cord = 15;
                        }
                    }
                    else if (count <= 1) {
                        cord = y11;
                    }
                    doc.text(x1, cord, linetxt);
                });
            }

            y11 = cord + 10;
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y11, 'Our Current ');
            doc.text(13, y11 + 4, 'Situation & Outlook : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var currentSituationText = (typeof (this.CurrentSituation) != 'undefined') ? this.CurrentSituation : '';
            var currentSituation = doc.splitTextToSize(currentSituationText, 220);

            //doc.text(X5, Y6, RelationHistory);
            let pageAdded = false;
            let cordY = y11 - 5;
            let count4 = 0;
            if (currentSituation != '') {
                currentSituation.forEach(linetxt => {
                    count4++;
                    if (count4 > 1) {
                        cordY = cordY + 4;
                        if (cordY >= 190) {
                           /* doc.setDrawColor(221, 219, 218)
                            doc.setLineWidth(0.3)
                            doc.line(151, 23, 151, 200);*/
                            doc.addPage();
                            cordY = 15;
                            pageAdded = true;

                        }
                    }
                    else if (count4 <= 1) {
                        cordY = y11;
                    }
                    doc.text(x1, cordY, linetxt);
                });
            }

            let y12;

            // if (cordY == y11) {
            //     cordY = 10;
            // }

            if (cordY >= 185) {
                doc.addPage();
                y12 = 15;
            }
            else {
                y12 = cordY + 10 + 8;
            }
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y12, 'Risk & Exposure: ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var riskExposureText = (typeof (this.RiskExposure) != 'undefined') ? this.RiskExposure : '';
            var riskExposure = doc.splitTextToSize(riskExposureText, 220);

            //doc.text(X5, Y6, RelationHistory);
            pageAdded = false;
            cordY = y12;
            let count5 = 0;
            if (riskExposure != '') {
                riskExposure.forEach(linetxt => {
                    count5++;
                    if (count5 > 1) {
                        cordY = cordY + 4;
                        if (cordY >= 200) {
                           /* doc.setDrawColor(221, 219, 218)
                            doc.setLineWidth(0.3)
                            doc.line(151, 23, 151, 200);*/
                            doc.addPage();
                            cordY = 15;
                            pageAdded = true;

                        }
                    }
                    else if (count5 <= 1) {
                        cordY = y12;
                    }
                    doc.text(x1, cordY, linetxt);
                });
            }

            let y13;

            // if (cordY == y12) {
            //     cordY = 10;
            // }

            if (cordY >= 185) {
                doc.addPage();
                y13 = 15;
            }
            else {
                y13 = cordY + 10;
            }
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(13, y13, 'Relationship History: ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var relationshipHistoryText = (typeof (this.RelationHistory) != 'undefined') ? this.RelationHistory : '';
            var relationshipHistory = doc.splitTextToSize(relationshipHistoryText, 220);

            //doc.text(X5, Y6, RelationHistory);
            pageAdded = false;
            cordY = y13;
            let count6 = 0;
            if (relationshipHistory != '') {
                relationshipHistory.forEach(linetxt => {
                    count6++;
                    if (count6 > 1) {
                        cordY = cordY + 4;
                        if (cordY >= 200) {
                           /* doc.setDrawColor(221, 219, 218)
                            doc.setLineWidth(0.3)
                            doc.line(151, 23, 151, 200);*/
                            doc.addPage();
                            cordY = 15;
                            pageAdded = true;

                        }
                    }
                    else if (count6 <= 1) {
                        cordY = y13;
                    }
                    doc.text(x1, cordY, linetxt);
                });
            }

            let y14;

            // if (cordY == y13) {
            //     cordY = 10;
            // }

            if (cordY >= 170) {
                doc.addPage();
                y14 = 15;
            }
            else {
                y14 = cordY + 10;
            }

            doc.setFillColor(242, 242, 242);
            doc.rect(10, y14, 280, 8, 'F');
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(128, y14+5.5, 'Business Description');

            let y15 = y14+5.5+9.5;

            doc.text(13, y15, 'Overview of Business : ');
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var businessOverviewText = (typeof (this.BusinessOverview) != 'undefined') ? this.BusinessOverview : '';
            var businessOverview = doc.splitTextToSize(businessOverviewText, 220);

            //doc.text(X5, Y6, RelationHistory);
            pageAdded = false;
            cordY = y15;
            let count7 = 0;
            if (businessOverview != '') {
                businessOverview.forEach(linetxt => {
                    count7++;
                    if (count7 > 1) {
                        cordY = cordY + 4;
                        if (cordY >= 200) {
                           /* doc.setDrawColor(221, 219, 218)
                            doc.setLineWidth(0.3)
                            doc.line(151, 23, 151, 200);*/
                            doc.addPage();
                            cordY = 15;
                            pageAdded = true;

                        }
                    }
                    else if (count7 <= 1) {
                        cordY = y15;
                    }
                    doc.text(x1, cordY, linetxt);
                });
            }

            let y16;

            // if (cordY == y15) {
            //     cordY = 10;
            // }

            if (cordY >= 170) {
                doc.addPage();
                y16 = 15;
            }
            else {
                y16 = cordY + 10;
            }

            doc.setFillColor(242, 242, 242);
            doc.rect(10, y16, 280, 8, 'F');
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(128, y16+5.5, 'Salesforce Overview');

            let y17 = y16+5.5+9.5;
            x1 = x1 + 50;
            x2 = x2 + 30;
            doc.setFontSize(10);
            doc.text(23, y17, 'Contacts at this Account : ');
           

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var ContactsText = (typeof (this.Contacts) != 'undefined') ? this.Contacts.toString() : '';
            doc.text(x1, y17, ContactsText);
           

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('Contacts Created Last 12 mths : ', 155, y17);
            let X9 = 155 + Math.ceil(doc.getTextWidth('Contacts Created Last 12 mths : '));

           

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var Contacts12MonthText = (typeof (this.Contacts12Month) != 'undefined') ? this.Contacts12Month.toString() : '';
            doc.text(x2, y17, Contacts12MonthText);

            let cordY3 = y17 + 5;
            if (cordY3 >= 170) {
                doc.addPage();
                cordY3 = 15;
            }
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('Open Opportunities : ', 23, cordY3);
            let X10 = 13 + Math.ceil(doc.getTextWidth('Open Opportunities : '));


            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var Opportunities = (typeof (this.Opportunities) != 'undefined') ? this.Opportunities.toString() : '';
            doc.text(x1, cordY3, Opportunities);


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('Open Opportunity Value(USD) : ', 155, cordY3);
            let X11 = 155 + Math.ceil(doc.getTextWidth('Open Opportunity Value(USD) : '));


            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var OppValue = (typeof (this.OppValue) != 'undefined') ? this.OppValue.toString() : '';
            doc.text(x2, cordY3, OppValue);

            let cordY4 = cordY3 + 5;
            if (cordY4 >= 170) {
                doc.addPage();
                cordY4 = 15;
            }


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('Contacts Created since last review : ', 23, cordY4);
            let X17 = 13 + Math.ceil(doc.getTextWidth('Contacts Created since last review : '));


            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var ContactBeforeReview = (typeof (this.ContactBeforeReview) != 'undefined') ? this.ContactBeforeReview.toString() : '';
            doc.text(x1, cordY4, ContactBeforeReview);


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('Opportunities Created since last Review : ', 155, cordY4);
            let X18 = 155 + Math.ceil(doc.getTextWidth('Opportunities Created since last Review : '));


            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var OppBeforeReview = (typeof (this.OppBeforeReview) != 'undefined') ? this.OppBeforeReview.toString() : '';
            doc.text(x2, cordY4, OppBeforeReview);


            let cordY5 = cordY4 + 5;
            if (cordY5 >= 170) {
                doc.addPage();
                cordY5 = 15;
            }

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('Open Support Cases : ', 23, cordY5);
            let X12 = 13 + Math.ceil(doc.getTextWidth('Open Support Cases : '));


            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var Cases = (typeof (this.Cases) != 'undefined') ? this.Cases.toString() : '';
            doc.text(x1, cordY5, Cases);


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text('All Cases Last 12 mths : ', 155, cordY5);
            let X13 = 155 + Math.ceil(doc.getTextWidth('All Cases Last 12 mths : '));


            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            var Cases12Months = (typeof (this.Cases12Months) != 'undefined') ? this.Cases12Months.toString() : '';
            doc.text(x2, cordY5, Cases12Months);

            let y18 = cordY5 + 10;
            if (y18+10 >= 160) {
                doc.addPage();
                y18 = 15;
            }

            doc.setFillColor(242, 242, 242);
            doc.rect(10, y18, 280, 8, 'F');
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(118, y18+5.5, 'Strategy & Goals (In Progress)');

            let y19 = y18 + 15;

            if(this.strategyDataOpen.length>0){
                let count =1;
                this.strategyDataOpen.forEach(element => {
                    if (y19+10 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
    
                    doc.setFillColor(242, 242, 242);
                    let nameLength = 9 + Math.ceil(doc.getTextWidth(element.strategyName));
                    doc.rect(10, y19, 280, 8, 'F');
                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text(11, y19+5, 'Strategy '+count+' : '+element.strategyName);

                    y19 = y19 + 15;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Short / Long Term: ', 11, y19);
                    let X1 = 13 + Math.ceil(doc.getTextWidth('Short / Long Term: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var term = (typeof (element.term) != 'undefined') ? element.term : '';
                    doc.text(X1, y19, term);


                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Estimated Completion Date: ', 165, y19);
                    let X2 = 167 + Math.ceil(doc.getTextWidth('Estimated Completion Date: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var estimatedCompletionDate = (typeof (element.estimatedCompletionDate) != 'undefined') ? element.estimatedCompletionDate : '';
                    doc.text(X2, y19, estimatedCompletionDate);

                    y19 = y19 + 5;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Key Contact Sponsor: ', 11, y19);
                    X1 = 13 + Math.ceil(doc.getTextWidth('Key Contact Sponsor: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var keyContactSponser = (typeof (element.keyContactSponser) != 'undefined') ? element.keyContactSponser : '';
                    doc.text(X1, y19, keyContactSponser);


                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Strategy Type: ', 165, y19);
                    X2 = 167 + Math.ceil(doc.getTextWidth('Strategy Type: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var type = (typeof (element.type) != 'undefined') ? element.type : '';
                    doc.text(X2, y19, type);

                    y19 = y19 + 5;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Open Activities: ', 11, y19);
                    X1 = 13 + Math.ceil(doc.getTextWidth('Open Activities: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var openActivities = (typeof (element.openActivities) != 'undefined') ? element.openActivities.toString() : '';
                    doc.text(X1, y19, openActivities);


                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Completed Activities: ', 165, y19);
                    X2 = 167 + Math.ceil(doc.getTextWidth('Completed Activities: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var closedActivities = (typeof (element.closedActivities) != 'undefined') ? element.closedActivities.toString() : '';
                    doc.text(X2, y19, closedActivities);

                    y19 = y19 + 5;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text('Solution / Product Area: ', 11, y19);
                    X1 = 13 + Math.ceil(doc.getTextWidth('Solution / Product Area: '));


                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var solution = (typeof (element.solution) != 'undefined') ? element.solution : '';
                    doc.text(X1, y19, solution);

                    y19 = y19 + 10;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text(11, y19, 'Business Problem Addressed');
                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var businessProblemAddressedText = (typeof (element.businessProblemAddressed) != 'undefined') ? element.businessProblemAddressed : '';
                    var businessProblemAddressed = doc.splitTextToSize(businessProblemAddressedText, 220);

                    //doc.text(X5, Y6, RelationHistory);
                    pageAdded = false;
                    let cord = y19+4;
                    let count1 = 0;
                    if (businessProblemAddressed != '') {
                        businessProblemAddressed.forEach(linetxt => {
                            count1++;
                            if (count1 > 1) {
                                cord = cord + 4;
                                if (cord >= 185) {
                                /* doc.setDrawColor(221, 219, 218)
                                    doc.setLineWidth(0.3)
                                    doc.line(151, 23, 151, 200);*/
                                    doc.addPage();
                                    cord = 15;
                                    pageAdded = true;

                                }
                            }
                            else if (count7 <= 1) {
                                y19 = y19+4;
                                cord = y19;
                            }
                            doc.text(11, cord, linetxt);
                        });
                    }

                    y19 = cord + 10;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
                    cord = y19+4;
                    count1 = 0;

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text(11, y19, 'Key Milestones');
                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var keyMilestonesText = (typeof (element.keyMilestones) != 'undefined') ? element.keyMilestones : '';
                    var keyMilestones = doc.splitTextToSize(keyMilestonesText, 220);
                    if (keyMilestones != '') {
                        keyMilestones.forEach(linetxt => {
                            count1++;
                            if (count1 > 1) {
                                cord = cord + 4;
                                if (cord >= 185) {
                                /* doc.setDrawColor(221, 219, 218)
                                    doc.setLineWidth(0.3)
                                    doc.line(151, 23, 151, 200);*/
                                    doc.addPage();
                                    cord = 15;
                                    pageAdded = true;

                                }
                            }
                            else if (count7 <= 1) {
                                y19 = y19+4;
                                cord = y19;
                            }
                            doc.text(11, cord, linetxt);
                        });
                    }

                    y19 = cord + 10;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
                    cord = y19+4;
                    count1 = 0;

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text(11, y19, 'Resources Required');
                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var resourcesRequiredText = (typeof (element.resourcesRequired) != 'undefined') ? element.resourcesRequired : '';
                    var resourcesRequired = doc.splitTextToSize(resourcesRequiredText, 220);
                    if (resourcesRequired != '') {
                        resourcesRequired.forEach(linetxt => {
                            count1++;
                            if (count1 > 1) {
                                cord = cord + 4;
                                if (cord >= 185) {
                                /* doc.setDrawColor(221, 219, 218)
                                    doc.setLineWidth(0.3)
                                    doc.line(151, 23, 151, 200);*/
                                    doc.addPage();
                                    cord = 15;
                                    pageAdded = true;

                                }
                            }
                            else if (count7 <= 1) {
                                y19 = y19+4;
                                cord = y19;
                            }
                            doc.text(11, cord, linetxt);
                        });
                    }

                    y19 = cord + 10;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
                    cord = y19+4;
                    count1 = 0;

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text(11, y19, 'Solution / Goal');
                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var solutionGoalText = (typeof (element.solutionGoal) != 'undefined') ? element.solutionGoal : '';
                    var solutionGoal = doc.splitTextToSize(solutionGoalText, 220);
                    if (solutionGoal != '') {
                        solutionGoal.forEach(linetxt => {
                            count1++;
                            if (count1 > 1) {
                                cord = cord + 4;
                                if (cord >= 185) {
                                /* doc.setDrawColor(221, 219, 218)
                                    doc.setLineWidth(0.3)
                                    doc.line(151, 23, 151, 200);*/
                                    doc.addPage();
                                    cord = 15;
                                    pageAdded = true;

                                }
                            }
                            else if (count7 <= 1) {
                                y19 = y19+4;
                                cord = y19;
                            }
                            doc.text(11, cord, linetxt);
                        });
                    }

                    y19 = cord + 10;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
                    cord = y19+4;
                    count1 = 0;

                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(10);
                    doc.text(11, y19, 'Comments & Next Steps');
                    doc.setFont('helvetica', 'normal');
                    doc.setFontSize(10);
                    var nextStepsText = (typeof (element.nextSteps) != 'undefined') ? element.nextSteps : '';
                    var nextSteps = doc.splitTextToSize(nextStepsText, 220);
                    if (nextSteps != '') {
                        nextSteps.forEach(linetxt => {
                            count1++;
                            if (count1 > 1) {
                                cord = cord + 4;
                                if (cord >= 185) {
                                /* doc.setDrawColor(221, 219, 218)
                                    doc.setLineWidth(0.3)
                                    doc.line(151, 23, 151, 200);*/
                                    doc.addPage();
                                    cord = 15;
                                    pageAdded = true;

                                }
                            }
                            else if (count7 <= 1) {
                                y19 = y19+4;
                                cord = y19;
                            }
                            doc.text(11, cord, linetxt);
                        });
                    }

                    y19 = y19 +20;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(12);
                    doc.text(11, y19, 'OPPORTUNITY LINKED TO STRATEGY:');

                    
                    y19 = y19 + 10;

                    //let Y21 = Y20 + 15.5;

                    if(element.oppList.currentPipeline.length>0){
                        doc.setFont('helvetica', 'bold');
                        doc.setFontSize(10);
                        doc.text(11, y19, 'Total Sales Value :');
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        let x11 = 10+ Math.ceil(doc.getTextWidth('Total Sales Value :  '));
                        doc.text(x11, y19, element.oppList.totalSalesValue);


                        y19 = y19 + 5.5;
                        if (y19 >= 160) {
                            doc.addPage();
                            y19 = 10;
                        
                        }
            
                        const currentOppCol = ["Name", "Opp. Nickname","Account Number","Stage", "Est. Booking Value", "Est. Close Date", "Contract Length", "Renewal Start Date","Next Step(s)"];
                        var currentOppRows = [];

                        let currentOpptemp = JSON.parse(JSON.stringify(element.oppList.currentPipeline));

                        currentOpptemp.forEach(e => {
                            var currentOppData = [e.opportunityName,e.opportunityNickname,e.dNumber, e.stageName, e.amountWithCurrency, e.closeDate, e.contractLength, e.renewalStartDate,  e.nextStep];
                            currentOppRows.push(currentOppData);

                        });
                    
                        doc.autoTable({
                            headerStyles: {
                                fillColor: [242, 242, 242],
                                textColor: [0, 0, 0],
                                halign: 'center',
                                fontStyle: 'bold',
                                fontSize: 10
                            },

                            bodyStyles: {
                                halign: 'center',
                                fontSize: 10
                            },
                        //  columnStyles: { 0: { halign: 'left' } },
                        columnStyles: {
                            8: {cellWidth: 40 }               
                        },
                            margin: { top: 10, left: 10, right: 7 },
                            columns: currentOppCol,
                            body: currentOppRows,
                            startY: y19,


                        })

                        y19 = doc.previousAutoTable.finalY;
                    }else{
                        y19 = y19+2;
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        doc.text(11, y19, 'There are no Opportunities linked to this specific Strategy');
                    }

                    y19 = y19 +20;
                    if (y19 >= 185) {
                        doc.addPage();
                        y19 = 15;
                    }
                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(12);
                    doc.text(11, y19, 'WHITESPACE LINKED TO STRATEGY:');

                    
                    y19 = y19 + 10;

                    //let Y21 = Y20 + 15.5;

                    if(element.whitespaceList.whiteSpaceOppList.length>0){
                        doc.setFont('helvetica', 'bold');
                        doc.setFontSize(10);
                        doc.text(11, y19, 'Total Potential Value: ');
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        let x11 = 15+ Math.ceil(doc.getTextWidth('Total Potential Value: '));
                        doc.text(x11, y19, element.whitespaceList.totalPotentialValue);


                        y19 = y19 + 5.5;
                        if (y19 >= 160) {
                            doc.addPage();
                            y19 = 10;
                        
                        }
            
                        const WhiteSpaceCol = ["Status", "Who do you need to speak to?", "Potential Value",  "Next Step(s)", "Solution", "Help Needed"];
                        var whiteSpaceRows = [];
                    
                        let whiteSpacetemp = JSON.parse(JSON.stringify(element.whitespaceList.whiteSpaceOppList));

                        whiteSpacetemp.forEach(e => {
                            var whiteSpaceData = [e.status, e.contactName, e.potentialValueWithCurrency,  e.nextStep, e.solution, e.helpNeeded];
                            whiteSpaceRows.push(whiteSpaceData);

                        });
                

                    doc.autoTable({
                            headerStyles: {
                                fillColor: [242, 242, 242],
                                textColor: [0, 0, 0],
                                halign: 'center',
                                fontStyle: 'bold',
                                fontSize: 10
                            },

                            bodyStyles: {
                                halign: 'center',
                                fontSize: 10
                            },
                        //  columnStyles: { 0: { halign: 'left' } },
                        columnStyles: {
                            0: {cellWidth: 40 } ,
                            2: {cellWidth: 40 } ,
                            4: {cellWidth: 40 } ,
                            5: {cellWidth: 50 } ,
                            6: {cellWidth: 50 } 
                        
                        },
                            margin: { top: 10, left: 10, right: 7},
                            columns: WhiteSpaceCol,
                            body: whiteSpaceRows,
                            startY: y19,

                        })

                        y19 = doc.previousAutoTable.finalY;
                    }else{
                        y19 = y19+2;
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        doc.text(11, y19, 'There are no Whitespace Potential Opportunities linked to this specific strategy');
                    }

                    y19 = y19 +20;
                    if (y19 >= 180) {
                        doc.addPage();
                        y19 = 15;
                    }
                    doc.setFont('helvetica', 'bold');
                    doc.setFontSize(12);
                    doc.text(11, y19, 'OPEN ACTIVITIES FOR STRATEGY');

                    
                    y19 = y19 + 5;

                    //let Y21 = Y20 + 15.5;

                    if(element.activityList.length>0){
                        
                        y19 = y19 + 5.5;
                        if (y19 >= 190) {
                            doc.addPage();
                            y19 = 10;
                        
                        }
            
                        const activityCol = ["Type","Subject", "Due Date", "Name",  "Status", "Assigned To"];
                        var activityRows = [];
                    
                        let activitytemp = JSON.parse(JSON.stringify(element.activityList));

                        activitytemp.forEach(e => {
                            var activityData = [e.ActivityType, e.ActivityName, e.DueDate,  e.WhoId, e.Status, e.Owner];
                            activityRows.push(activityData);

                        });
                

                    doc.autoTable({
                            headerStyles: {
                                fillColor: [242, 242, 242],
                                textColor: [0, 0, 0],
                                halign: 'center',
                                fontStyle: 'bold',
                                fontSize: 10
                            },

                            bodyStyles: {
                                halign: 'center',
                                fontSize: 10
                            },
                        //  columnStyles: { 0: { halign: 'left' } },
                        columnStyles: {
                            0: {cellWidth: 40 } ,
                            2: {cellWidth: 40 } ,
                            4: {cellWidth: 40 } ,
                            5: {cellWidth: 50 } ,
                            6: {cellWidth: 50 } 
                        
                        },
                            margin: { top: 10, left: 10, right: 7},
                            columns: activityCol,
                            body: activityRows,
                            startY: y19,

                        })

                        y19 = doc.previousAutoTable.finalY;
                    }else{
                        y19 = y19+7;
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        doc.text(11, y19, 'There are no open activities pending for this specific Strategy');
                    }
                    
                    //doc.setFillColor(0, 0, 0);
                    //doc.rect(10, y19+10, 280, 2, 'F');

                 y19=y19+15;
                 /*   if (y19 >= 190) {
                        doc.addPage();
                        y19 = 10;
                    
                    }

                    doc.setLineDash([5,5], 10);
                    doc.setLineWidth(1);
                    doc.line(5, y19, 293, y19);
                    y19 = y19+10;*/
                    count++;
                });

            }else{
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                doc.text(11, y19, 'No Open Strategies for the Account Plan');
            }

            let y20 = y19 +10;
            if (y20 +20 >= 185) {
                doc.addPage();
                y20 = 15;
            }
            doc.setFillColor(242, 242, 242);
            doc.rect(10, y20, 280, 8, 'F');


            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(118, y20 + 5.5, 'Strategy & Goals (Completed)');

            let y21 = y20 + 10.5;
   

            if(this.strategyDataCompleted.length>0){
                const strategyCol = ["Name", "Est. Completion Date", "Short / Long Term", "Key Contact Sponsor", "Strategy Type", "Strategy Status", "Solution / Product Area"];
                var strategyrows = [];

                let temp = JSON.parse(JSON.stringify(this.strategyDataCompleted));

                temp.forEach(e => {
                    var StrategyData = [e.strategyName, e.estimatedCompletionDate, e.term, e.keyContactSponser, e.type, e.status, e.solution];
                    strategyrows.push(StrategyData);

                });
            

                doc.autoTable({
                    headerStyles: {
                        fillColor: [242, 242, 242],
                        textColor: [0, 0, 0],
                        halign: 'center',
                        fontStyle: 'bold',
                        fontSize: 10
                    },

                    bodyStyles: {
                        halign: 'center',
                        fontSize: 10
                    },
                //  columnStyles: { 0: { halign: 'left' } },
                columnStyles: {
                    0: {cellWidth: 40 } ,
                
                },
                    margin: { top: 10, left: 10, right: 7 },
                    columns: strategyCol,
                    body: strategyrows,
                    startY: y21,


                })
            
                y21 = doc.previousAutoTable.finalY;
            }else{
                y21 = y21 + 10;
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                doc.text(11, y21, 'No completed strategies for the respective account plan (Last 1 year)');
            }
            
            y21 = y21 + 15;
                        if (y21 >= 185) {
                            doc.addPage();
                            y21 = 10;
                        
                        }

            doc.setFillColor(242, 242, 242);
            doc.rect(10, y21, 280, 8, 'F');



            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(100, y21 + 5.5, 'Current Pipeline (Not linked with any strategy)');

            
            let y22 = y21 + 15.5;

            //let Y21 = Y20 + 15.5;
            let y25;
            if(this.currentOppData.length>0){
                doc.setFont('helvetica', 'bold');
                doc.setFontSize(10);
                doc.text(11, y22, 'Total Sales Value :');
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                let x11 = 15+ Math.ceil(doc.getTextWidth('Total Sales Value :  '));
                doc.text(x11, y22, this.totalSales);


                let y23 = y22 + 5.5;
                let y24;
                if (y23 >= 160) {
                    doc.addPage();
                    y24 = 10;
                
                }
                else {
                    y24 = y23;
                }
    
    

                const currentOppCol = ["Name","Opp. Nickname","Account Number","Stage", "Est. Booking Value", "Est. Close Date", "Contract Length", "Renewal Start Date",  "Next Step(s)"];
                var currentOppRows = [];

            

                let currentOpptemp = JSON.parse(JSON.stringify(this.currentOppData));



                currentOpptemp.forEach(e => {
                    var currentOppData = [e.opportunityName,e.opportunityNickname,e.dNumber, e.stageName, e.amountWithCurrency, e.closeDate, e.contractLength, e.renewalStartDate,  e.nextStep, e.solution];
                    currentOppRows.push(currentOppData);

                });
            

                doc.autoTable({
                    headerStyles: {
                        fillColor: [242, 242, 242],
                        textColor: [0, 0, 0],
                        halign: 'center',
                        fontStyle: 'bold',
                        fontSize: 10
                    },

                    bodyStyles: {
                        halign: 'center',
                        fontSize: 10
                    },
                //  columnStyles: { 0: { halign: 'left' } },
                columnStyles: {
                    8: {cellWidth: 40 }               
                },
                    margin: { top: 10, left: 10, right: 7 },
                    columns: currentOppCol,
                    body: currentOppRows,
                    startY: y24,


                })
                y25 = doc.previousAutoTable.finalY;
            }else{
                y22 = y22+10;
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                doc.text(11, y22, 'No Other Opportunities linked to the respective account plan');
                y25 = y22;
            }
            

            y25 = y25+15;
            if (y25 >= 185) {
                doc.addPage();
                y25 = 10;     
                }

            doc.setFillColor(242, 242, 242);
            doc.rect(10, y25, 280, 8, 'F');



            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text(127, y25 + 5.5, 'Contract Details');


            y25 = y25 + 10.5;


            if(this.ContractList.length>0){
                const contractDataCol = ["Anual Contract Value (USD)","D Number" ,"Contract Type", "Contract End Date", "Contract Length", "Renewal Date", "Solution", "Usage"];
                var contractDataRows = [];
    
    
                let contractDatatemp = JSON.parse(JSON.stringify(this.ContractList));
    
    
    
                contractDatatemp.forEach(e => {
                    var contractData = [e.totalAmmount, e.DNumber,e.contractType, e.contractEndDate, e.contractLength, e.renewalStartDate, e.oliSolution, e.oliQuantity];
                    contractDataRows.push(contractData);
    
                });
    
    
                doc.autoTable({
                    headerStyles: {
                        fillColor: [242, 242, 242],
                        textColor: [0, 0, 0],
                        halign: 'center',
                        fontStyle: 'bold',
                        fontSize: 10
                    },
    
                    bodyStyles: {
                        halign: 'center',
                        fontSize: 10
                    },
                    columnStyles: { 0: { halign: 'center' } },
                    margin: { top: 10, left: 10, right: 7 },
                    columns: contractDataCol,
                    body: contractDataRows,
                    startY: y25,
    
    
                })
            }else{
                y25 = y25 + 10;
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                doc.text(11, y25, 'No Contracts linked to the respective account plan');
            }


    //         let y8 = y7 + 10;

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y8, 'Date of Last Plan Review : ');

    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var LastReview = (typeof (this.LastReview) != 'undefined') ? this.LastAccountReview : '';
    //         doc.text(x1, y8, LastReview);

    //         let y9 = y8 + 10;

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y9, 'Date for Next Plan Review :');

    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);

           
           
    //         var LastAccountReview = (typeof (this.LastAccountReview) != 'undefined') ? this.LastAccountReview : '';
    //         doc.text(x1, y9, LastAccountReview);     
            
    //         let y10 = y9+10 ;

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y10, 'Website : ');
    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
           
    //         var WebsiteText = (typeof (this.Website) != 'undefined') ? this.Website : '';
    //         var Website = doc.splitTextToSize(WebsiteText, 85);
    //         doc.text(x1, y10, Website);

    //         let y11 = y10 + 10;
    //         let c11 = 0;
    //         if (Website != '') {
    //             Website.forEach(linetxt => {
    //                 c11++;
    //                 if (c11 > 1) {
    //                     y11 = y11 + 4;
    //                 }
    //             });
    //         }

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y11, 'Industry : ');

    //         doc.setFont('helvetica', 'normal');

    //         doc.setFontSize(10);
            
    //         var IndustryText = (typeof (this.Industry) != 'undefined') ? this.Industry : '';
    //         var Industry = doc.splitTextToSize(IndustryText, 85);
    //         doc.text(x1, y11, Industry);

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y11 + 10, 'Fiscal Year End : ');

    //         doc.setFont('helvetica', 'normal');

    //         doc.setFontSize(10);

    //         var FiscalYearText = (typeof (this.FiscalYear) != 'undefined') ? this.FiscalYear : '';
    //         var FiscalYear = doc.splitTextToSize(FiscalYearText, 85);
    //         doc.text(x1, y11 + 10, FiscalYear);

    //         let y12 = y11 + 20;
    //         let c12 = 0;
    //         if (FiscalYear != '') {
    //             FiscalYear.forEach(linetxt => {
    //                 c12++;
    //                 if (c12 > 1) {
    //                     y12 = y12 + 4;
    //                 }
    //             });
    //         }



    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y12, 'Global #FTE : ');

    //         doc.setFont('helvetica', 'normal');


    //         doc.setFontSize(10);
    //         var GlobalFTEText = (typeof (this.GlobalFTE) != 'undefined') ? this.GlobalFTE.toString() : '';
    //         doc.text(x1, y12, GlobalFTEText);

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, y12 + 10, 'Regional #FTE : ');

    //         doc.setFont('helvetica', 'normal');

    //         doc.setFontSize(10);
            
    //         var RegionalFTEText = (typeof (this.RegionalFTE) != 'undefined') ? this.RegionalFTE.toString() : '';
    //         doc.text(x1, y12 + 10, RegionalFTEText);

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);

    //         doc.setDrawColor(221, 219, 218)
    //         doc.setLineWidth(0.3)
    //         doc.line(151, 23, 151, 200);

    //         let Y3 = 20.5 + 9.5;

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(155, Y3, "Client's Strategy : ");

    //         let X5 = 155 + Math.ceil(doc.getTextWidth("Relationship History :  "));

    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var ClientStrategyText = (typeof (this.ClientStrategy) != 'undefined') ? this.ClientStrategy : '';
    //         var ClientStrategy = doc.splitTextToSize(ClientStrategyText, 95);

    //         doc.text(X5, Y3, ClientStrategy);


    //         let Y4 = Y3;
    //         let count1 = 0;
    //         if (ClientStrategy != '') {
    //             ClientStrategy.forEach(linetxt => {
    //                 count1++;
    //                 if (count1 > 1) {
    //                     Y4 = Y4 + 5;

    //                 }
    //                 else if (count1 <= 1) {
    //                     Y4 = Y3 + 10;
    //                 }
    //             });
    //         }
    //         if (Y4 == Y3) {
    //             Y4 = Y3 + 10;
    //         }
    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(155, Y4, 'Our Current ');
    //         doc.text(155, Y4 + 4, 'Situation & Outlook : ');

    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var CurrentSituationText = (typeof (this.CurrentSituation) != 'undefined') ? this.CurrentSituation : '';
    //         var CurrentSituation = doc.splitTextToSize(CurrentSituationText, 95);

    //         doc.text(X5, Y4, CurrentSituation);
    //         let Y5 = Y4;
    //         let count2 = 0;
    //         if (CurrentSituation != '') {
    //             CurrentSituation.forEach(linetxt => {
    //                 count2++;
    //                 if (count2 > 1) {
    //                     Y5 = Y5 + 4.5;

    //                 }
    //                 else if (count2 <= 1) {
    //                     Y5 = Y4 + 14;
    //                 }
    //             });
    //         }
    //         if (Y5 == Y4) {
    //             Y5 = Y4 + 14;
    //         }

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(155, Y5, 'Risk & Exposure : ');
         


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var RiskExposureText = (typeof (this.RiskExposure) != 'undefined') ? this.RiskExposure : '';
    //         var RiskExposure = doc.splitTextToSize(RiskExposureText, 95);

    //         doc.text(X5, Y5, RiskExposure);

    //         let Y6 = Y5;
    //         let count3 = 0;
    //         if (RiskExposure != '') {
    //             RiskExposure.forEach(linetxt => {
    //                 count3++;
    //                 if (count3 > 1) {
    //                     Y6 = Y6 + 5;
    //                 }
    //                 else if (count3 <= 1) {
    //                     Y6 = Y5 + 10;
    //                 }
    //             });
    //         }
    //         if (Y6 == Y5) {
    //             Y6 = Y5 + 10;
    //         }

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(155, Y6, 'Relationship History : ');


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var RelationHistoryText = (typeof (this.RelationHistory) != 'undefined') ? this.RelationHistory : '';
    //         var RelationHistory = doc.splitTextToSize(RelationHistoryText, 95);

    //         //doc.text(X5, Y6, RelationHistory);

    //         let pageAdded = false;
    //         let cordY = Y6 - 5;
    //         let count4 = 0;
    //         if (RelationHistory != '') {
    //             RelationHistory.forEach(linetxt => {
    //                 count4++;
    //                 if (count4 > 1) {
    //                     cordY = cordY + 4;
    //                     if (cordY >= 200) {
    //                        /* doc.setDrawColor(221, 219, 218)
    //                         doc.setLineWidth(0.3)
    //                         doc.line(151, 23, 151, 200);*/
    //                         doc.addPage();
    //                         cordY = 15;
    //                         pageAdded = true;

    //                     }
    //                 }
    //                 else if (count4 <= 1) {
    //                     cordY = Y6;
    //                 }
    //                 doc.text(X5, cordY, linetxt);
    //             });
    //         }


    //         let Y9;

    //         if (cordY == Y6) {
    //             cordY = 10;
    //         }



    //         if (cordY >= 170) {
    //             doc.addPage();
    //             Y9 = 15;
    //         }
    //         else {
    //             Y9 = cordY + 10;
    //         }


    //         let y22 ;
    //         if (pageAdded == true) {
    //             doc.setFont('helvetica', 'bold');
    //             doc.setFontSize(10);
    //             doc.text(13, 15, 'Business Defined Attribute :');
    
    //             doc.setFont('helvetica', 'normal');
    //             doc.setFontSize(10);

    //            var BDAText = (typeof (this.BDA) != 'undefined') ? this.BDA : '';
    //             var BDA = doc.splitTextToSize(BDAText, 85);
    //             doc.text(x1, 15, BDA);
    //             y22=25;
    //             let c13 = 0;
    //             if (BDA != '') {
    //                 BDA.forEach(linetxt => {
    //                     c13++;
    //                     if (c13 > 1) {
    //                         y22 = y22 + 4;
    //                     }
    //                 });
    //             }
    
    //         }

    //         else if(pageAdded != true){
    //             doc.addPage();
    //             doc.setFont('helvetica', 'bold');
    //             doc.setFontSize(10);
    //             doc.text(13, 15, 'Business Defined Attribute :');
    
    //             doc.setFont('helvetica', 'normal');
    //             doc.setFontSize(10);
    //            var BDAText = (typeof (this.BDA) != 'undefined') ? this.BDA : '';
    //             var BDA = doc.splitTextToSize(BDAText, 85);
    //             doc.text(x1, 15, BDA);
    //             y22=25;
    //             let c13 = 0;
    //             if (BDA != '') {
    //                 BDA.forEach(linetxt => {
    //                     c13++;
    //                     if (c13 > 1) {
    //                         y22 = y22 + 4;
    //                     }
    //                 });
    //             }
    //         }

    //        let Y16;
    //        console.log(this.BDA);
    //        if(this.BDA  = '' || typeof (this.BDA) == 'undefined'){
    //            Y16 = 20;
    //        }
    //        else{
    //         Y16 = y22 + 5;
    //        }
    //         //let Y8 = ycord2+2;
             
    //         let Y10;
           
    //       if (pageAdded == true) {
    //         if(Y16>=Y9){
    //             Y10 = Y16;
    //         }
    //         else{
    //             Y10 = Y9;
    //         }
    //       }
    //       else{
    //         Y10 = Y16;           
    //       }
              
    //      doc.setDrawColor(221, 219, 218)
    //      doc.setLineWidth(0.3)
    //      doc.line(151, 8, 151, Y10);
            
    //      let Y11 = Y10 + 7;
    //         let Y15 = Y10 + 7;
           

    //         let Y12 = Y11; 

    //         if(Y11>=150){
    //             doc.addPage();
    //             Y12=10;
    //         }
    // //let Y32 = Y12 + 8;//Comment this and uncomment below code when business overview is required
    // //SSE-21127(Account Plan Phase 3) 
    //        doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y12, 280, 8, 'F');

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y12 + 5.5, 'Business Description');

    //         let Y30 = Y12 + 17.5;


    //         doc.setFontSize(10);
    //         doc.text(13, Y30, 'Overview of Business : ');
    //         let X26 = 13 + Math.ceil(doc.getTextWidth('Overview of Business :  '));
    //         doc.setFont('helvetica', 'normal');
    //             doc.setFontSize(10);
                
    //             var BusinessOverviewText = (typeof (this.BusinessOverview) != 'undefined') ? this.BusinessOverview : '';
    //             var BusinessOverview = doc.splitTextToSize(BusinessOverviewText, 225);
    //             doc.text(X26, Y30, BusinessOverview);

    //             let Y32= Y30+10;
    //             let c13 = 0;
    //             if (BusinessOverview != '') {
    //                 BusinessOverview.forEach(linetxt => {
    //                     c13++;
    //                     if (c13 > 1) {
    //                         Y32 = Y32 + 4.5;
                           
    //                     }
    //                 });
    //             }
            
                
    //             if (Y32 >= 170) {
    //                 doc.addPage();
    //                 Y32 = 15;
    //             }      
    //     doc.setFillColor(242, 242, 242);
    //     doc.rect(10, Y32, 280, 8, 'F');

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y32 + 5.5, 'Salesforce Overview');

    //         let Y14 = Y32 + 17.5;
          
            

    //         doc.setFontSize(10);
    //         doc.text(13, Y14, 'Contacts at this Account : ');
    //         let X8 = 13 + Math.ceil(doc.getTextWidth('Contacts at this Account : '));
           

    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var ContactsText = (typeof (this.Contacts) != 'undefined') ? this.Contacts.toString() : '';
    //         doc.text(X8, Y14, ContactsText);
           

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('Contacts Created Last 12 mths : ', 155, Y14);
    //         let X9 = 155 + Math.ceil(doc.getTextWidth('Contacts Created Last 12 mths : '));

           

    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var Contacts12MonthText = (typeof (this.Contacts12Month) != 'undefined') ? this.Contacts12Month.toString() : '';
    //         doc.text(X9, Y14, Contacts12MonthText);

    //         let cordY3 = Y14 + 5;
    //         if (cordY3 >= 170) {
    //             doc.addPage();
    //             cordY3 = 15;
    //         }
    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('Open Opportunities : ', 13, cordY3);
    //         let X10 = 13 + Math.ceil(doc.getTextWidth('Open Opportunities : '));


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var Opportunities = (typeof (this.Opportunities) != 'undefined') ? this.Opportunities.toString() : '';
    //         doc.text(X10, cordY3, Opportunities);


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('Open Opportunity Value : ', 155, cordY3);
    //         let X11 = 155 + Math.ceil(doc.getTextWidth('Open Opportunity Value : '));


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var OppValue = (typeof (this.OppValue) != 'undefined') ? this.OppValue.toString() : '';
    //         doc.text(X11, cordY3, OppValue);

    //         let cordY4 = cordY3 + 5;
    //         if (cordY4 >= 170) {
    //             doc.addPage();
    //             cordY4 = 15;
    //         }


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('Contacts Created since last review : ', 13, cordY4);
    //         let X17 = 13 + Math.ceil(doc.getTextWidth('Contacts Created since last review : '));


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var ContactBeforeReview = (typeof (this.ContactBeforeReview) != 'undefined') ? this.ContactBeforeReview.toString() : '';
    //         doc.text(X17, cordY4, ContactBeforeReview);


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('Opportunities Created since last Review : ', 155, cordY4);
    //         let X18 = 155 + Math.ceil(doc.getTextWidth('Opportunities Created since last Review : '));


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var OppBeforeReview = (typeof (this.OppBeforeReview) != 'undefined') ? this.OppBeforeReview.toString() : '';
    //         doc.text(X18, cordY4, OppBeforeReview);


    //         let cordY5 = cordY4 + 5;
    //         if (cordY5 >= 170) {
    //             doc.addPage();
    //             cordY5 = 15;
    //         }

    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('Open Support Cases : ', 13, cordY5);
    //         let X12 = 13 + Math.ceil(doc.getTextWidth('Open Support Cases : '));


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var Cases = (typeof (this.Cases) != 'undefined') ? this.Cases.toString() : '';
    //         doc.text(X12, cordY5, Cases);


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text('All Cases Last 12 mths : ', 155, cordY5);
    //         let X13 = 155 + Math.ceil(doc.getTextWidth('All Cases Last 12 mths : '));


    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         var Cases12Months = (typeof (this.Cases12Months) != 'undefined') ? this.Cases12Months.toString() : '';
    //         doc.text(X13, cordY5, Cases12Months);


    //         let Y13;

    //         let Y18;
    //         let y17 = cordY5 + 10;


    //         if (y17 >= 150) {
    //             doc.addPage();
    //             Y18 = 10;
               

    //         }

    //         else if (y17 < 260) {

    //             // Y18 = Y17 + 15.5;
    //             Y18 = y17;
               
    //         }


    //         doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y18, 280, 8, 'F');


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y18 + 5.5, 'Strategy and Goals');

    //         let Y19 = Y18 + 10.5;
   

    //         const strategyCol = ["Name", "Est. Completion Date", "Short / Long Term", "Key Contact Sponsor", "Strategy Type", "Strategy Status", "Solution / Product Area"];
    //         var strategyrows = [];

           

    //         let temp = JSON.parse(JSON.stringify(this.strategyData));

    //         temp.forEach(e => {
    //             var StrategyData = [e.strategyName, e.estimatedCompletionDate, e.term, e.contactName, e.type, e.status, e.productSolution];
    //             strategyrows.push(StrategyData);

    //         });
           

    //         doc.autoTable({
    //             headerStyles: {
    //                 fillColor: [242, 242, 242],
    //                 textColor: [0, 0, 0],
    //                 halign: 'center',
    //                 fontStyle: 'bold',
    //                 fontSize: 10
    //             },

    //             bodyStyles: {
    //                 halign: 'center',
    //                 fontSize: 10
    //             },
    //           //  columnStyles: { 0: { halign: 'left' } },
    //           columnStyles: {
    //             0: {cellWidth: 40 } ,
              
    //         },
    //             margin: { top: 10, left: 10, right: 7 },
    //             columns: strategyCol,
    //             body: strategyrows,
    //             startY: Y19,


    //         })
          
    //         let Y20 = doc.previousAutoTable.finalY;
         
           
    //         if (Y20 >= 140) {
    //             doc.addPage();
    //             Y20 = 10;
              
    //         }
    //         else {
    //             Y20 = Y20 + 10.5;
    //         }

        
    //         doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y20, 280, 8, 'F');



    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y20 + 5.5, 'White Space Opportunity');

        

    //         let Y21 = Y20 + 15.5;


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, Y21, 'Total Potential Value :');
    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         let x10 = 15+ Math.ceil(doc.getTextWidth('Total Potential Value :  '));
    //         doc.text(x10, Y21, this.totalPotential);

    //         let Y34 = Y21 + 5.5;

    //         let Y37;
         
    //         if (Y34 >= 160) {
    //             doc.addPage();
    //             Y37 = 10;
            
    //         }
    //         else {
                
    //             Y37 = Y34;
    //         }
       
         
    //         const WhiteSpaceCol = ["Strategy", "Status", "Who do you need to speak to?", "Potential Value",  "Next Step(s)", "Solution", "Help Needed"];
    //         var whiteSpaceRows = [];
           
    //         let whiteSpacetemp = JSON.parse(JSON.stringify(this.WhiteSpaceData));

    //         whiteSpacetemp.forEach(e => {
    //             var whiteSpaceData = [e.strategyName,  e.status, e.contactName, e.potentialValueWithCurrency,  e.nextStep, e.solution, e.helpNeeded];
    //             whiteSpaceRows.push(whiteSpaceData);

    //         });
      

    //        doc.autoTable({
    //             headerStyles: {
    //                 fillColor: [242, 242, 242],
    //                 textColor: [0, 0, 0],
    //                 halign: 'center',
    //                 fontStyle: 'bold',
    //                 fontSize: 10
    //             },

    //             bodyStyles: {
    //                 halign: 'center',
    //                 fontSize: 10
    //             },
    //           //  columnStyles: { 0: { halign: 'left' } },
    //           columnStyles: {
    //             0: {cellWidth: 40 } ,
    //             2: {cellWidth: 40 } ,
    //             4: {cellWidth: 40 } ,
    //             5: {cellWidth: 50 } ,
    //             6: {cellWidth: 50 } 
              
    //         },
    //             margin: { top: 10, left: 10, right: 7},
    //             columns: WhiteSpaceCol,
    //             body: whiteSpaceRows,
    //             startY: Y37,


    //         })


    //        let Y22 = doc.previousAutoTable.finalY;
    //         let Y38;
           
        
    //         if (Y22 >= 140) {
    //             doc.addPage();
    //             Y38 = 10;
            
    //         }
    //         else {
    //             Y38 = Y22 + 10.5;
    //         }

    //         //Y38= 100;
         
    //         doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y38, 280, 8, 'F');



    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y38 + 5.5, 'Current Pipeline');

            
    //         let Y23 = Y38 + 15.5;

    //         //let Y21 = Y20 + 15.5;


    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(10);
    //         doc.text(13, Y23, 'Total Sales Value :');
    //         doc.setFont('helvetica', 'normal');
    //         doc.setFontSize(10);
    //         let x11 = 15+ Math.ceil(doc.getTextWidth('Total Sales Value :  '));
    //         doc.text(x11, Y23, this.totalSales);


    //         let Y35 = Y23 + 5.5;
    //         let Y36;
    //         if (Y35 >= 160) {
    //             doc.addPage();
    //             Y36 = 10;
            
    //         }
    //         else {
    //             Y36 = Y35;
    //         }
  
  

    //         const currentOppCol = ["Name", "Opp. Nickname","Stage", "Est. Booking Value", "Est. Close Date", "Contract Length", "Renewal Start Date",  "Next Step(s)", "Solution"];
    //         var currentOppRows = [];

           

    //         let currentOpptemp = JSON.parse(JSON.stringify(this.currentOppData));



    //         currentOpptemp.forEach(e => {
    //             var currentOppData = [e.opportunityName,e.opportunityNickname, e.stageName, e.amountWithCurrency, e.closeDate, e.contractLength, e.renewalStartDate,  e.nextStep, e.solution];
    //             currentOppRows.push(currentOppData);

    //         });
           

    //         doc.autoTable({
    //             headerStyles: {
    //                 fillColor: [242, 242, 242],
    //                 textColor: [0, 0, 0],
    //                 halign: 'center',
    //                 fontStyle: 'bold',
    //                 fontSize: 10
    //             },

    //             bodyStyles: {
    //                 halign: 'center',
    //                 fontSize: 10
    //             },
    //           //  columnStyles: { 0: { halign: 'left' } },
    //           columnStyles: {
    //             8: {cellWidth: 40 }               
    //         },
    //             margin: { top: 10, left: 10, right: 7 },
    //             columns: currentOppCol,
    //             body: currentOppRows,
    //             startY: Y36,


    //         })

    //         let Y24 = doc.previousAutoTable.finalY;
            

    //         if (Y24 >= 140) {
    //             doc.addPage();
    //             Y24 = 10;
             
    //         }
    //         else {
    //             Y24 = Y24 + 10.5;
    //         }

    //         doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y24, 280, 8, 'F');



    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y24 + 5.5, 'Account Intelligence');

            

    //         let Y25 = Y24 + 10.5;



    //         const systemCol = ["Account Intelligence Name",
    //             "HRMS System",
    //             "Short Description",
    //             "Technology",
    //             "Technographic Category",
    //             "Sub Category"
    //         ]

    //         // "Account Intelligence Type"

    //         var systemRows = [];

         

    //         let systemtemp = JSON.parse(JSON.stringify(this.systemData));


    //         systemtemp.forEach(e => {
    //             var systemData = [e.technology, e.systemName, e.Description, e.technology,
    //             e.technographicCategory, e.subCategory];
                
    //             systemRows.push(systemData);

    //         });
       

    //         doc.autoTable({
    //             headerStyles: {
    //                 fillColor: [242, 242, 242],
    //                 textColor: [0, 0, 0],
    //                 halign: 'center',
    //                 fontStyle: 'bold',
    //                 fontSize: 10
    //             },

    //             bodyStyles: {
    //                 halign: 'center',
    //                 fontSize: 10
    //             },
    //             columnStyles: { 0: { halign: 'center' } },
    //             margin: { top: 10, left: 10, right: 7},
    //             columns: systemCol,
    //             body: systemRows,
    //             startY: Y25,


    //         })


    //         let Y26 = doc.previousAutoTable.finalY;
           

    //         if (Y26 >= 140) {
    //             doc.addPage();
    //             Y26 = 10;
         
    //         }
    //         else {
    //             Y26 = Y26 + 10.5;
    //         }

    //         doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y26, 280, 8, 'F');



    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y26 + 5.5, 'Competitor Information');

          

    //         let Y27 = Y26 + 10.5;

           

    //         const competitorDataCol = ["Name", "Solution", "Est. Customer Spend","Opportunity","Incumbent Vendor","Incumbent Renewal Date" ];
    //         var competitorDataRows = [];


    //         let competitorDatatemp = JSON.parse(JSON.stringify(this.competitorData));


    //         competitorDatatemp.forEach(e => {
    //             var competitorData = [e.competitorName, e.solution, e.estimatedCustomerSpend,e.opportunityName,e.incumbentVendor,e.incumbentDate ];
    //             competitorDataRows.push(competitorData);

    //         });

    //         doc.autoTable({
    //             headerStyles: {
    //                 fillColor: [242, 242, 242],
    //                 textColor: [0, 0, 0],
    //                 halign: 'center',
    //                 fontStyle: 'bold',
    //                 fontSize: 10
    //             },

    //             bodyStyles: {
    //                 halign: 'center',
    //                 fontSize: 10
    //             },
    //             columnStyles: { 0: { halign: 'center' } },
    //             margin: { top: 10, left: 10, right: 7 },
    //             columns: competitorDataCol,
    //             body: competitorDataRows,
    //             startY: Y27,


    //         })

    //         let Y28 = doc.previousAutoTable.finalY;

    //         if (Y28 >= 140) {
    //             doc.addPage();
    //             Y28 = 10;
    //         }
    //         else {
    //             Y28 = Y28 + 10.5;
    //         }

    //         doc.setFillColor(242, 242, 242);
    //         doc.rect(10, Y28, 280, 8, 'F');



    //         doc.setFont('helvetica', 'bold');
    //         doc.setFontSize(12);
    //         doc.text(15, Y28 + 5.5, 'Contract Details');


    //         let Y29 = Y28 + 10.5;



    //         const contractDataCol = ["Anual Contract Value (USD)", "Contract Type", "Contract End Date", "Contract Length", "Renewal Date", "Solution", "Usage"];
    //         var contractDataRows = [];


    //         let contractDatatemp = JSON.parse(JSON.stringify(this.ContractList));



    //         contractDatatemp.forEach(e => {
    //             var contractData = [e.totalAmmount, e.contractType, e.contractEndDate, e.contractLength, e.renewalStartDate, e.oliSolution, e.oliQuantity];
    //             contractDataRows.push(contractData);

    //         });


    //         doc.autoTable({
    //             headerStyles: {
    //                 fillColor: [242, 242, 242],
    //                 textColor: [0, 0, 0],
    //                 halign: 'center',
    //                 fontStyle: 'bold',
    //                 fontSize: 10
    //             },

    //             bodyStyles: {
    //                 halign: 'center',
    //                 fontSize: 10
    //             },
    //             columnStyles: { 0: { halign: 'center' } },
    //             margin: { top: 10, left: 10, right: 7 },
    //             columns: contractDataCol,
    //             body: contractDataRows,
    //             startY: Y29,


    //         })

            /*let Y30;
            let y15 = Y29 + 70;
            if(typeof(this.HistoryTrend)  == 'undefined' || this.HistoryTrend == ''){
           
              
                Y30 = Y29 + 5;
    
            }else{
    
             

                if(y15 >= 120 ){
                    doc.addPage();
                    Y30 = 10;
        
                }   
    
                else if(y15 < 120 ){
                   
                    Y30 = Y29 + 15.5;
                    
        
                }  
            
             doc.setFillColor(242, 242, 242);
         
             doc.rect(10, Y30, 280, 8, 'F');  
        
             doc.setFont('helvetica' , 'bold');
             doc.setFontSize(12);
            
             doc.text(15, Y30+5.5, 'History of Total Spend with SHL ($K)');
            
             doc.addImage(this.HistoryTrend, 'jpg', 50,Y30+11.5, 100, 70);
            }*/

          // doc.save('data.pdf');// For testing purpose 

            //Convert PDF to Blob
            var pdfBlob = doc.output('blob');
            
            this.GetPdfBase64String(pdfBlob);
            

        } catch (error) {
          
            this.showSpinner = false;
           

            let str = error.message;
           

            if (str.includes('.autoTable', 1)) {
                this.renderedCallback();
            }
            else {
                if (this.checkPDF == true) {

                    updatecheckPDF({ AccountPlanId: this.recordId }).then(Response => {
                        if (Response.MessageType == "ERROR") {

                            const event = new ShowToastEvent({
                                title: 'Error',
                                variant: 'Error',
                                mode: 'sticky',
                                message: Response.Message + " Please contact System Admin.",

                            });
                            this.dispatchEvent(event);
                        }
                        else if (Response.MessageType == "SUCCESS") {
                            const event = new ShowToastEvent({
                                title: 'Error',
                                variant: 'Error',
                                mode: 'sticky',
                                message: "Error occured while generating Account Plan.Please contact System Admin. " + error.message,

                            });
                            this.dispatchEvent(event);

                        }
                    }

                    ).catch(Error => {
                    })
                }
                else {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        mode: 'pester',
                        message: "Error --> " + error.message + " occured while generating Account Plan.Please contact System Admin.",

                    });
                    this.dispatchEvent(event);
                }
            }

        }

    }
    calculateYcordinate(priorY){

   
    }
    GetPdfBase64String(pdfBlob){
        
        let self = this; // the function was geting confused with the scope of the 'this' so I created a local variable to use instead
        var reader = new FileReader();
            reader.readAsDataURL(pdfBlob);
            reader.onload=  () => {
                var base64String = reader.result;  
                var base64StringClean = base64String.replace('data:application/pdf;base64,',''); 
                let sendAPData = { Name : self.PDFheader ,
                                   AccountPlanId : self.recordId,
                                   ContentDocumentID : self.ContentDocumentID,
                                   pdfBase64String : base64StringClean};
                let size = (atob(base64StringClean).length)/(1024*1024);
                savePDF({sappdfw_string :  JSON.stringify(sendAPData)}).then(Response => {
                       self.showSpinner = false;

                         const event = new ShowToastEvent({
                            title: Response.MessageType,
                            variant: Response.MessageType,
                            mode:'pester',
                            message: Response.Message,
                            
                    });
                    self.dispatchEvent(event);
                    window.location.reload();
                   // self.navigateAction(event); 
                }).catch(error => {
                    self.showSpinner = false;
                    if(size>3){
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'Error',
                            mode:'pester',
                            message: 'PDF cannot be generated as volume of data is too large',
                            
                    });
                    self.dispatchEvent(event);
                    }else{
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'Error',
                            mode:'pester',
                            message: 'Unknown error occurred. Please contact your System Administrator',
                            
                    });
                    self.dispatchEvent(event);
                    }
                });
            }
     }
   
}