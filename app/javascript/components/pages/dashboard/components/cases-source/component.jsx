// 'Cases Source'

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { BarChart } from "../../../../charts";
import { fetchCasesSource } from "../../action-creators";
import { getCasesSource } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getCasesSource(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  useEffect(() => {
    dispatch(fetchCasesSource());
  }, []);

  let graphData;

  const chartOptions = {
    scales: {
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Case Sources",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Number Of Cases",
            fontColor: "green"
          }
        }
      ]
    }
  };

  if (stats) {
    const data = stats;
    const labels = [];
    const values = [];

    for (const key in data) {
      labels.push(key);
    }

    for (const key in data) {
      values.push(data[key]);
    }

    graphData = {
      labels,
      datasets: [
        {
          label: "Case Sources",
          data: values,
          backgroundColor: [
            "rgb(0, 0, 255)", // Blue
            "rgb(255, 0, 0)", // Red
            "rgb(0, 255, 0)", // Green
            "rgb(255, 255, 0)", // Yellow
            "rgb(255, 0, 255)", // Magenta
            "rgb(0, 255, 255)", // Cyan
            "rgb(255, 165, 0)", // Orange
            "rgb(0, 128, 0)", // Dark Green
            "rgb(225, 221, 0)",
            "rgb(100, 0, 255)",
            "rgb(128, 0, 128)", // Purple
            "rgb(128, 0, 0)", // Maroon
            "rgb(0, 128, 128)", // Teal
            "rgb(255, 140, 0)" // Dark Orange
          ]
        }
      ]
    };
  }

  return (
    stats && (
      <Grid item md={6} xl={6}>
        <div className={css.container}>
          <h2>Source of Cases</h2>
          <div className={css.card} flat>
            <BarChart data={graphData} options={chartOptions} showDetails showLegend={false} />
          </div>
        </div>
      </Grid>
    )
  );
};

Component.displayName = "CasesSource";

export default Component;
