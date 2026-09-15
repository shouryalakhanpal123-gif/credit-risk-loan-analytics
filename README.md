# Credit Risk & Loan Approval Analytics — SQL

## 📌 Project Overview

This project focuses on analyzing customer credit profiles, loan applications, default behaviour, and transaction patterns using **Microsoft SQL Server**.

The SQL analytics layer is the foundation of the Credit Risk & Loan Approval Analytics Platform. It transforms raw relational data into meaningful business insights that can later be used for Machine Learning, Risk Scoring, and BI Dashboard development.

---

## 🎯 Business Objective

The objective is to analyze loan and customer data to:

- Understand customer credit profiles
- Analyze loan approval and rejection trends
- Segment customers based on income and employment
- Identify high-risk customers
- Measure loan default rates
- Analyze loan amount patterns
- Track monthly approval statistics
- Categorize customers by credit risk
- Understand transaction behaviour
- Identify potential predictors of loan default

---

## 🛠️ Technology Used

- **Database:** Microsoft SQL Server 2025
- **Language:** T-SQL
- **Database Tool:** SQL Server Management Studio (SSMS)
- **Data Source:** CSV datasets

---

## 📂 Dataset Structure

The project uses four relational datasets:

### 1. customers

Contains customer demographic and financial information.

Key fields:

- `customer_id`
- `first_name`
- `last_name`
- `gender`
- `age`
- `marital_status`
- `dependents`
- `education`
- `employment_type`
- `annual_income`
- `city`
- `state`
- `residence_type`
- `years_at_residence`
- `kyc_status`
- `customer_since`

### 2. credit_history

Contains customer credit bureau information.

Key fields:

- `credit_id`
- `customer_id`
- `credit_score`
- `num_open_accounts`
- `num_credit_inquiries_6m`
- `credit_utilization_ratio`
- `num_late_payments_30d`
- `num_late_payments_90d`
- `num_defaults_prior`
- `bankruptcies`
- `total_credit_limit`
- `total_outstanding_debt`
- `oldest_account_age_months`

### 3. loan_applications

Contains loan application and outcome information.

Key fields:

- `application_id`
- `customer_id`
- `application_date`
- `loan_type`
- `loan_purpose`
- `requested_amount`
- `loan_term_months`
- `interest_rate`
- `debt_to_income_ratio`
- `collateral_flag`
- `approval_status`
- `approved_amount`
- `disbursed_flag`
- `loan_default`

### 4. transactions

Contains customer transaction behaviour.

Key fields:

- `transaction_id`
- `customer_id`
- `transaction_date`
- `transaction_type`
- `category`
- `channel`
- `amount`
- `balance_after`

---

# 📊 Analytical SQL Questions

The project answers the following key business questions:

### 1. Credit Score Analysis

Analyze minimum, maximum, average, and median credit scores.

**Business use:** Understand the overall credit quality of the customer base.

---

### 2. Loan Approval Trends

Analyze monthly:

- Total applications
- Approved applications
- Rejected applications
- Applications under review

**Business use:** Identify changes in lending and approval behaviour over time.

---

### 3. Customer Segmentation

Segment customers based on:

- Income
- Employment type

**Business use:** Understand different customer segments and their financial profiles.

---

### 4. High-Risk Customer Identification

Identify customers with risk indicators such as:

- Low credit score
- High credit utilization
- Recent late payments
- Previous defaults

**Business use:** Support early identification of potentially risky borrowers.

---

### 5. Default Rate Analysis

Calculate:

- Total disbursed loans
- Number of defaults
- Overall default rate
- Default rate by loan type

**Business use:** Understand portfolio credit risk and identify loan types with higher default rates.

---

### 6. Loan Amount Distribution

Analyze loan amounts by loan type using:

- Minimum
- Maximum
- Average
- Median

**Business use:** Understand lending patterns and typical loan sizes.

---

### 7. Monthly Approval Statistics

Calculate monthly:

- Applications
- Approved loans
- Rejected loans
- Under-review applications
- Approval rate

**Business use:** Monitor lending performance over time.

---

### 8. Risk Categorisation

Create rule-based risk categories:

- Low Risk
- Medium Risk
- High Risk

based on credit score, utilization, and prior defaults.

**Business use:** Create an initial risk segmentation before Machine Learning.

> Note: This is a preliminary rule-based categorisation. The final project uses an ML-based probability of default and risk score.

---

### 9. Transaction Behaviour Analysis

Aggregate customer transactions to calculate:

- Transaction count
- Total inflow
- Total outflow
- Net cash flow
- Average balance

**Business use:** Understand customer financial behaviour and cash-flow patterns.

---

### 10. Default Predictor Analysis

Analyze relationships between default and important risk variables such as:

- Credit score
- Debt-to-income ratio
- Previous defaults

**Business use:** Identify variables that may be useful for the Machine Learning default prediction model.

---

# 🗂️ SQL Project Structure

```text
sql/
│
├── 01_credit_score_analysis.sql
├── 02_loan_approval_trends.sql
├── 03_customer_segmentation.sql
├── 04_high_risk_customers.sql
├── 05_default_rate_analysis.sql
├── 06_loan_amount_distribution.sql
├── 07_monthly_approval_statistics.sql
├── 08_risk_categorisation.sql
├── 09_transaction_behaviour.sql
└── 10_default_predictors.sql
