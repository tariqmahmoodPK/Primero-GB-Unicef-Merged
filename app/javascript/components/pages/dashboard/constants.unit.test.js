import * as constants from "./constants";

describe("Verifying config constant", () => {
  it("should have known constant", () => {
    const clone = { ...constants };

    [
      "DASHBOARD_FLAGS_SORT_FIELD",
      "DASHBOARD_FLAGS_SORT_ORDER",
      "DASHBOARD_NAMES",
      "DASHBOARD_TYPES",
      "INDICATOR_NAMES",
      "NAME",
      "PROTECTION_CONCERNS_ORDER_NAMES",
      "RISK_LEVELS"
    ].forEach(property => {
      expect(clone).to.have.property(property);
      delete clone[property];
    });

    expect(clone).to.be.empty;
  });

  it("should have correct constant value", () => {
    const clone = { ...constants };

    expect(clone.DASHBOARD_NAMES).to.have.all.keys(
      "APPROVALS_ASSESSMENT_PENDING",
      "APPROVALS_ASSESSMENT",
      "APPROVALS_CASE_PLAN_PENDING",
      "APPROVALS_CASE_PLAN",
      "APPROVALS_CLOSURE_PENDING",
      "APPROVALS_CLOSURE",
      "APPROVALS_ACTION_PLAN_PENDING",
      "APPROVALS_ACTION_PLAN",
      "APPROVALS_GBV_CLOSURE_PENDING",
      "APPROVALS_GBV_CLOSURE",
      "CASE_INCIDENT_OVERVIEW",
      "CASE_OVERVIEW",
      "CASE_RISK",
      "CASES_BY_SOCIAL_WORKER",
      "CASES_BY_TASK_OVERDUE_ASSESSMENT",
      "CASES_BY_TASK_OVERDUE_CASE_PLAN",
      "CASES_BY_TASK_OVERDUE_FOLLOWUPS",
      "CASES_BY_TASK_OVERDUE_SERVICES",
      "CASES_TO_ASSIGN",
      "GROUP_OVERVIEW",
      "NATIONAL_ADMIN_SUMMARY",
      "PERPETRATOR_ARMED_FORCE_GROUP_PARTY_NAMES",
      "PROTECTION_CONCERNS",
      "REPORTING_LOCATION",
      "SHARED_FROM_MY_TEAM",
      "SHARED_WITH_ME",
      "SHARED_WITH_MY_TEAM",
      "SHARED_WITH_MY_TEAM_OVERVIEW",
      "SHARED_WITH_OTHERS",
      "VIOLATIONS_CATEGORY_REGION",
      "VIOLATIONS_CATEGORY_VERIFICATION_STATUS",
      "WORKFLOW_TEAM",
      "WORKFLOW"
    );

    expect(clone.INDICATOR_NAMES).to.have.all.keys(
      "PERPETRATOR_ARMED_FORCE_GROUP_PARTY_NAMES",
      "PROTECTION_CONCERNS_ALL_CASES",
      "PROTECTION_CONCERNS_CLOSED_THIS_WEEK",
      "PROTECTION_CONCERNS_NEW_THIS_WEEK",
      "PROTECTION_CONCERNS_OPEN_CASES",
      "REPORTING_LOCATION_ClOSED_LAST_WEEK",
      "REPORTING_LOCATION_ClOSED_THIS_WEEK",
      "REPORTING_LOCATION_OPEN_LAST_WEEK",
      "REPORTING_LOCATION_OPEN_THIS_WEEK",
      "REPORTING_LOCATION_OPEN",
      "RISK_LEVEL",
      "VIOLATIONS_CATEGORY_VERIFICATION_STATUS",
      "WORKFLOW_TEAM",
      "WORKFLOW"
    );

    expect(clone.PROTECTION_CONCERNS_ORDER_NAMES).to.be.an("array");
  });
});
