// 'Registered and Closed Cases by Month'

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { Chart } from "../../../../charts";
import { fetchMonthlyRegisteredAndResolvedCases } from "../../action-creators";
import { getMonthlyRegisteredAndResolvedCases } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getMonthlyRegisteredAndResolvedCases(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  useEffect(() => {
    dispatch(fetchMonthlyRegisteredAndResolvedCases());
  }, []);

  let graphData;

  let detailed = {};

  if (stats) {
    detailed = stats;
    const labels = [];
    const reg = [];
    const res = [];
    let statsArr = [];
    const registered = stats.Registered;
    const resolved = stats.Resolved;

    for (const key in registered) {
      const t = {
        name: key,
        reg: registered[key].total,
        res: resolved[key].total
      };

      statsArr.push(t);
    }

    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const date = new Date();
    const thisIndex = date.getMonth();
    const lastMonths = months.splice(0, thisIndex + 1);
    const startMonths = months.splice(thisIndex, 11);
    const newMonth = [...startMonths, ...lastMonths];

    statsArr = statsArr.sort((a, b) => {
      return newMonth.indexOf(a.name) - newMonth.indexOf(b.name);
    });

    for (const obj of statsArr) {
      labels.push(obj.name);
      reg.push(obj.reg);
      res.push(obj.res);
    }

    graphData = {
      labels,
      datasets: [
        {
          label: "Closed",
          data: res,
          backgroundColor: "rgba(54, 162, 235)",
          borderColor: "rgb(54, 162, 235)",
          borderWidth: 1,
          fill: false
        },
        {
          label: "Registered",
          data: reg,
          backgroundColor: "rgba(255, 159, 64)",
          borderColor: "rgb(255, 159, 64)",
          borderWidth: 1,
          fill: false
        }
      ]
    };
  }

  const chartOptions = {
    scales: {
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Month",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Number of Cases",
            fontColor: "green"
          }
        }
      ]
    },
    tooltips: {
      callbacks: {
        // eslint-disable-next-line no-shadow
        label(tooltipItem, data) {
          const seriesName = data.datasets[tooltipItem.datasetIndex].label;
          const month = tooltipItem.label;
          const { value } = tooltipItem;
          const key = seriesName === "Closed" ? "Resolved" : "Registered";
          const details = detailed[key][month] || null;
          let html = `${seriesName} (${value}) `;

          if (details) {
            html += `Male: ${details.male} `;
            html += `Female: ${details.female} `;
            html += `Transgender: ${details.transgender}`;
          }

          return html;
        }
      }
    }
  };

  return (
    <>
      {graphData && (
        <Grid item md={6} xl={6}>
          <div className={css.container}>
            <h2>Registered and Closed Cases by Month</h2>
            <div className={css.card} flat>
              <Chart options={chartOptions} data={graphData} showDetails />
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

Component.displayName = `MonthlyRegisteredAndResolvedCases`;

export default Component;
