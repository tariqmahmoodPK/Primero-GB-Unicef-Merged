// 'Cases at a Glance'

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import Grid from "@material-ui/core/Grid";

import { BarChart } from "../../../../charts";
import { fetchCasesAtAGlance } from "../../action-creators";
import { getCasesAtAGlance } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getCasesAtAGlance(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  useEffect(() => {
    dispatch(fetchCasesAtAGlance());
  }, []);

  let graphData;

  const chartOptions = {
    scales: {
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Cases Status",
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
          label: "Cases at a Glance",
          data: values,
          backgroundColor: [
            "rgb(0, 0, 255)", // Blue
            "rgb(0, 128, 0)", // Green
            "rgb(255, 165, 0)", // Orange
            "rgb(255, 0, 0)", // Red
            "rgb(255, 255, 0)", // Yellow
            "rgb(32, 195, 255)", // Light Blue
            "rgb(128, 128, 128)", // Grey
            "rgb(139, 0, 0)" // Dark Red
          ]
        }
      ]
    };
  }

  return (
    stats && (
      <Grid item md={6} xl={6}>
        <div className={css.container}>
          <h2>Cases at a Glance</h2>
          <div className={css.card} flat>
            <BarChart data={graphData} options={chartOptions} showDetails showLegend={false} />
          </div>
        </div>
      </Grid>
    )
  );
};

Component.displayName = "CasesAtAGlance";

export default Component;
