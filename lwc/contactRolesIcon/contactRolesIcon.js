import { LightningElement, api, track } from 'lwc';

export default class ContactRolesIcon extends LightningElement {
    @api roles; // Array of roles to display icons for
    @track roleIcons = []; // Computed array of role-icon pairs
    iconName;
    moreIcons;
    allRoleNames;
    toggleColor;

    connectedCallback() {
        this.allRoleNames = this.roles != null ? this.roles : 'No Roles Added';
        //this.roles != null ? this.template.querySelector('[data-id="myDiv"]').classList.remove('redBackGround') : this.template.querySelector('[data-id="myDiv"]').classList.add('redBackGround');
        this.roles != null ? this.toggleColor = 'enlargeIcon' : this.toggleColor = 'enlargeIcon redBackGround';
        if (this.roles != null) {
            this.mapRolesToIcons();
        }
    }

    //edit --> custom83
    mapRolesToIcons() {
        const roleIconMap = {
            //'Decision Maker / Billing Contact': 'action:new_opportunity',
            //'Decision Maker': 'action:new_opportunity',//priority//custom:custom11//
            'Blocker': 'action:close',
            'Influencer': 'action:new_lead', //custom84//new_lead
            /*'Billing Contact': 'utility:update',
            'Team Member': 'utility:user',
            'Budget Holder': 'utility:currency',
            'Business User': 'utility:briefcase',
            'Champion': 'utility:award',
            'Economic Buyer': 'utility:cart',
            'Evaluator': 'utility:preview',
            'Executive Sponsor': 'utility:leadership',
            'Procurement Contact': 'utility:contract',
            'Trial User': 'utility:clock',
            'Other': 'utility:help',
            */
        };
        const displayOrder = {
            //'Decision Maker / Billing Contact': 0,
            //'Decision Maker': 0,
            'Influencer': 1,
            'Blocker': 2,
        };
        console.log('this.roles: ', JSON.stringify(this.roles));
        let rolesList = this.roles.split(',').map(item => item.trim());
        console.log('rolesList: ', rolesList);
        /*if (rolesList.includes('Decision Maker')) {
            iconName = 'action:new_opportunity';
        }*/
        let moreIconList = [];
        let iconsToDisplay = [];
        rolesList.forEach(role => {
            if (!roleIconMap.hasOwnProperty(role)) {
                moreIconList.push(role);
            } else {
                iconsToDisplay.push(role);
            }
        });

        console.log('moreIconList: ', JSON.stringify(moreIconList));
        this.moreIcons = moreIconList.join(',');
        console.log('this.moreIcons: ', this.moreIcons);

        this.roleIcons = iconsToDisplay.map(role => ({
            role,
            iconName: roleIconMap[role],
            displayOrder: displayOrder[role]
        }));

        this.roleIcons.sort((a, b) => a.displayOrder - b.displayOrder);
        console.log('this.roleIcons: ', JSON.stringify(this.roleIcons));
    }

    handleEditContactRole() {
        console.log('Hiiiiiiiiiiiiiiiii');
        const submitEvent = new CustomEvent('openeditcontactrolemodal');
        this.dispatchEvent(submitEvent);
    }
}