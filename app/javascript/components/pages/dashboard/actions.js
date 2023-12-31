import { namespaceActions } from "../../../libs";

import NAMESPACE from "./namespace";

export default namespaceActions(NAMESPACE, [
  "CASES_BY_CASE_WORKER",
  "CASES_BY_STATUS",
  "CASES_REGISTRATION",
  "CASES_OVERVIEW",
  "DASHBOARDS",
  "DASHBOARDS_STARTED",
  "DASHBOARDS_SUCCESS",
  "DASHBOARDS_FINISHED",
  "DASHBOARDS_FAILURE",
  "DASHBOARD_FLAGS",
  "DASHBOARD_FLAGS_STARTED",
  "DASHBOARD_FLAGS_SUCCESS",
  "DASHBOARD_FLAGS_FINISHED",
  "DASHBOARD_FLAGS_FAILURE",
  "OPEN_PAGE_ACTIONS",
  "SERVICES_STATUS",
  // 'Percentage of Children who received Child Protection Services'
  "PERCENTAGE_OF_CHILDREN_WHO_RECEIVED_CHILD_PROTECTION_SERVICES",
  "PERCENTAGE_OF_CHILDREN_WHO_RECEIVED_CHILD_PROTECTION_SERVICES_SUCCESS",
  // 'Closed Cases by Sex and Reason'
  "RESOLVED_CASES_BY_GENDER_AND_REASON",
  "RESOLVED_CASES_BY_GENDER_AND_REASON_SUCCESS",
  // 'Cases Referrals (To Agency)'
  "CASES_REFERRALS_TO_AGENCY",
  "CASES_REFERRALS_TO_AGENCY_SUCCESS",
  // 'Cases requiring Alternative Care Placement Services'
  "CASES_REQUIRING_ALTERNATIVE_CARE_PLACEMENT_SERVICES",
  "CASES_REQUIRING_ALTERNATIVE_CARE_PLACEMENT_SERVICES_SUCCESS",
  // 'Registered and Closed Cases by Month'
  "MONTHLY_REGISTERED_AND_RESOLVED_CASES",
  "MONTHLY_REGISTERED_AND_RESOLVED_CASES_SUCCESS",
  // 'High Risk Cases by Protection Concern'
  "HIGH_RISK_CASES_BY_PROTECTION_CONCERN",
  "HIGH_RISK_CASES_BY_PROTECTION_CONCERN_SUCCESS",
  // 'Registered Cases by Protection Concern'
  "REGISTERED_CASES_BY_PROTECTION_CONCERN",
  "REGISTERED_CASES_BY_PROTECTION_CONCERN_SUCCESS",
  // 'Community based Child Protection Committees'
  "COMMUNITY_BASED_CHILD_PROTECTION_COMMITTEES",
  "COMMUNITY_BASED_CHILD_PROTECTION_COMMITTEES_SUCCESS",
  // 'Community Engagement Sessions'
  "COMMUNITY_ENGAGEMENT_SESSIONS",
  "COMMUNITY_ENGAGEMENT_SESSIONS_SUCCESS",
  // 'Cases at a Glance'
  "CASES_AT_A_GLANCE",
  "CASES_AT_A_GLANCE_SUCCESS",
  // 'Cases Source'
  "CASES_SOURCE",
  "CASES_SOURCE_SUCCESS",
  "CASE_STATUSES",
  "CASE_STATUSES_SUCCESS",
  // 'Custody with Court Order'
  "CUSTODY_WITH_COURT_ORDER",
  "CUSTODY_WITH_COURT_ORDER_SUCCESS",
  // 'Police Cases'
  "POLICE_CASES",
  "POLICE_CASES_SUCCESS",
  // 'Cases Requiring Special Consideration'
  "CASES_REQUIRING_SPECIAL_CONSIDERATION",
  "CASES_REQUIRING_SPECIAL_CONSIDERATION_SUCCESS"
]);
