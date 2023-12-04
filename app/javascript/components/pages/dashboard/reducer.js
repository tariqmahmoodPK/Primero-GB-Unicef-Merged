import { fromJS, Map } from "immutable";
import orderBy from "lodash/orderBy";

import actions from "./actions";
import NAMESPACE from "./namespace";
import { DASHBOARD_FLAGS_SORT_ORDER, DASHBOARD_FLAGS_SORT_FIELD } from "./constants";

const DEFAULT_STATE = Map({});

const reducer = (state = DEFAULT_STATE, { type, payload }) => {
  switch (type) {
    // 'Percentage of Children who received Child Protection Services'
    case actions.PERCENTAGE_OF_CHILDREN_WHO_RECEIVED_CHILD_PROTECTION_SERVICES_SUCCESS:
      return state.set("percentageChildrenReceivedChildProtectionServices", fromJS(payload));
    // 'Closed Cases by Sex and Reason'
    case actions.RESOLVED_CASES_BY_GENDER_AND_REASON_SUCCESS:
      return state.set("resolvedCasesByGenderAndReason", fromJS(payload));
    // 'Cases Referrals (To Agency)'
    case actions.CASES_REFERRALS_TO_AGENCY_SUCCESS:
      return state.set("casesReferralsToAgency", fromJS(payload));
    // 'Cases requiring Alternative Care Placement Services'
    case actions.CASES_REQUIRING_ALTERNATIVE_CARE_PLACEMENT_SERVICES_SUCCESS:
      return state.set("casesRequiringAlternativeCarePlacementServices", fromJS(payload));
    // 'Registered and Closed Cases by Month'
    case actions.MONTHLY_REGISTERED_AND_RESOLVED_CASES_SUCCESS:
      return state.set("monthlyRegisteredAndResolvedCases", fromJS(payload));
    // 'High Risk Cases by Protection Concern'
    case actions.HIGH_RISK_CASES_BY_PROTECTION_CONCERN_SUCCESS:
      return state.set("highRiskCasesByProtectionConcern", fromJS(payload));
    // 'Registered Cases by Protection Concern'
    case actions.REGISTERED_CASES_BY_PROTECTION_CONCERN_SUCCESS:
      return state.set("registeredCasesByProtectionConcern", fromJS(payload));
    // 'Community based Child Protection Committees'
    case actions.COMMUNITY_BASED_CHILD_PROTECTION_COMMITTEES_SUCCESS:
      return state.set("communityBasedChildProtectionCommittees", fromJS(payload));
    // 'Community Engagement Sessions'
    case actions.COMMUNITY_ENGAGEMENT_SESSIONS_SUCCESS:
      return state.set("communityEngagementSessions", fromJS(payload));
    // 'Cases at a Glance'
    case actions.CASES_AT_A_GLANCE_SUCCESS:
      return state.set("casesAtAGlance", fromJS(payload));
    // 'Cases Source'
    case actions.CASES_SOURCE_SUCCESS:
      return state.set("casesSource", fromJS(payload));
    // 'Custody with Court Order'
    case actions.CUSTODY_WITH_COURT_ORDER_SUCCESS:
      return state.set("custodyWithCourtOrder", fromJS(payload));
    // 'Police Cases'
    case actions.POLICE_CASES_SUCCESS:
      return state.set("policeCases", fromJS(payload));
    // 'Cases Requiring Special Consideration'
    case actions.CASES_REQUIRING_SPECIAL_CONSIDERATION_SUCCESS:
      return state.set("casesRequiringSpecialConsideration", fromJS(payload));
    // 'Dashboard Flags'
    case actions.DASHBOARD_FLAGS:
      return state.set("flags", fromJS(payload));
    case actions.CASES_BY_STATUS:
      return state.set("casesByStatus", fromJS(payload.casesByStatus));
    case actions.CASES_BY_CASE_WORKER:
      return state.set("casesByCaseWorker", fromJS(payload.casesByCaseWorker));
    case actions.CASES_REGISTRATION:
      return state.set("casesRegistration", fromJS(payload.casesRegistration));
    case actions.CASES_OVERVIEW:
      return state.set("casesOverview", fromJS(payload.casesOverview));
    case actions.DASHBOARDS_STARTED:
      return state.set("loading", fromJS(payload)).set("errors", false);
    case actions.CASE_STATUSES_SUCCESS:
      return state.set("caseStatuses", fromJS(payload));
    case actions.DASHBOARDS_SUCCESS:
      return state.set("data", fromJS(payload.data));
    case actions.DASHBOARDS_FINISHED:
      return state.set("loading", fromJS(payload));
    case actions.DASHBOARDS_FAILURE:
      return state.set("errors", true);
    case actions.DASHBOARD_FLAGS_STARTED:
      return state.setIn(["flags", "loading"], fromJS(payload)).setIn(["flags", "errors"], false);
    case actions.DASHBOARD_FLAGS_SUCCESS: {
      const orderedArray = orderBy(payload.data, dateObj => new Date(dateObj[DASHBOARD_FLAGS_SORT_FIELD]), [
        DASHBOARD_FLAGS_SORT_ORDER
      ]);

      return state.setIn(["flags", "data"], fromJS(orderedArray));
    }
    case actions.DASHBOARD_FLAGS_FINISHED:
      return state.setIn(["flags", "loading"], fromJS(payload));
    case actions.DASHBOARD_FLAGS_FAILURE:
      return state.setIn(["flags", "errors"], true);
    case actions.SERVICES_STATUS:
      return state.set("servicesStatus", fromJS(payload.services));
    case actions.OPEN_PAGE_ACTIONS:
      return state.set("isOpenPageActions", fromJS(payload));
    case "user/LOGOUT_SUCCESS":
      return DEFAULT_STATE;
    default:
      return state;
  }
};

export default { [NAMESPACE]: reducer };
