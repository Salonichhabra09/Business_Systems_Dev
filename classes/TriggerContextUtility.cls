public class TriggerContextUtility {
    private static boolean courseTriggerFirstRun = true;

    public static boolean isCourseTriggerFirstRun() {
        return courseTriggerFirstRun;
    }

    public static void setCourseTriggerFirstRunFalse(){
        courseTriggerFirstRun = false;
    }
}