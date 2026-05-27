public class UpdateLeadEmailsBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, Email FROM Contact WHERE Email != null
        ]);
    }

    public void execute(Database.BatchableContext context, List<Contact> leads) {
        List<Contact> toUpdate = new List<Contact>();

        for (Contact l : leads) {
            if (!l.Email.endsWith('.invalid')) {
                l.Email += '.invalid';
                toUpdate.add(l);
            }
        }

        if (!toUpdate.isEmpty()) {
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.EmailHeader.triggerUserEmail = false;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = false;
            dmlOpts.EmailHeader.triggerOtherEmail = false;

            for (Contact l : toUpdate) {
                l.setOptions(dmlOpts);
            }

            Database.update(toUpdate, false);
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Contact email update batch completed.');
    }
}