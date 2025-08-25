# ------------------------------------------------------
# FILE NAME: Impact_Eval_Challenge_1.R
# AUTHOR: Dylan Craig
# DATE CREATED: November 28, 2024
# DATE MODIFIED: August 25, 2025
#
# PURPOSE:
# Simulate p-hacking by generating random datasets and applying multiple modeling
# strategies (e.g., adding irrelevant covariates, analyzing subsets, and
# transforming variables) to demonstrate how false positives can arise. The script
# also visualizes the proportion of significant p-values across simulations.
# ------------------------------------------------------

# Load libraries
library(tidyverse)

# Set seed for reproducibility
set.seed(12345)

# Simulation parameters
n <- 1000          # Number of observations per simulation
iterations <- 1000  # Number of simulations

# Placeholder for results
results <- data.frame(iteration = integer(), significant = logical())

# Function to test a model and check if p-value for X is < 0.05
test_model <- function(formula, data) {
  # Use a tryCatch block to handle cases where a model might fail (e.g., subset is too small)
  tryCatch({
    model <- lm(as.formula(formula), data = data)
    p_value <- summary(model)$coefficients["X", "Pr(>|t|)"]
    return(p_value < 0.05)
  }, error = function(e) {
    # If an error occurs, return FALSE (not significant)
    return(FALSE)
  })
}

# -------------------- Simulation --------------------
for (i in 1:iterations) {
  # Generate data where X and Y have no true relationship
  data <- data.frame(
    X = rnorm(n),
    Y = rnorm(n),
    Z1 = rnorm(n),
    Z2 = rnorm(n),
    Z3 = rnorm(n),
    Z4 = rnorm(n),
    Z5 = rnorm(n)
  )
  
  # Initialize significant flag for this iteration
  significant <- FALSE
  
  # 1. Overfitting: Test models with increasing irrelevant covariates
  significant <- significant || any(
    test_model("Y ~ X", data),
    test_model("Y ~ X + Z1", data),
    test_model("Y ~ X + Z1 + Z2", data),
    test_model("Y ~ X + Z1 + Z2 + Z3", data),
    test_model("Y ~ X + Z1 + Z2 + Z3 + Z4", data),
    test_model("Y ~ X + Z1 + Z2 + Z3 + Z4 + Z5", data)
  )
  
  # 2. Subsets: Test models on data subsets
  top_half <- data %>% filter(Y > median(Y))
  bottom_half <- data %>% filter(Y <= median(Y))
  random_subset <- data %>% sample_frac(0.5)
  
  significant <- significant || any(
    test_model("Y ~ X", top_half),
    test_model("Y ~ X", bottom_half),
    test_model("Y ~ X", random_subset)
  )
  
  # 3. Transformations: Apply multiple transformations to Y
  data_transformed <- data %>%
    mutate(
      Y_log = log(abs(Y) + 1), # Avoid log of negative numbers
      Y_sqrt = sqrt(abs(Y)),
      Y_squared = Y^2,
      Y_exp = exp(-abs(Y))
    )
  
  significant <- significant || any(
    test_model("Y_log ~ X", data_transformed),
    test_model("Y_sqrt ~ X", data_transformed),
    test_model("Y_squared ~ X", data_transformed),
    test_model("Y_exp ~ X", data_transformed)
  )
  
  # Record result for the iteration
  results <- rbind(results, data.frame(iteration = i, significant = significant))
}

# -------------------- Summarize Results --------------------
# Calculate and print the proportion of iterations with at least one significant result
proportion_significant <- mean(results$significant)
cat("Proportion of iterations with at least one significant p-value:", proportion_significant, "\n")

# -------------------- Visualization --------------------
# Prepare data for a more informative plot
plot_data <- results %>%
  count(significant) %>%
  mutate(
    Category = ifelse(significant, "Found a 'Significant' Result", "No Significant Result"),
    Percentage = n / sum(n)
  )

# Create an improved bar chart
ggplot(plot_data, aes(x = Category, y = Percentage, fill = Category)) +
  geom_col(width = 0.6, color = "black") +
  geom_text(aes(label = scales::percent(Percentage, accuracy = 0.1)), vjust = -0.5, size = 5) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  scale_fill_manual(values = c("Found a 'Significant' Result" = "#d95f02", "No Significant Result" = "#7570b3")) +
  labs(
    title = "P-Hacking Simulation Results",
    subtitle = paste("Proportion of", iterations, "Simulations Finding at Least One False Positive (p < 0.05)"),
    x = "",
    y = "Proportion of Simulations"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 12, margin = margin(b = 20)),
    axis.text.x = element_text(size = 12, face = "bold"),
    panel.grid.major.x = element_blank()
  )