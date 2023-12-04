/* eslint-disable no-param-reassign */

import ChartJS from "chart.js";
import { createRef, useEffect } from "react";
import PropTypes from "prop-types";
import makeStyles from "@material-ui/core/styles/makeStyles";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Chart = ({ type, data, description, showDetails, options }) => {
  const css = useStyles();
  const chartRef = createRef();

  useEffect(() => {
    const chatCtx = chartRef.current.getContext("2d");

    if (options) {
      options.scales.yAxes[0].ticks = {
        beginAtZero: true,
        min: 0,
        suggestedMin: 0,
        precision: 0,
        display: false
      };

      if (type === "pie" || type === "doughnut") {
        options.legend = {
          position: "top"
        };

        options.tooltips = {
          callbacks: {
            label(tooltipItem, data) {
              // Get the Concerned Dataset
              const dataset = data.datasets[tooltipItem.datasetIndex];
              // Calculate the Total of this Dataset
              const total = dataset.data.reduce((previousValue, currentValue, currentIndex, array) => {
                return previousValue + currentValue;
              });
              // Get the Current Item's Value
              const currentValue = dataset.data[tooltipItem.index];
              // Calculate the percentage based on the total and current item,
              // Also this does a rough rounding to give a whole number
              const percentage = Math.floor((currentValue / total) * 100 + 0.5);

              return ` ${dataset.label[tooltipItem.index]} ${percentage}% | ${currentValue} Record(s)`;
            }
          }
        };
      }
    }

    /* eslint-disable no-new */
    const chartInstance = new ChartJS(chatCtx, {
      type: type || "line",
      data,
      options: {
        ...options,
        responsive: true,
        animation: {
          duration: 0
        },
        maintainAspectRatio: false
        // legend: {
        //   display: showDetails
        // },
        // tooltips: {
        //   callbacks: {
        //     label: (tooltipItem, chartData) => {
        //       const { label } = chartData.datasets[tooltipItem.datasetIndex];
        //       let { value } = tooltipItem;

        //       if (value === "0.1") {
        //         value = "0";
        //       }

        //       return `${label}: ${value}`;
        //     }
        //   }
        // },
        // scales: {
        //   yAxes: [
        //     {
        //       display: showDetails,
        //       ticks: {
        //         beginAtZero: true,
        //         min: 0,
        //         suggestedMin: 0
        //       }
        //     }
        //   ],
        //   xAxes: [
        //     {
        //       display: showDetails,
        //       min: 0,
        //       suggestedMin: 0,
        //       ticks: {
        //         callback: value => {
        //           if (value?.length > 25) {
        //             return value.substr(0, 25).concat("...");
        //           }

        //           return value;
        //         }
        //       }
        //     }
        //   ]
        // }
      }
    });

    return () => {
      chartInstance.destroy();
    };
  });

  return (
    <>
      {!showDetails ? <p className={css.description}>{description}</p> : null}
      <canvas id="reportGraph" ref={chartRef} height={!showDetails ? null : 400} />
    </>
  );
};

Chart.displayName = "Chart";

Chart.defaultProps = {
  showDetails: false
};

Chart.propTypes = {
  data: PropTypes.object,
  description: PropTypes.string,
  options: PropTypes.object,
  showDetails: PropTypes.bool,
  type: PropTypes.string
};

export default Chart;
