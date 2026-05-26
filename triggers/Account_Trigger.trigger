// Created By RISHABH KANOTRA to combine all triggers on Account on 06/06/2019
trigger Account_Trigger on Account(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if (Trigger_Activation__c.getInstance('Account_Trigger').Active__c || Test.isRunningTest()) {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                AccountTriggerManager_2.mapGlobalCountryFields(Trigger.new, Null, trigger.newMap); // SSE-16905 - Prachi
                AccountTriggerManager_2.beforeAccInsert(Trigger.new);
                AccountTriggerManager_2.setGCSCAccountOwner(Trigger.new, Null);
                AccountTriggerManager_2.updateNumberOfAP(Trigger.new, Null); // Changes Start SSE-21598 Prachi
                AccountTriggerManager_1.mapsalesTeamRegionAndsuperMDRegionFromTerritory(Trigger.new, null, trigger.newMap); // SSE-23791
            }

            else if (Trigger.isAfter) {
                AccountTerritoryManagement.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap);
            }

        } // Insert

        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                AccountTriggerManager_2.mapGlobalCountryFields(Trigger.new, Trigger.oldMap, trigger.newMap); // SSE-16905 - Prachi

                if (UserInfo.getName() != 'Backoffice') {
                    AccountTriggerManager_1.beforeAccountValidation(Trigger.old, Trigger.new, Trigger.oldMap);
                    AccountTriggerManager_1.changeAccRecordType(Trigger.new, Trigger.oldMap);
                }
                AccountTriggerManager_2.setGCSCAccountOwner(Trigger.new, Trigger.oldMap);
                AccountTriggerManager_2.updateNumberOfAP(Trigger.new, Trigger.oldMap); // Changes Start SSE-21598 Prachi
                AccountTriggerManager_1.mapsalesTeamRegionAndsuperMDRegionFromTerritory(Trigger.new, Trigger.oldMap, trigger.newMap); // SSE-23791
                AccountTriggerManager_1.beforeAccountSanction(Trigger.new, Trigger.oldMap);

            }

            else if (Trigger.isAfter) {
                // AccountTriggerManager_2.afterAccTransferHistory(Trigger.old, Trigger.new, Trigger.oldMap);
                AccountTriggerManager_2.sendSuccessEmailTCPlus(Trigger.newMap, trigger.oldMap);
                AccountTerritoryManagement.handleAfterInsertUpdate(Trigger.new,Trigger.oldMap);
            }

        } // Update

        if (Trigger.isDelete) {
            if (Trigger.isBefore) {
                AccountTriggerManager_2.UserValidationForAccountMergeOrDelete(trigger.old);
            }

            else if (Trigger.isAfter) {
                AccountTriggerManager_2.afterAccDelete(Trigger.old);
            }

        } // Delete

        if (Trigger.isUndelete) {
            if (Trigger.isAfter) {
                AccountTriggerManager_2.afterAccUndelete(Trigger.new);
            }

        } // Undelete

    } // Trigger_Activation

} // end