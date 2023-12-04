import { RECORD_PATH } from "../../../config";
import { DB_COLLECTIONS_NAMES } from "../../../db";

import actions from "./actions";

export const fetchFlags = (recordType, activeOnly = false) => {
  const commonPath = `record_type=${recordType}`;
  const path = activeOnly
    ? `${RECORD_PATH.flags}?active_only=true&${commonPath}`
    : `${RECORD_PATH.flags}?${commonPath}`;

  return {
    type: actions.DASHBOARD_FLAGS,
    api: {
      path
    }
  };
};

export const fetchCasesByStatus = () => {
  return {
    type: actions.CASES_BY_STATUS,
    payload: {
      casesByStatus: {
        open: "100",
        closed: "100"
      }
    }
  };
};

export const fetchCaseStatuses = () => ({
  type: actions.CASE_STATUSES,
  api: {
    path: "dashboards/get_child_statuses"
  }
});

export const fetchCasesByCaseWorker = () => {
  return {
    type: actions.CASES_BY_CASE_WORKER,
    payload: {
      casesByCaseWorker: [
        {
          case_worker: "Case Worker 1",
          assessment: "2",
          case_plan: "1",
          follow_up: "0",
          services: "1"
        },
        {
          case_worker: "Case Worker 2",
          assessment: "2",
          case_plan: "1",
          follow_up: "0",
          services: "1"
        }
      ]
    }
  };
};

export const fetchCasesRegistration = () => {
  return {
    type: actions.CASES_REGISTRATION,
    payload: {
      casesRegistration: {
        jan: 150,
        feb: 100,
        mar: 50,
        apr: 120,
        may: 200,
        jun: 100,
        jul: 80,
        aug: 50,
        sep: 120
      }
    }
  };
};

export const fetchCasesOverview = () => {
  return {
    type: actions.CASES_OVERVIEW,
    payload: {
      casesOverview: {
        transfers: 4,
        waiting: 1,
        pending: 1,
        rejected: 1
      }
    }
  };
};

export const fetchServicesStatus = () => {
  return {
    type: actions.SERVICES_STATUS,
    payload: {
      services: {
        caseManagement: [
          { status: "in_progress", high: 4, medium: 0, low: 1 },
          { status: "near_deadline", high: 1, medium: 0, low: 0 },
          { status: "overdue", high: 1, medium: 0, low: 1 }
        ],
        screening: [
          { status: "in_progress", high: 4, medium: 0, low: 1 },
          { status: "near_deadline", high: 1, medium: 0, low: 0 },
          { status: "overdue", high: 1, medium: 0, low: 1 }
        ]
      }
    }
  };
};

export const openPageActions = payload => {
  return {
    type: actions.OPEN_PAGE_ACTIONS,
    payload
  };
};

export const fetchDashboards = () => ({
  type: actions.DASHBOARDS,
  api: {
    path: RECORD_PATH.dashboards,
    db: {
      collection: DB_COLLECTIONS_NAMES.DASHBOARDS
    }
  }
});

/* ====================================== */
/*                 Graphs                 */
/* ====================================== */

// 'Percentage of Children who received Child Protection Services'
export const fetchPercentageChildrenReceivedChildProtectionServices = () => ({
  type: actions.PERCENTAGE_OF_CHILDREN_WHO_RECEIVED_CHILD_PROTECTION_SERVICES,
  api: {
    path: "dashboards/percentage_children_received_child_protection_services"
  }
});

// 'Closed Cases by Sex and Reason'
export const fetchResolvedCasesByGenderAndReason = () => ({
  type: actions.RESOLVED_CASES_BY_GENDER_AND_REASON,
  api: {
    path: "dashboards/resolved_cases_by_gender_and_reason"
  }
});

// 'Cases Referrals (To Agency)'
export const fetchCasesReferralsToAgency = () => ({
  type: actions.CASES_REFERRALS_TO_AGENCY,
  api: {
    path: "dashboards/cases_referrals_to_agency"
  }
});

// 'Cases requiring Alternative Care Placement Services'
export const fetchCasesRequiringAlternativeCarePlacementServices = () => ({
  type: actions.CASES_REQUIRING_ALTERNATIVE_CARE_PLACEMENT_SERVICES,
  api: {
    path: "dashboards/alternative_care_placement_by_gender"
  }
});

// 'Registered and Closed Cases by Month'
export const fetchMonthlyRegisteredAndResolvedCases = () => ({
  type: actions.MONTHLY_REGISTERED_AND_RESOLVED_CASES,
  api: {
    path: "dashboards/month_wise_registered_and_resolved_cases_stats"
  }
});

// 'High Risk Cases by Protection Concern'
export const fetchHighRiskCasesByProtectionConcern = () => ({
  type: actions.HIGH_RISK_CASES_BY_PROTECTION_CONCERN,
  api: {
    path: "dashboards/high_risk_cases_by_protection_concern"
  }
});

// 'Registered Cases by Protection Concern'
export const fetchRegisteredCasesByProtectionConcern = () => ({
  type: actions.REGISTERED_CASES_BY_PROTECTION_CONCERN,
  api: {
    path: "dashboards/registered_cases_by_protection_concern"
  }
});

// 'Community based Child Protection Committees'
export const fetchCommunityBasedChildProtectionCommittees = () => ({
  type: actions.COMMUNITY_BASED_CHILD_PROTECTION_COMMITTEES,
  api: {
    path: "dashboards/community_based_child_protection_committees"
  }
});

// 'Community Engagement Sessions'
export const fetchCommunityEngagementSessions = () => ({
  type: actions.COMMUNITY_ENGAGEMENT_SESSIONS,
  api: {
    path: "dashboards/community_engagement_sessions"
  }
});

// 'Cases at a Glance'
export const fetchCasesAtAGlance = () => ({
  type: actions.CASES_AT_A_GLANCE,
  api: {
    path: "dashboards/cases_at_a_glance"
  }
});

// 'Cases Source'
export const fetchCasesSource = () => ({
  type: actions.CASES_SOURCE,
  api: {
    path: "dashboards/cases_source"
  }
});

// 'Custody with Court Order'
export const fetchCustodyWithCourtOrder = () => ({
  type: actions.CUSTODY_WITH_COURT_ORDER,
  api: {
    path: "dashboards/custody_with_court_order"
  }
});

// 'Police Cases'
export const fetchPoliceCases = () => ({
  type: actions.POLICE_CASES,
  api: {
    path: "dashboards/police_cases"
  }
});

// 'Cases Requiring Special Consideration'
export const fetchCasesRequiringSpecialConsideration = () => ({
  type: actions.CASES_REQUIRING_SPECIAL_CONSIDERATION,
  api: {
    path: "dashboards/cases_requiring_special_consideration"
  }
});
