// 'Community based Child Protection Committees'

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { Chart } from "../../../../charts";
import { fetchCommunityBasedChildProtectionCommittees } from "../../action-creators";
import { getCommunityBasedChildProtectionCommittees } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getCommunityBasedChildProtectionCommittees(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  useEffect(() => {
    dispatch(fetchCommunityBasedChildProtectionCommittees());
  }, []);

  let graphData;

  if (stats) {
    const labels = [];
    const genderStats = [];

    for (const key in stats) {
      labels.push(key);
      genderStats.push(stats[key]);
    }

    graphData = {
      labels,
      datasets: [
        {
          label: labels,
          data: genderStats,
          backgroundColor: [
            "rgb(255, 99, 132)",
            "rgb(54, 162, 235)",
            "rgb(255, 205, 86)",
            "rgb(128, 0, 128)",
            "rgb(150, 75, 0)",
            "rgb(54, 170, 89)",
            "rgb(254, 170, 89)"
          ],
          hoverOffset: 6
        }
      ]
    };
  }

  const chartOptions = {
    scales: {
      xAxes: [
        {
          ticks: {
            display: false
          },
          gridLines: {
            display: false
          },
          scaleLabel: {
            display: false,
            labelString: "Time in Seconds",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          ticks: {
            display: false
          },
          gridLines: {
            display: false
          },
          scaleLabel: {
            display: false,
            labelString: "Speed in Miles per Hour",
            fontColor: "green"
          }
        }
      ]
    }
  };

  return (
    <>
      {graphData && (
        <Grid item xl={6} md={6} xs={12}>
          <div className={css.container}>
            <h2>Community based Child Protection Committees</h2>
            <div className={css.card} flat>
              <Chart type="doughnut" options={chartOptions} data={graphData} showDetails />
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

Component.displayName = `CommunityBasedChildProtectionCommittees`;

export default Component;
