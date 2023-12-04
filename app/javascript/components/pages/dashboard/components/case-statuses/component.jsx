import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { fetchCaseStatuses } from "../../action-creators";
import { getCaseStatuses } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getCaseStatuses(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;
  let role;
  let st;

  if (stats) {
    role = stats.role;
    st = stats.data;
  }

  useEffect(() => {
    dispatch(fetchCaseStatuses());
  }, []);

  return (
    <>
      {stats && <h2>Case Status</h2>}
      {stats && (
        <div>
          {role === "CP Manager" && (
            <div className={css.container}>
              <div className={css.card} style={{ backgroundColor: "rgb(255, 99, 132)" }} flat>
                <div className={css.perc}>{st.registered}</div>
                <div className={css.text}>Registered Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(54, 162, 235)" }} flat>
                <div className={css.perc}>{st.significant_harm}</div>
                <div className={css.text}>Significant Harm Cases</div>
              </div>
            </div>
          )}
          {role === "CPO" && (
            <div className={css.container}>
              <div className={css.card} style={{ backgroundColor: "rgb(255, 99, 132)" }} flat>
                <div className={css.perc}>{st.registered}</div>
                <div className={css.text}>Registered Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(54, 162, 235)" }} flat>
                <div className={css.perc}>{st.significant_harm}</div>
                <div className={css.text}>Significant Harm Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(128, 0, 128)" }} flat>
                <div className={css.perc}>{st.resolved}</div>
                <div className={css.text}>Resolved Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(255, 205, 86)" }} flat>
                <div className={css.perc}>{st.closed}</div>
                <div className={css.text}>Closed Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(54, 170, 89)" }} flat>
                <div className={css.perc}>{st.assigned_to_me}</div>
                <div className={css.text}>Cases Assigned to Me</div>
              </div>
            </div>
          )}
          {role === "CPI In-charge" && (
            <div className={css.container}>
              <div className={css.card} style={{ backgroundColor: "rgb(255, 99, 132)" }} flat>
                <div className={css.perc}>{st.registered}</div>
                <div className={css.text}>Registered Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(54, 162, 235)" }} flat>
                <div className={css.perc}>{st.significant_harm}</div>
                <div className={css.text}>Significant Harm Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(54, 170, 89)" }} flat>
                <div className={css.perc}>{st.pending}</div>
                <div className={css.text}>Pending to be Assigned Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(128, 0, 128)" }} flat>
                <div className={css.perc}>{st.resolved}</div>
                <div className={css.text}>Resolved Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(255, 205, 86)" }} flat>
                <div className={css.perc}>{st.closed}</div>
                <div className={css.text}>Closed Cases</div>
              </div>
            </div>
          )}
          {(role === "FTR Manager" || role === "Referral") && (
            <div className={css.container}>
              <div className={css.card} style={{ backgroundColor: "rgb(255, 99, 132)" }} flat>
                <div className={css.perc}>{st.registered}</div>
                <div className={css.text}>Registered Cases</div>
              </div>
              <div className={css.card} style={{ backgroundColor: "rgb(54, 162, 235)" }} flat>
                <div className={css.perc}>{st.significant_harm}</div>
                <div className={css.text}>Significant Harm Cases</div>
              </div>
            </div>
          )}
        </div>
      )}
    </>
  );
};

Component.displayName = `CaseStatuses`;

export default Component;
