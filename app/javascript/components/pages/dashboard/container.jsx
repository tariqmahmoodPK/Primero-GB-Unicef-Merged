// Dashboard Component that import all the Graphs in it.

/* eslint-disable react/jsx-no-target-blank */
/* eslint-disable global-require */

import { useEffect } from "react";
import { useDispatch } from "react-redux";
import { Grid } from "@material-ui/core";

import { useI18n } from "../../i18n";
import PageContainer, { PageHeading, PageContent } from "../../page";
import { getPermissions } from "../../user/selectors";
import { getLoading, getErrors } from "../../index-table";
import { OfflineAlert } from "../../disable-offline";
import { usePermissions, ACTIONS, RESOURCES } from "../../permissions";
import { RECORD_PATH } from "../../../config";
import { useMemoizedSelector } from "../../../libs";

import {
  Approvals,
  CasesBySocialWorker,
  CasesToAssign,
  Flags,
  OverdueTasks,
  Overview,
  PerpetratorArmedForceGroupPartyNames,
  ProtectionConcern,
  ReportingLocation,
  SharedFromMyTeam,
  SharedWithMyTeam,
  ViolationsCategoryRegion,
  ViolationsCategoryVerificationStatus,
  WorkflowIndividualCases,
  WorkflowTeamCases,
  // 'Percentage of Children who received Child Protection Services'
  PercentageChildrenReceivedChildProtectionServices,
  // 'Closed Cases by Sex and Reason'
  ResolvedCasesByGenderAndReason,
  // 'Cases Referrals (To Agency)'
  CasesReferralsToAgency,
  // 'Cases requiring Alternative Care Placement Services'
  CasesRequiringAlternativeCarePlacementServices,
  // 'Registered and Closed Cases by Month'
  MonthlyRegisteredAndResolvedCases,
  // 'High Risk Cases by Protection Concern'
  HighRiskCasesByProtectionConcern,
  // 'Registered Cases by Protection Concern'
  RegisteredCasesByProtectionConcern,
  // 'Community based Child Protection Committees'
  CommunityBasedChildProtectionCommittees,
  // 'Community Engagement Sessions'
  CommunityEngagementSessions,
  // 'Cases at a Glance'
  CasesAtAGlance,
  // 'Cases Source'
  CasesSource,
  CaseStatuses,
  // 'Custody with Court Order'
  CustodyWithCourtOrder,
  // 'Police Cases'
  PoliceCases,
  // 'Cases Requiring Special Consideration'
  CasesRequiringSpecialConsideration
} from "./components";
import NAMESPACE from "./namespace";
import { NAME } from "./constants";
import { fetchDashboards, fetchFlags } from "./action-creators";

const Dashboard = () => {
  const i18n = useI18n();
  const dispatch = useDispatch();
  const canFetchFlags = usePermissions(RESOURCES.dashboards, [ACTIONS.DASH_FLAGS]);

  useEffect(() => {
    dispatch(fetchDashboards());

    if (canFetchFlags) {
      dispatch(fetchFlags(RECORD_PATH.cases, true));
    }
  }, []);

  const userPermissions = useMemoizedSelector(state => getPermissions(state));
  const loading = useMemoizedSelector(state => getLoading(state, NAMESPACE));
  const errors = useMemoizedSelector(state => getErrors(state, NAMESPACE));
  const loadingFlags = useMemoizedSelector(state => getLoading(state, [NAMESPACE, "flags"]));
  const flagsErrors = useMemoizedSelector(state => getErrors(state, [NAMESPACE, "flags"]));

  const indicatorProps = {
    overlay: true,
    type: NAMESPACE,
    loading,
    errors
  };

  const flagsIndicators = {
    overlay: true,
    type: NAMESPACE,
    loading: loadingFlags,
    errors: flagsErrors
  };

  return (
    <PageContainer>
      <Grid container style={{ alignItems: 'center' }} item xl={12} md={12} xs={12}>
        <Grid item xl={6} md={6} xs={12}>
          <PageHeading title={i18n.t("navigation.home")} />
        </Grid>
        <Grid item xl={6} md={6} xs={12} style={{ textAlign: 'right' }}>
          <a
            style={{ fontSize: 20, fontWeight: 600, textAlign: 'right' }}
            href="/download_package.zip"
            download
            target="_blank"
          >
            Resources
          </a>
        </Grid>
      </Grid>
      <PageContent>
        <OfflineAlert text={i18n.t("messages.dashboard_offline")} />
        <Grid container spacing={3}>
            {/*<CaseStatuses />*/}
            <Grid item xl={12} md={12} xs={12}>
              <PercentageChildrenReceivedChildProtectionServices text="Registered Cases"/>
            </Grid>
            <CasesAtAGlance />
            <RegisteredCasesByProtectionConcern /> {/* 'Registered Cases by Protection Concern' */}
            <HighRiskCasesByProtectionConcern /> {/* 'High Risk Cases by Protection Concern' */}
            <MonthlyRegisteredAndResolvedCases /> {/* Registered and Closed Cases by Month */}
            <CasesSource />
            <CasesRequiringAlternativeCarePlacementServices />
            <CasesReferralsToAgency />
            <CustodyWithCourtOrder />
            <PoliceCases />
            <CasesRequiringSpecialConsideration />
            <ResolvedCasesByGenderAndReason />
            <CommunityBasedChildProtectionCommittees />
            <CommunityEngagementSessions />
            <Grid item xl={12} md={12} xs={12}>
              <CasesToAssign loadingIndicator={indicatorProps} />
              <Approvals loadingIndicator={indicatorProps} />
              <SharedFromMyTeam loadingIndicator={indicatorProps} />
              <SharedWithMyTeam loadingIndicator={indicatorProps} />
              <OverdueTasks loadingIndicator={indicatorProps} />
              <CasesBySocialWorker loadingIndicator={indicatorProps} />
              <WorkflowTeamCases loadingIndicator={indicatorProps} />
              <ReportingLocation loadingIndicator={indicatorProps} />
              <ProtectionConcern loadingIndicator={indicatorProps} />
              <ViolationsCategoryVerificationStatus loadingIndicator={indicatorProps} />
              <ViolationsCategoryRegion loadingIndicator={indicatorProps} />
              <PerpetratorArmedForceGroupPartyNames loadingIndicator={indicatorProps} />
            </Grid>
            <Grid item xl={12} md={12} xs={12}>
              <Overview loadingIndicator={indicatorProps} userPermissions={userPermissions} />
              <PercentageChildrenReceivedChildProtectionServices text="Percentage of Children who received Child Protection Services" />
            </Grid>
          <Grid item xl={3} md={4} xs={12}>
            <Flags loadingIndicator={flagsIndicators} />
          </Grid>
        </Grid>
      </PageContent>
    </PageContainer>
  );
};

Dashboard.displayName = NAME;

export default Dashboard;
