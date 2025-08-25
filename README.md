# P-Hacking Simulation: Finding Significance Where None Exists

This R project demonstrates the concept of "p-hacking" (also known as data dredging or significance chasing). The script runs a simulation to show how applying multiple common, yet questionable, research practices to a dataset with no true effects can dramatically increase the chances of finding a statistically significant, but ultimately meaningless, result (a false positive, p < 0.05).

---

## 🔬 The Simulation

The core of this project is a simulation that runs 1,000 times. In each iteration, it generates a random dataset where the independent variable `X` and the dependent variable `Y` have **no actual relationship**.

Then, it applies a series of p-hacking techniques to try and force a significant p-value:
1.  **Overfitting**: It tests multiple models, progressively adding irrelevant control variables (`Z1`, `Z2`, etc.).
2.  **Subgroup Analysis**: It runs the analysis on different subsets of the data (e.g., the top half, the bottom half, a random sample).
3.  **Variable Transformation**: It applies various mathematical transformations (`log`, `sqrt`, `squared`) to the dependent variable `Y`.

If **any** of these dozens of tests within a single simulation yields a p-value less than 0.05, the entire simulation is flagged as having found a "significant" result.

---

## 🚀 How to Run

1.  **Prerequisites**: Make sure you have R and the `tidyverse` package (which includes `ggplot2`) installed. If you don't have it, run this command in your R console:
    ```R
    install.packages("tidyverse")
    ```
2.  **Execute the Script**: Open the R script in R or RStudio and run the entire file. No modifications are needed.

---

## 📊 Interpreting the Output

The script will produce two key outputs:

### 1. Console Output
A line will be printed in the console showing the final proportion of the 1,000 simulations that found at least one false-positive result.

This number demonstrates how the "researcher's degrees of freedom" can inflate the false positive rate far above the nominal 5% alpha level.

### 2. Visualization
A bar chart will be generated in the R plot viewer. This plot provides a clear visual comparison between the number of simulations that resulted in a false positive ("Found a 'Significant' Result") versus those that did not, making the final takeaway easy to understand.
