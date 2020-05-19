/**
 * Created by cveli on 1/21/2020.
 */

public class SandboxRefresh {

    public static void UpdateIntegrationsEndPoints() {
        UpdateSandboxIntegrationsEndpoints.UpdateIntegrationsEndPoints();
    }

    public static void InvalidateContacts() {
        Database.executeBatch(new BatchInvalidateContacts(),  test.isRunningTest() ? 1 : Limits.getLimitCallouts());
    }
        public static void InvalidateLeads() {
        Database.executeBatch(new BatchInvalidateLeads(), test.isRunningTest() ? 1 : Limits.getLimitCallouts());
    }
        public static void InvalidateApplicants() {
        Database.executeBatch(new BatchInvalidateApplicants(), test.isRunningTest() ? 1 : Limits.getLimitCallouts());
    }

    public static void RefreshSanbox(){
        if (!test.isRunningTest()) {
            InvalidateContacts();
            InvalidateLeads();
            InvalidateApplicants();
        }
        UpdateIntegrationsEndPoints();
    }


}