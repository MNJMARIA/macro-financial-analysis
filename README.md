# Analysis and Forecasting of Investment Asset Returns under Macroeconomic Factors

[![Python](https://img.shields.io/badge/Python-3.8+-blue)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains the course project for the discipline "Data Analysis in Information Systems" at Igor Sikorsky Kyiv Polytechnic Institute (KPI). The project aims to investigate the impact of key macroeconomic factors (GDP, inflation, real interest rates, unemployment) on the returns of stocks and cryptocurrencies.

## Architecture & Technology Stack

The project is built upon a multidimensional data warehouse model (star schema) with a complete ETL pipeline implementation.

- **Programming Language:** Python
- **Database:** Oracle / SQL (for the data warehouse)
- **Key Libraries:** Pandas, Scikit-learn, Statsmodels, TensorFlow/Keras, SQLAlchemy
- **Data Sources:** Kaggle (stock prices, cryptocurrency prices, GDP, inflation, real interest rates, unemployment data)

## Project Structure

### 1. Data Warehouse
- Design of a multidimensional model (star schema)
- Development of ETL processes for loading, cleaning, and transforming data

### 2. Data Analysis & Modeling
- **Correlation Analysis:** Identifying linear relationships between macroeconomic factors and asset returns
- **Regression Analysis:** Building and comparing linear, multiple, and polynomial regression models
- **Classification:** Predicting market direction using KNN, Decision Tree, Random Forest, AdaBoost, and SVC
- **Time Series Forecasting:** Building and comparing ARIMA, SARIMAX, and LSTM models

## Key Results

- For stocks, a weak linear correlation with macroeconomic factors was found, with the exception of unemployment (r = 0.48)
- Cryptocurrencies demonstrated a strong dependency on U.S. macroeconomics (especially real interest rates and inflation)
- The SARIMAX model, which accounts for exogenous factors, delivered the best forecasting performance
- The LSTM neural network showed promising results but requires a larger dataset for improved generalization

## How to Run the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/macro-financial-analysis.git
   ```

2. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the Jupyter Notebook or Python scripts to reproduce the analysis and results

## Limitations & Future Work

The main limitation of this work is the small dataset size, especially for cryptocurrencies (only 8 annual observations). To improve model accuracy and draw more robust conclusions, future work should incorporate monthly or daily granularity data and expand the set of macroeconomic factors.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Author:** Mariia Stepanova, Igor Sikorsky Kyiv Polytechnic Institute (2025)
