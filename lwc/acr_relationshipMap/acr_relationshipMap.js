import { LightningElement, api, track, wire } from 'lwc';
import getHierarchyDetails from '@salesforce/apex/ACR_RelationshipMapController.getHierarchyDetails';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from "@salesforce/apex";
import ICON from '@salesforce/resourceUrl/Linked_to_Open_and_Closed_Won_Opportunity_Icon';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import COMMUNICATION_CHANNEL from '@salesforce/messageChannel/acr_componentCommunication__c';
import updateInfluenceJSON from '@salesforce/apex/ACR_RelationshipMapController.updateInfluenceJSON';
import getInfluenceAndConflictDetails from '@salesforce/apex/ACR_RelationshipMapController.getInfluenceAndConflictDetails';
import updateConflictJSON from '@salesforce/apex/ACR_RelationshipMapController.updateConflictJSON';
import deleteInfluenceConflictLine from '@salesforce/apex/ACR_RelationshipMapController.deleteInfluenceConflictLine';
import { loadStyle } from 'lightning/platformResourceLoader';
import MENU_CLASS from '@salesforce/resourceUrl/Acr_HeaderCss';

export default class ComponentA extends LightningElement {

    //@api zoomLevel = 70; //Represents the zoom level for the contact hierarchy.
    _zoomLevel;
    minimum = 20; //Specifies the minimum value for the zoom level.
    isShowHierarchy = false;
    isShowSpinner = true;
    scriptsInitialized = false; //Tracks whether the scripts have been initialized.
    errorGettingContacts = 'Error in displaying the hierarchy'; //Stores an error message related to contact retrieval.
    isShowErrorMessage = false;
    isShowContacts = false; //Controls the visibility of the contacts in the component.
    @track ele; //Represents a reference to the '.dragContainer' element.
    @track contacts = []; //Holds the array of retrieved contacts.
    totalPlaceholders;
    accountName;
    accountUrl;
    recordId;
    wiredData;
    hierarchySize = 12;
    isAction = false;
    isView = false;
    contact;
    accountId;
    activeTabInViewCard;
    hierarchyName;
    linkedToOpenAndClosedWonOpportunityIcon = ICON;
    isLegendPopUpOpen = false;
    browserZoomLevel = 1;

    @track sourceNode = null;
    @track targetNode = null;
    @track connections = [];
    @track connectionsForConflictLines = [];
    @track selectedNodes = [];
    @track selectedNodesMap = new Map();
    @track selectedNodesMapForConflictLines = new Map();
    nodeIdsSet = new Set();
    nodeIdsSetForConflictLines = new Set();
    influenceJsonToUse;
    conflictJsonToUse;
    zoomLevel1 = 1;
    lineMargin = '';
    //currentZoom;
    contHierarchyHeight;
    scrollTop;
    scrollLeft;
    zoomInterval;

    sourceNodeId;
    targetNodeId;

    isInfluenceMode = false;
    isConflictMode = false;
    isConflictSelectionMode = false;
    isInfluenceSelectionMode = false;
    lineIdToDelete;
    isDeleteLinePopup = false;
    lineType;
    lineDeletePopupTitle = '';
    //arrowPathData = 'M0,0 L10,5 L0,10';
    arrowPathData = 'M5, 9 L20, 9 L20, 6 L30, 10 L20, 14 L20, 11 L5, 11 Z';
    //arrowPathData = 'M5,9 L35,9 L35,6 L45,10 L35,14 L35,11 L5,11 Z';
    svgClass;
    contactTitleToDisplay = 'Persona';

    legends = [
        { iconName: 'utility:favorite', label: 'Champion', size: 'x-small', iconClass: 'champion-icon' },
        { iconName: 'utility:favorite', label: 'Coach', size: 'x-small', iconClass: 'coach-icon' },
        { iconName: 'action:new_note', label: 'Notes Available', size: 'xx-small', iconClass: 'note-added-icon reduce-size' },
        { iconName: 'action:new_note', label: 'Notes not available', size: 'xx-small', iconClass: 'note-not-added-icon reduce-size' },
        { iconName: 'custom:custom17', label: 'Economic Buyer', size: 'x-small', iconClass: 'economic-buyer' },
        { iconName: 'custom:custom101', label: 'IO Psychologist', size: 'x-small', iconClass: 'io-psychologist' },
        { iconName: 'action:new_opportunity', label: 'Linked to Open Opportunity', size: 'xx-small', iconClass: 'reduce-size' },
        { iconName: 'action:new_opportunity', label: 'Linked to Closed Won Opportunity', size: 'xx-small', iconClass: 'linked-to-closed-won-opportunity reduce-size' },
        { iconName: 'action:new_opportunity', label: 'Linked to Closed Lost Opportunity', size: 'xx-small', iconClass: 'linked-to-closed-lost-opportunity reduce-size' },
    ];

    colorLegends = [
        { label: 'Active Card', color: '#32CD32' }, // Lime Green
        { label: 'Inctive Card', color: '#32CD32' } // Lime Green
    ];

    get transformStyle() {
        return `transform: scale(${this.zoomLevel}); transform-origin: top left;`;
    }

    @api
    get zoomLevel() {
        return this._zoomLevel ?? 70; // Default to 70 if undefined or null
    }

    set zoomLevel(value) {
        this._zoomLevel = value;
    }

    get isZoomDisabled() {
        if (this.isConflictMode || this.isInfluenceMode) {
            return true;
        } else {
            return false;
        }
    }

    get contactTitleToDisplayOptions() {
        return [
            { label: 'Persona', value: 'Persona' },
            { label: 'Job Title', value: 'JobTitle' },
            { label: 'Area Of Interest', value: 'AreaOfInterest' },
            { label: 'City', value: 'City' },
            { label: 'State', value: 'State' },
            { label: 'Country', value: 'Country' },
        ];
    }

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.c__recordId;
            this.hierarchyName = currentPageReference.state.c__hierarchyName;
        }
    }

    @wire(getHierarchyDetails, { hierarchyInformationId: '$recordId' })
    wiredHierarchyDetails(value) {
        this.wiredData = value;
        const { error, data } = value;
        if (data) {
            this.contacts = [];
            this.accountName = data.AccountName;
            this.accountUrl = data.AccountUrl;
            this.accountId = data.AccountId;
            let hierarchyList = data.HierarchyList;
            if (hierarchyList != null && hierarchyList.length > 0) {
                this.totalPlaceholders = data.TotalPlaceholders;
                var result = JSON.parse(JSON.stringify(hierarchyList));
                // Create a new list with additional properties
                let myList = result.map(row => ({
                    ...row,
                    condition: (!row.ReportsTo)
                }));
                this.contacts = myList; // Set the retrieved contacts to the component's contacts property.
                this.isShowContacts = true; // Show the contacts in the component.
                this.allContactsList = hierarchyList;
                this.isShowHierarchy = true;
            } else {
                //self.errorGettingContacts = res.message; // Set an error message if no contacts were retrieved.
                this.isShowContacts = false; // Hide the contacts in the component.
            }
            this.isShowSpinner = false; // Hide the spinner since the contacts retrieval is complete.
            this.error = undefined;
        } else if (error) {
            this.isShowSpinner = false;
            this.isShowErrorMessage = true;
            this.error = error;
            this.contacts = undefined;
        }
    }
    /**
     * Callback function triggered after the component finishes rendering.
     * Performs specific actions to manipulate the rendered elements.
     * Also initializes scripts if not already initialized.
     */

    connectedCallback() {
        //window.addEventListener('resize', () => this.drawLine());
        let currentUrl = window.location.origin;
        this.svgClass = currentUrl.includes('.sandbox.') ? 'connections' : 'connections prod-fix';

        subscribe(this.messageContext, COMMUNICATION_CHANNEL, (message) => {
            this.handleNodePosition(message);
        });
    }

    disconnectedCallback() {
        //window.removeEventListener("resize", this.detectZoom);
    }

    renderedCallback() {

        loadStyle(this, MENU_CLASS).then(() => {
        }).catch(error => {
            console.error("Error in loading the MENU_CLASS", error);
        })

        const style = document.createElement('style');
        style.innerText = `.slider .slds-form-element__label {
                display: none !important;
            }
            
            .slider .slds-form-element__control {
                margin-top: 7px !important;
            }
            
            .slider .slds-slider__range {
                width: 100%;
            }`;

        // Retrieve the 'div.slider' element from the template.
        var temp = this.template.querySelector('div.slider'); //this.template.querySelector('[data-id="slider"]');
        if (temp != null) {
            temp.appendChild(style);// Append the style element to the 'div.slider' element.
        }

        // Retrieve the '.resize' element from the template.
        var mainPattElem = this.template.querySelector('.resize');
        if (mainPattElem) {
            // Adjust the zoom level of the '.resize' element based on the 'zoomLevel' property.
            mainPattElem.style.zoom = this.zoomLevel + '%';
            if (this.currentZoom) {
                //this.requestNodePositions();
            }

        }

        // Retrieve the '.dragContainer' element from the template.
        this.ele = this.template.querySelector('.dragContainer');
        if (this.ele != null) {
            let centerX = (this.ele.scrollWidth - this.ele.clientWidth) / 2;
            this.ele.scrollTo(centerX, 0);  // Scroll the '.dragContainer' element horizontally to center its content.                         
        }

        let scrollVal = (document.body.scrollWidth / 2);
        let currentZoom = this.getBrowserZoom();
        document.documentElement.scrollLeft = ((scrollVal * currentZoom) - (200 * currentZoom));

        setTimeout(() => {

            const contHierarchy = this.template.querySelector('.contHierarchy');
            const resizeTemplate = this.template.querySelector('.contHierarchy');
            const contHierarchyHeight = contHierarchy.getBoundingClientRect().height;
            const contHierarchyWidth = resizeTemplate.getBoundingClientRect().width;
            let increasedHeight = contHierarchyHeight + 300;
            this.contHierarchyHeight = 'height:' + increasedHeight + 'px; width: ' + contHierarchyWidth + 'px;';

            /*const contHierarchy = this.template.querySelector('.contHierarchy');
            const contHierarchyHeight = contHierarchy.getBoundingClientRect().height;
            let increasedHeight = contHierarchyHeight + 300;
            this.contHierarchyHeight = 'height:' + increasedHeight + 'px;';*/
            //this.contHierarchyHeight = 'height:' + contHierarchyHeight + 'px;';
        }, 5000);
        //this.requestNodePositions();
    }

    // Increase the zoom level by one step
    zoomIn() {
        var zoom = this.zoomLevel;
        if (zoom <= 99) { // Check if the zoom level is less than or equal to 99
            var newZoom = parseInt(zoom) + 1; // Increment the zoom level by 1
            this.zoomLevel = newZoom; // Update the zoom level with the new value
        }
    }

    // Decrease the zoom level by one step
    zoomOut() {
        var zoom = this.zoomLevel
        if (zoom >= this.minimum) { // Check if the zoom level is greater than or equal to the minimum value
            var newZoom = parseInt(zoom) - 1; // Decrement the zoom level by 1
            this.zoomLevel = newZoom; // Update the zoom level with the new value
        }
    }

    // Handle the zoom event triggered by the slider
    handleZoom(event) {
        var sliderValue = event.target.value; // Get the value of the slider
        this.zoomLevel = sliderValue; // Update the zoom level with the value from the slider
    }

    handleRefreshHierarchy(event) {
        this.connections = [];
        this.connectionsForConflictLines = [];
        this.influenceJson = undefined;
        this.conflictJson = undefined;
        this.zoomLevel = event.detail;
        this.handleActionClose();
        this.isShowContacts = false;
        refreshApex(this.wiredData).then(() => {
            this.isShowContacts = true;
            this.zoomLevel = event.detail;
            if (this.isInfluenceMode) {
                clearInterval(this.zoomInterval);
                this.currentZoom = undefined;
                this.getInfluenceJson();
            }
            if (this.isConflictMode) {
                clearInterval(this.zoomInterval);
                this.currentZoom = undefined;
                this.getConflictJson();
            }
        });
    }

    handleSpinnerToggle() {
        this.isShowSpinner = true;
    }

    handleViewContact(event) {

        if (!this.contact) {
            let mapWidth = this.template.querySelector('.level-2');
            let totalWidth = this.template.querySelector('.dragContainer');
            let percent = mapWidth.getBoundingClientRect().width / totalWidth.getBoundingClientRect().width;
            percent = percent * 100;
            if (percent <= 75) {
                this.zoomLevel = 60;
            } else if (percent > 75 && percent <= 90) {
                this.zoomLevel = 55;
            } else if (percent > 90 && percent <= 120) {
                this.zoomLevel = 40;
            } else if (percent > 120 && percent <= 185) {
                this.zoomLevel = 30;
            } else if (percent > 185) {
                this.zoomLevel = 20;
            }
            this.hierarchySize = 7;
            this.isAction = true;
        }
        setTimeout(() => {
            this.isView = false;
        }, 0);
        setTimeout(() => {
            this.isView = true;
        }, 0);
        this.contact = event.detail.contact;
        this.activeTabInViewCard = event.detail.tab;
        if (this.isInfluenceMode) {
            this.getInfluenceJson();
        }
        if (this.isConflictMode) {
            this.getConflictJson();
        }
    }

    handleActionClose() {
        this.zoomLevel = 70;
        this.hierarchySize = 12;
        this.isAction = false;
        this.isEdit = false;
        this.isView = false;
        this.contact = null;
        if (this.isInfluenceMode) {
            this.getInfluenceJson();
        }
        if (this.isConflictMode) {
            this.getConflictJson();
        }
    }

    handleCloseLegendsPopUp() {
        this.isLegendPopUpOpen = false;
    }

    handleLegendOpen() {
        this.isLegendPopUpOpen = true;
    }

    handleDragStart(event) {
        event.dataTransfer.setData("contactId", event.target.dataset.id);
    }

    handleDrop(event) {
        event.preventDefault();
        const contactId = event.dataTransfer.getData("contactId");
        const newReportsToId = event.target.dataset.id || null;
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleNodePosition({ action, nodeId, node, nodeType, actionType, type }) {

        if (action === 'sendNodePosition' && type == 'influence') {
            this.handleSelectNode(nodeId, node, nodeType, actionType);
        }
        if (action === 'sendNodePosition' && type == 'conflict') {
            this.handleSelectNodeForConflictLines(nodeId, node, nodeType, actionType);
        }
    }

    handleSelectNode(nodeId, selectedNode, nodeType, actionType) {

        if (!this.sourceNode && selectedNode != null && nodeType == 'Source') {
            this.sourceNode = selectedNode;
            this.sourceNodeId = nodeId;
        } else {
            this.targetNode = selectedNode;
            this.targetNodeId = nodeId;
            //this.createConnection(nodeId, actionType);
        }
        this.selectedNodesMap.set(nodeId, selectedNode);

        if (this.selectedNodesMap.size == this.nodeIdsSet.size) {
            this.addNodesToInfluenceJson();
        }
    }

    addNodesToInfluenceJson() {
        let influenceJson = JSON.parse(this.influenceJson);
        influenceJson.forEach(element => {
            element.sourceNode = this.selectedNodesMap.get(element.source);
            element.targetNode = this.selectedNodesMap.get(element.target);
        });

        this.influenceJsonToUse = influenceJson;

        this.createConnections();
    }

    handleSelectNodeForConflictLines(nodeId, selectedNode, nodeType, actionType) {
        this.selectedNodesMapForConflictLines.set(nodeId, selectedNode);

        if (this.selectedNodesMapForConflictLines.size == this.nodeIdsSetForConflictLines.size) {
            this.addNodesToConflictJson();
        }
    }

    addNodesToConflictJson() {
        let conflictJson = JSON.parse(this.conflictJson);
        conflictJson.forEach(element => {
            element.sourceNode = this.selectedNodesMapForConflictLines.get(element.source);
            element.targetNode = this.selectedNodesMapForConflictLines.get(element.target);
        });

        this.conflictJsonToUse = conflictJson;

        this.createConnectionsForConflictLines();
    }

    createConnections() {

        const contHierarchy = this.template.querySelector('.contHierarchy');
        const resizeTemplate = this.template.querySelector('.contHierarchy');
        const contHierarchyHeight = contHierarchy.getBoundingClientRect().height;
        const contHierarchyWidth = resizeTemplate.getBoundingClientRect().width;
        let increasedHeight = contHierarchyHeight + 300;
        this.contHierarchyHeight = 'height:' + increasedHeight + 'px; width: ' + contHierarchyWidth + 'px;';

        let connectionsList = [];

        this.influenceJsonToUse.forEach(element => {
            let sourceRect = element.sourceNode;
            let targetRect = element.targetNode;

            let x1 = sourceRect.x;
            let y1 = sourceRect.y;
            let x2 = targetRect.x;
            let y2 = targetRect.y;

            // Define the control point for a smooth curve (midway)
            //const cx = ((x1 + x2) / 2) - 100; //
            //const cy = Math.min(y1, y2) + 25; // Adjust curvature by modifying this value

            let cx;
            let cy;
            if (parseInt(x1, 10) === parseInt(x2, 10)) {
                if ((y1 > y2 ? y1 - y2 : y2 - y1) < 200) {
                    cx = x1;
                    cy = y2;
                } else {
                    cx = x1 + (y2 > y1 ? 250 : -250);
                    cy = (y1 + y2) / 2;
                }
            } else if (parseInt(y1, 10) === parseInt(y2, 10)) {
                /*if ((x1 > x2 ? x1 - x2 : x2 - x1) < 250) {
                    cx = x1;
                    cy = y2;
                } else {*/
                cx = (x1 + x2) / 2;
                cy = y1 + (x1 < x2 ? 150 : -150);
                //}
            } else {
                cx = x1;
                cy = y2;
            }

            // Store relative positions (as percentages)
            let connection = {
                id: element.source + '-' + element.target,//target id
                source: element.source,
                target: element.target,
                x1: sourceRect.x,
                y1: sourceRect.y,
                x2: targetRect.x,
                y2: targetRect.y,
                path: `M ${x1},${y1} Q ${cx},${cy} ${x2},${y2}`,
                cx: cx,
                cy: cy,
            };
            connectionsList.push(connection);
        });
        this.connections = connectionsList;

        setTimeout(() => {
            document.documentElement.scrollTop = this.scrollTop ? this.scrollTop : 0;
            document.body.scrollTop = this.scrollTop ? this.scrollTop : 0;
            document.documentElement.scrollLeft = this.scrollLeft ? this.scrollLeft : 0;
            document.body.scrollLeft = this.scrollLeft ? this.scrollLeft : 0;
        }, 0);
        setTimeout(() => {
            // if (actionType == 'new') {
            //     this.updateInfluenceJSON();
            // } else {
            this.isShowSpinner = false;
            //}
        }, 1000);
        setTimeout(() => {
            this.connections.forEach(element => {
                const path = this.template.querySelector(`[data-id="${element.id}"]`);

                // Ensure path element is available
                if (!path) return;

                const pathLength = path.getTotalLength(); // Get the total length of the path
                let arrowArray = []; // Temporary array to hold arrow details

                //const samplePoints = 20;  // Sample the path 50 times, adjust for more or less frequent arrows
                let samplePoints = pathLength / 30;
                for (let i = 0; i < samplePoints; i++) {
                    const point = path.getPointAtLength((i / (samplePoints - 1)) * pathLength); // Sample points along the path

                    // Calculate the tangent (direction) at this point by looking at two neighboring points
                    const nextPoint = path.getPointAtLength(((i + 1) / (samplePoints - 1)) * pathLength); // Next sample point
                    const dx = nextPoint.x - point.x; // Difference in x-coordinates
                    const dy = (nextPoint.y - (point.y)); // Difference in y-coordinates
                    const rotationAngle = Math.atan2(dy, dx) * (180 / Math.PI); // Convert to degrees

                    // Create transform string to position and rotate the arrow
                    // Adjust for the size of the arrow so it is centered at the point
                    const arrowOffset = -0.5; // Adjust this value to properly center the arrow based on its size
                    if (rotationAngle != 0) {
                        const transform = `translate(${point.x + 4}, ${point.y + 4}) rotate(${rotationAngle})`;
                        // Store the arrow details in the array
                        arrowArray.push({
                            key: `arrow-${i}`,
                            d: this.arrowPathData,
                            transform: transform
                        });
                    }
                }

                // Set the arrows array to trigger reactivity in LWC
                element.arrows = arrowArray;
            });
        }, 500);
    }

    createConnectionsForConflictLines() {

        const contHierarchy = this.template.querySelector('.contHierarchy');
        const contHierarchyHeight = contHierarchy.getBoundingClientRect().height;
        let increasedHeight = contHierarchyHeight + 300;
        this.contHierarchyHeight = 'height:' + increasedHeight + 'px;';

        let connectionsList = [];

        this.conflictJsonToUse.forEach(element => {
            let sourceRect = element.sourceNode;
            let targetRect = element.targetNode;

            let x1 = sourceRect.x;
            let y1 = sourceRect.y;
            let x2 = targetRect.x;
            let y2 = targetRect.y;

            // Define the control point for a smooth curve (midway)
            //const cx = ((x1 + x2) / 2) - 100; //
            //const cy = Math.min(y1, y2) + 25; // Adjust curvature by modifying this value
            let cx;
            let cy;
            if ((x2 < x1 && y2 < y1) || (x1 < x2 && y1 < y2)) {
                cx = ((x1 + x2) / 2);
                cy = Math.min(y1, y2);
            } else if (((x2 > x1) && (y2 < y1)) || ((x2 < x1) && (y1 < y2))) {
                cx = ((x1 + x2) / 2);
                cy = ((y1 + y2) / 2);
            } else if (x1 == x2 || y1 == y2) {
                cx = ((x1 + x2) / 2) - 50;
                cy = ((y1 + y2) / 2) + 50;
            }

            // Store relative positions (as percentages)
            let connection = {
                id: element.source + '-' + element.target,//target id
                source: element.source,
                target: element.target,
                x1: sourceRect.x,
                y1: sourceRect.y,
                x2: targetRect.x,
                y2: targetRect.y,
                path: `M ${x1},${y1} Q ${cx},${cy} ${x2},${y2}`,
                targetcx: targetRect.x,
                targetcy: targetRect.y,
                sourcecx: sourceRect.x,
                sourcecy: sourceRect.y,
                points: `${x2},${y2},5,10,-5,10`
            };

            connectionsList.push(connection);

        });

        this.connectionsForConflictLines = connectionsList;


        setTimeout(() => {
            document.documentElement.scrollTop = this.scrollTop ? this.scrollTop : 0;
            document.body.scrollTop = this.scrollTop ? this.scrollTop : 0;
            document.documentElement.scrollLeft = this.scrollLeft ? this.scrollLeft : 0;
            document.body.scrollLeft = this.scrollLeft ? this.scrollLeft : 0;
        }, 0);
        setTimeout(() => {
            // if (actionType == 'new') {
            //     this.updateInfluenceJSON();
            // } else {
            this.isShowSpinner = false;
            //}
        }, 1000);

    }

    checkZoomChange() {
        this.zoomInterval = setInterval(() => {
            const newZoom = this.getBrowserZoom();
            if (newZoom !== this.currentZoom) {
                this.isShowSpinner = true;
                let scrollVal = (document.body.scrollWidth / 2);
                document.documentElement.scrollLeft = ((scrollVal * newZoom) - (200 * newZoom));

                this.scrollTop = document.body.scrollTop || document.documentElement.scrollTop;
                document.body.scrollTop = 0;
                document.documentElement.scrollTop = 0;

                this.scrollLeft = document.body.scrollLeft || document.documentElement.scrollLeft;
                document.body.scrollLeft = 0;
                document.documentElement.scrollLeft = 0;

                this.currentZoom = newZoom;
                this.selectedNodesMap = new Map();
                this.selectedNodesMapForConflictLines = new Map();
                //this.nodeIdsSet = new Set();
                //this.nodeIdsSetForConflictLines = new Set();
                this.connections = [];
                this.connectionsForConflictLines = [];
                if (this.isInfluenceMode || this.lineType == 'Influence') {
                    this.requestNodePositions();
                } if (this.isConflictMode || this.lineType == 'Conflict') {
                    this.requestNodePositionsForConflictLines();
                }
            }
        }, 500); // Check every 500ms
    }

    requestNodePositions() {
        // Request child nodes to send positions
        publish(this.messageContext, COMMUNICATION_CHANNEL, { action: 'requestNodePositions', influenceJson: this.influenceJson, nodeType: 'Source' });
    }

    requestNodePositionsForConflictLines() {
        publish(this.messageContext, COMMUNICATION_CHANNEL, { action: 'requestNodePositionsForConflictLines', conflictJson: this.conflictJson, nodeType: 'Source' });
    }

    requestRemoveSelectionMode() {
        publish(this.messageContext, COMMUNICATION_CHANNEL, { action: 'removeSelectionMode' });
    }

    getBrowserZoom() {
        return window.devicePixelRatio || 1; // Default is 1 (100% zoom)
    }

    handleInfluenceLines(event) {
        let isChecked = event.target.checked;
        this.isInfluenceMode = isChecked;
        if (isChecked) {
            this.getInfluenceJson();
        } else {
            this.connections = [];
            this.currentZoom = undefined;
            clearInterval(this.zoomInterval);
        }
    }

    handleConflictLines(event) {
        let isChecked = event.target.checked;
        this.isConflictMode = isChecked;
        if (isChecked) {
            this.getConflictJson();
        } else {
            this.connectionsForConflictLines = [];
            this.currentZoom = undefined;
            clearInterval(this.zoomInterval);
        }
    }

    getInfluenceJson() {
        this.isShowSpinner = true;
        this.connections = [];
        getInfluenceAndConflictDetails({ hierarchyInformationId: this.recordId })
            .then((result) => {
                if (result[0].Influence__c) {
                    this.influenceJson = (result[0]?.Influence__c);
                    this.handleNodeIdsSet();
                    clearInterval(this.zoomInterval);
                    this.currentZoom = undefined;
                    this.checkZoomChange();
                } else {
                    this.isShowSpinner = false;
                }
            })
            .catch((error) => {
                /*if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }*/
            })
            .finally(() => {
                console.log('finally getInfluenceAndConflictDetails: ');
            });
    }

    getConflictJson() {
        this.isShowSpinner = true;
        this.connectionsForConflictLines = [];
        getInfluenceAndConflictDetails({ hierarchyInformationId: this.recordId })
            .then((result) => {
                if (result[0].Conflict__c) {
                    this.conflictJson = (result[0]?.Conflict__c);
                    this.handleNodeIdsSetForConflictLines();
                    clearInterval(this.zoomInterval);
                    this.currentZoom = undefined;
                    this.checkZoomChange();
                } else {
                    this.isShowSpinner = false;
                }
            })
            .catch((error) => {
                console.log('error getInfluenceAndConflictDetails: ', JSON.stringify(error));
                /*if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }*/
            })
            .finally(() => {
                console.log('finally getInfluenceAndConflictDetails: ');
            });
    }

    handleLineClick(event) {
        this.lineIdToDelete = event.target.dataset.id;
        this.lineType = event.target.dataset.type;
        this.lineDeletePopupTitle = 'Delete ' + this.lineType;
        this.isDeleteLinePopup = true;
    }

    handleNewConnection(event) {
        this.isShowSpinner = true;
        this.isInfluenceSelectionMode = event.detail.isInfluenceSelectionMode;
        if (this.isInfluenceSelectionMode) {
            this.handleNewInfluenceConnection(event);
        } else {
            this.handleNewConflictConnection(event);
        }
    }

    handleNewInfluenceConnection(event) {
        let updatedInfluenceJson = [];
        let isDuplicate = false;
        this.connections.forEach(element => {
            let connection = {};
            connection.id = element.id;
            connection.source = element.source;
            connection.target = element.target;

            updatedInfluenceJson.push(connection);
            if (element.id == (event.detail.sourceId + '-' + event.detail.targetId)) {
                isDuplicate = true;
            }
        });


        if (!isDuplicate) {
            let newConnection = {
                id: event.detail.sourceId + '-' + event.detail.targetId,
                source: event.detail.sourceId,
                target: event.detail.targetId
            };
            updatedInfluenceJson.push(newConnection);
        }

        updateInfluenceJSON({ influenceJson: JSON.stringify(updatedInfluenceJson), hierarchyInformationId: this.recordId })
            .then((result) => {
                this.currentZoom = undefined;
                this.influenceJson = result;
                this.isInfluenceSelectionMode = false;
                this.requestRemoveSelectionMode();
                this.handleNodeIdsSet();
                if (this.zoomInterval) {
                    clearInterval(this.zoomInterval);
                }
                setTimeout(() => {
                    this.checkZoomChange();
                }, 0);
            })
            .catch((error) => {
                console.log('error updateInfluenceJSON: ', JSON.stringify(error));
                /*if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }*/
            })
            .finally(() => {
                console.log('finally updateInfluenceJSON: ');
                this.showSpinner = false;
            });
    }

    handleNewConflictConnection(event) {
        let updatedConflictJson = [];
        let isDuplicate = false;

        this.connectionsForConflictLines.forEach(element => {
            let connection = {};
            connection.id = element.id;
            connection.source = element.source;
            connection.target = element.target;

            updatedConflictJson.push(connection);
            if (element.id == (event.detail.sourceId + '-' + event.detail.targetId) || element.id == (event.detail.targetId + '-' + event.detail.sourceId)) {
                isDuplicate = true;
            }
        });

        if (!isDuplicate) {
            let newConnection = {
                id: event.detail.sourceId + '-' + event.detail.targetId,
                source: event.detail.sourceId,
                target: event.detail.targetId
            };
            updatedConflictJson.push(newConnection);
        }

        updateConflictJSON({ conflictJson: JSON.stringify(updatedConflictJson), hierarchyInformationId: this.recordId })
            .then((result) => {
                this.currentZoom = undefined;
                this.conflictJson = result;
                this.isConflictSelectionMode = false;
                this.requestRemoveSelectionMode();
                this.handleNodeIdsSetForConflictLines();
                if (this.zoomInterval) {
                    clearInterval(this.zoomInterval);
                }
                setTimeout(() => {
                    this.checkZoomChange();
                }, 0);
            })
            .catch((error) => {
                console.log('error updateInfluenceJSON: ', JSON.stringify(error));
                /*if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }*/
            })
            .finally(() => {
                console.log('finally updateInfluenceJSON: ');
                this.showSpinner = false;
            });
    }

    handleNodeIdsSet() {
        this.nodeIdsSet = new Set();
        let influenceJson = JSON.parse(this.influenceJson);

        influenceJson.forEach(element => {
            this.nodeIdsSet.add(element.source);
            this.nodeIdsSet.add(element.target);
        });
    }

    handleNodeIdsSetForConflictLines() {
        this.nodeIdsSetForConflictLines = new Set();
        let conflictJson = JSON.parse(this.conflictJson);

        conflictJson.forEach(element => {
            this.nodeIdsSetForConflictLines.add(element.source);
            this.nodeIdsSetForConflictLines.add(element.target);
        });
    }

    handleInfluenceMode() {
        //this.isShowSpinner = true;
        if (!this.isInfluenceMode) {
            this.isInfluenceMode = true;
            this.isInfluenceSelectionMode = true;
            this.getInfluenceJson();
        }
    }

    handleConflictMode() {
        //this.isShowSpinner = true;
        if (!this.isConflictMode) {
            this.isConflictMode = true;
            this.isConflictSelectionMode = true;
            this.getConflictJson();
        }
    }

    handleDeleteLinePopupClose() {
        this.isDeleteLinePopup = false;
    }

    handleDeleteLine() {
        this.isShowSpinner = true;
        deleteInfluenceConflictLine({ hierarchyInformationId: this.recordId, lineIdToDelete: this.lineIdToDelete, lineType: this.lineType })
            .then((result) => {
                this.isDeleteLinePopup = false;
                this.currentZoom = undefined;
                let hasConflict = false;
                let hasInfluence = false;
                if (this.lineType == 'Influence') {
                    this.influenceJson = result == null ? undefined : result;
                    if (this.influenceJson) {
                        hasInfluence = true;
                        this.handleNodeIdsSet();
                    } else {
                        this.connections = [];
                        this.isShowSpinner = false;
                    }
                } else {
                    this.conflictJson = result == null ? undefined : result;
                    if (this.conflictJson) {
                        hasConflict = true;
                        this.handleNodeIdsSetForConflictLines();
                    } else {
                        this.connectionsForConflictLines = [];
                        this.isShowSpinner = false;
                    }
                }
                if (this.zoomInterval) {
                    clearInterval(this.zoomInterval);
                }
                if (hasInfluence || hasConflict) {
                    setTimeout(() => {
                        this.checkZoomChange();
                    }, 0);
                }
                this.lineType = undefined;
            })
            .catch((error) => {
                console.log('error updateInfluenceJSON: ', JSON.stringify(error));
                /*if (error.body && error.body.message) {
                    let errorMessage = error.body.message;
                    this.toast('Error', errorMessage, 'error', 'dismissible');
                } else {
                    this.toast('Error', 'Something went wrong', 'error', 'dismissible');
                }*/
            })
            .finally(() => {
                console.log('finally updateInfluenceJSON: ');
                this.showSpinner = false;
            });
    }

    handleInputChange(event) {
        if (this.contactTitleToDisplay !== event.target.value) {
            this.contactTitleToDisplay = event.target.value;
            publish(this.messageContext, COMMUNICATION_CHANNEL, { action: 'updateContactTitleValue', contactTitleToDisplay: event.target.value });
        }
    }
}