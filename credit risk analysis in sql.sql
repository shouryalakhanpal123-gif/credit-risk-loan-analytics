create database credore_finance
use credore_finance 

ALTER TABLE credit_history
ADD CONSTRAINT fk_credit_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE loan_applications
ADD CONSTRAINT fk_loan_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

--AVERAGE,MINIMUM,MAXIMUM CREDIT SCORE 

SELECT COUNT(*) AS TOTAL_CUSTOMERS,
ROUND(AVG(CREDIT_SCORE),2)AS AVG_CREDIT_SCORE,
MIN(CREDIT_SCORE)AS MIN_CREDIT_SCORE,
MAX(CREDIT_SCORE)AS MAX_CREDIT_SCORE
FROM credit_history

--Credit Score vs Default

SELECT 
    CASE 
        WHEN CH.CREDIT_SCORE < 500 THEN 'POOR'
        WHEN CH.CREDIT_SCORE < 650 THEN 'FAIR'
        WHEN CH.CREDIT_SCORE < 750 THEN 'GOOD'
        ELSE 'EXCELLENT'
    END AS CREDIT_SCORE_BAND,
    COUNT(*) AS TOTAL_LOANS,
    SUM(CASE WHEN LA.LOAN_DEFAULT = 1 THEN 1 ELSE 0 END) AS DEFAULTS,
    ROUND(
        100.0 * SUM(CASE WHEN LA.LOAN_DEFAULT = 1 THEN 1 ELSE 0 END)
        / COUNT(*),2
        )AS DEFAULT_RATE 
        FROM credit_history CH
        JOIN loan_applications LA
             ON CH.customer_id = LA.customer_id
        WHERE LA.loan_default IS NOT NULL
        GROUP BY credit_score
        ORDER BY CREDIT_SCORE_BAND 


--Loan Approval Trends

-- 2. Loan Approval Trends

SELECT
    DATEFROMPARTS(
        YEAR(application_date),
        MONTH(application_date),
        1
    ) AS month,

    COUNT(*) AS total_applications,

    SUM(
        CASE
            WHEN approval_status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS approved,

    SUM(
        CASE
            WHEN approval_status = 'Rejected' THEN 1
            ELSE 0
        END
    ) AS rejected,

    SUM(
        CASE
            WHEN approval_status = 'Under Review' THEN 1
            ELSE 0
        END
    ) AS under_review

FROM loan_applications

GROUP BY
    YEAR(application_date),
    MONTH(application_date)

ORDER BY
    month;

-- CUSTOMER SEGMENTATION

SELECT
    CASE
        WHEN annual_income < 300000 THEN 'LOW INCOME'
        WHEN annual_income < 700000 THEN 'MIDDLE INCOME'
        ELSE 'HIGH INCOME'
    END AS income_segment,

    COUNT(*) AS customer_count,

    CAST(
        AVG(annual_income) AS DECIMAL(18,2)
    ) AS average_income

FROM [customers ]

GROUP BY
    CASE
        WHEN annual_income < 300000 THEN 'LOW INCOME'
        WHEN annual_income < 700000 THEN 'MIDDLE INCOME'
        ELSE 'HIGH INCOME'
    END

ORDER BY average_income;

--Employment-based segmentation

SELECT
    employment_type,
    COUNT(*) AS customer_count,
    AVG(annual_income) AS average_income

FROM [customers ]

GROUP BY employment_type

ORDER BY customer_count DESC;



-- 4. High-Risk Customer Identification

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    ch.credit_score,
    ch.credit_utilization_ratio,
    ch.num_late_payments_90d,
    ch.num_defaults_prior

FROM [customers ] c

INNER JOIN credit_history ch
    ON c.customer_id = ch.customer_id

WHERE
       ch.credit_score < 600
    OR ch.credit_utilization_ratio > 0.80
    OR ch.num_late_payments_90d > 0
    OR ch.num_defaults_prior > 0

ORDER BY
    ch.credit_score ASC;


    -- 5. Default Rate Analysis

SELECT
    COUNT(*) AS total_disbursed_loans,

    SUM(
        CASE
            WHEN loan_default = 1 THEN 1
            ELSE 0
        END
    ) AS defaulted_loans,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN loan_default = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS DECIMAL(10,2)
    ) AS default_rate

FROM loan_applications

WHERE loan_default IS NOT NULL;


--Default Rate by Loan Type

SELECT
    loan_type,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN loan_default = 1 THEN 1
            ELSE 0
        END
    ) AS defaults,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN loan_default = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS DECIMAL(10,2)
    ) AS default_rate

FROM loan_applications

WHERE loan_default IS NOT NULL

GROUP BY loan_type

ORDER BY default_rate DESC;


-- 6. Loan Amount Distribution

WITH loan_stats AS
(
    SELECT
        loan_type,
        requested_amount,

        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY requested_amount)
            OVER (PARTITION BY loan_type) AS median_amount

    FROM loan_applications
)

SELECT
    loan_type,

    COUNT(*) AS applications,

    MIN(requested_amount) AS minimum_amount,

    MAX(requested_amount) AS maximum_amount,

    AVG(
        CAST(requested_amount AS DECIMAL(18,2))
    ) AS average_amount,

    MAX(median_amount) AS median_amount

FROM loan_stats

GROUP BY loan_type

ORDER BY average_amount DESC;


-- 7. Monthly Approval Statistics

SELECT
    DATEFROMPARTS(
        YEAR(application_date),
        MONTH(application_date),
        1
    ) AS month,

    COUNT(*) AS total_applications,

    SUM(
        CASE
            WHEN approval_status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS approved,

    SUM(
        CASE
            WHEN approval_status = 'Rejected' THEN 1
            ELSE 0
        END
    ) AS rejected,

    SUM(
        CASE
            WHEN approval_status = 'Under Review' THEN 1
            ELSE 0
        END
    ) AS under_review,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN approval_status = 'Approved' THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN approval_status IN ('Approved', 'Rejected')
                    THEN 1
                    ELSE 0
                END
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS approval_rate

FROM loan_applications

GROUP BY
    YEAR(application_date),
    MONTH(application_date)

ORDER BY month;


-- 8. Risk Categorisation

SELECT
    c.customer_id,

    ch.credit_score,

    ch.credit_utilization_ratio,

    ch.num_defaults_prior,

    CASE
        WHEN
            ch.credit_score < 550
            OR ch.credit_utilization_ratio > 0.80
            OR ch.num_defaults_prior > 0
        THEN 'High Risk'

        WHEN
            ch.credit_score < 700
            OR ch.credit_utilization_ratio > 0.50
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS risk_category

FROM [customers ] c

INNER JOIN credit_history ch
    ON c.customer_id = ch.customer_id;



-- 9. Transaction Behaviour Analysis

SELECT
    customer_id,

    COUNT(*) AS transaction_count,

    SUM(
        CASE
            WHEN transaction_type = 'Credit'
            THEN amount
            ELSE 0
        END
    ) AS total_inflow,

    SUM(
        CASE
            WHEN transaction_type = 'Debit'
            THEN amount
            ELSE 0
        END
    ) AS total_outflow,

    SUM(
        CASE
            WHEN transaction_type = 'Credit'
            THEN amount

            WHEN transaction_type = 'Debit'
            THEN -amount

            ELSE 0
        END
    ) AS net_cash_flow,

    AVG(
        CAST(balance_after AS DECIMAL(18,2))
    ) AS average_balance

FROM transactions

GROUP BY customer_id;


-- 10A. Credit Score vs Default

SELECT
    CASE
        WHEN ch.credit_score < 550 THEN 'Poor'
        WHEN ch.credit_score < 650 THEN 'Fair'
        WHEN ch.credit_score < 750 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_band,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN la.loan_default = 1 THEN 1
            ELSE 0
        END
    ) AS defaults,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN la.loan_default = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS DECIMAL(10,2)
    ) AS default_rate

FROM credit_history ch

INNER JOIN loan_applications la
    ON ch.customer_id = la.customer_id

WHERE la.loan_default IS NOT NULL

GROUP BY
    CASE
        WHEN ch.credit_score < 550 THEN 'Poor'
        WHEN ch.credit_score < 650 THEN 'Fair'
        WHEN ch.credit_score < 750 THEN 'Good'
        ELSE 'Excellent'
    END

ORDER BY default_rate DESC;


-- 10B. DTI vs Default

SELECT
    CASE
        WHEN debt_to_income_ratio < 0.30 THEN 'Low DTI'
        WHEN debt_to_income_ratio < 0.50 THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS dti_band,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN loan_default = 1 THEN 1
            ELSE 0
        END
    ) AS defaults,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN loan_default = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS DECIMAL(10,2)
    ) AS default_rate

FROM loan_applications

WHERE loan_default IS NOT NULL

GROUP BY
    CASE
        WHEN debt_to_income_ratio < 0.30 THEN 'Low DTI'
        WHEN debt_to_income_ratio < 0.50 THEN 'Medium DTI'
        ELSE 'High DTI'
    END

ORDER BY default_rate DESC;



-- 10C. Previous Defaults vs Current Default

SELECT
    ch.num_defaults_prior,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN la.loan_default = 1 THEN 1
            ELSE 0
        END
    ) AS current_defaults,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN la.loan_default = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS DECIMAL(10,2)
    ) AS default_rate

FROM credit_history ch

INNER JOIN loan_applications la
    ON ch.customer_id = la.customer_id

WHERE la.loan_default IS NOT NULL

GROUP BY ch.num_defaults_prior

ORDER BY ch.num_defaults_prior;


