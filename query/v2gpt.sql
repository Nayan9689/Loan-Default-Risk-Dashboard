USE loan_risk;

SELECT * FROM loans_stg LIMIT 10;

SELECT
	loan_status,
    COUNT(*) AS loan_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loans_stg), 2) AS percentage
FROM loans_stg
GROUP BY loan_status
ORDER BY loan_count DESC;

USE loan_risk;

DROP TABLE IF EXISTS loan_risk_analysis;

USE loan_risk;

DROP TABLE IF EXISTS loan_risk_analysis;

CREATE TABLE loan_risk_analysis AS
SELECT
    id,
    loan_amnt,
    funded_amnt,
    funded_amnt_inv,
    term,
    int_rate,
    installment,
    grade,
    sub_grade,
    emp_length,
    home_ownership,
    annual_inc,
    verification_status,
    issue_d,
    loan_status,
    purpose,
    zip_code,
    addr_state,
    dti,
    delinq_2yrs,
    earliest_cr_line,
    fico_range_low,
    fico_range_high,
    inq_last_6mths,
    mths_since_last_delinq,
    mths_since_last_record,
    open_acc,
    pub_rec,
    revol_bal,
    revol_util,
    total_acc,

    CASE
        WHEN loan_status IN ('Charged Off', 'Default')
        THEN 1
        ELSE 0
    END AS default_flag,

    CASE
        WHEN loan_status IN (
            'Charged Off',
            'Default',
            'Late (31-120 days)',
            'Late (16-30 days)'
        )
        THEN 1
        ELSE 0
    END AS risk_flag,

    ROUND((fico_range_low + fico_range_high) / 2, 0) AS fico_score,

    CASE
        WHEN annual_inc < 30000 THEN 'Low Income'
        WHEN annual_inc < 60000 THEN 'Lower-Middle Income'
        WHEN annual_inc < 100000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS income_band,

    CASE
        WHEN dti < 10 THEN 'Low DTI'
        WHEN dti < 20 THEN 'Moderate DTI'
        WHEN dti < 30 THEN 'High DTI'
        ELSE 'Very High DTI'
    END AS dti_band,

    CASE
        WHEN fico_range_low < 580 THEN 'Poor'
        WHEN fico_range_low < 670 THEN 'Fair'
        WHEN fico_range_low < 740 THEN 'Good'
        WHEN fico_range_low < 800 THEN 'Very Good'
        ELSE 'Excellent'
    END AS fico_band

FROM loans_stg
WHERE loan_status IS NOT NULL;

SELECT COUNT(*) 
FROM loan_risk_analysis;

SELECT 
	default_flag,
    COUNT(*) AS lloans
FROM loan_risk_analysis
GROUP BY default_flag;

SELECT
	grade,
    COUNT(*) AS toatl_loans,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM loan_risk_analysis
GROUP BY grade
ORDER BY default_rate DESC;


SELECT 
	fico_band,
    COUNT(*) AS total_loans,
	SUM(default_flag) AS defaults,
	ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM loan_risk_analysis
GROUP BY fico_band
ORDER BY default_rate DESC;

SELECT 
	dti_band,
    COUNT(*) AS total_loans,
	SUM(default_flag) AS defaults,
	ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM loan_risk_analysis
GROUP BY dti_band
ORDER BY default_rate DESC;


SELECT 
	emp_length,
    COUNT(*) AS total_loans,
	SUM(default_flag) AS defaults,
	ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM loan_risk_analysis
GROUP BY emp_length
ORDER BY default_rate DESC;

SELECT 
	id,
    loan_amt,
    annual_inc,
    int_rate,
    grade,
    sub_grade,
    fico_score,
    fico_band,
    dti,
    income_band,
    purpose,
    addr_state,
    loan_status,
    
    CASE
		WHEN fico_score < 650 AND dti >= 25 THEN 'High Priority'
        WHEN fico_score < 650 AND dti >= 30 THEN 'Manual  Review'
        WHEN int_rate >= 20 AND dti >= 25 THEN 'Manual  Review'
        WHEN grade IN ('D','E','F','G') THEN 'Manual  Review'
        ELSE 'Standard'
	END AS review_category

FROM loam_risk_analysis;
    

SELECT
    id,
    loan_amnt,
    annual_inc,
    int_rate,
    grade,
    sub_grade,
    fico_score,
    fico_band,
    dti,
    income_band,
    purpose,
    addr_state,
    loan_status,

    CASE
        WHEN fico_score < 650 AND dti >= 25 THEN 'High Priority'
        WHEN fico_score < 650 OR dti >= 30 THEN 'Manual Review'
        WHEN int_rate >= 20 AND dti >= 25 THEN 'Manual Review'
        WHEN grade IN ('D','E','F','G') THEN 'Manual Review'
        ELSE 'Standard'
    END AS review_category

FROM loan_risk_analysis;


SELECT
    review_category,
    COUNT(*) AS applications
FROM
(
    SELECT
        CASE
            WHEN fico_score < 650 AND dti >= 25 THEN 'High Priority'
            WHEN fico_score < 650 OR dti >= 30 THEN 'Manual Review'
            WHEN int_rate >= 20 AND dti >= 25 THEN 'Manual Review'
            WHEN grade IN ('D','E','F','G') THEN 'Manual Review'
            ELSE 'Standard'
        END AS review_category
    FROM loan_risk_analysis
) x
GROUP BY review_category
ORDER BY applications DESC;


SELECT 
	COUNT(*) AS tota_loans,
    SUM(loan_amnt) AS total_loan_amount,
    SUM(default_flag) AS total_defaults,
    
    ROUND(
		SUM(default_flag) * 100.0 / COUNT(*),
        2
	)AS default_rate,
    
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    
    ROUND(AVG(int_rate), 2) AS avg_interst_rate,
    
    ROUND(AVG(dti), 2) AS avg_dti,
    
    ROUND(AVG(fico_score), 2) AS avg_fico_score

FROM loan_risk_analysis;
    


SELECT
    YEAR(STR_TO_DATE(issue_d, '%b-%Y')) AS issue_year,
    COUNT(*) AS total_loans,
    SUM(default_flag) AS defaults,
    ROUND(
        SUM(default_flag) * 100.0 / COUNT(*),
        2
    ) AS default_rate,
    SUM(loan_amnt) AS loan_amount
FROM loan_risk_analysis
WHERE issue_d IS NOT NULL
GROUP BY YEAR(STR_TO_DATE(issue_d, '%b-%Y'))
ORDER BY issue_year;


SELECT * FROM loan_risk_analysis LIMIT 5;


SELECT issue_d
FROM loan_risk_analysis
LIMIT 10;




SELECT
    YEAR(STR_TO_DATE(issue_d, '%b%Y')) AS issue_year,
    COUNT(*) AS total_loans,
    SUM(default_flag) AS defaults,
    ROUND(
        SUM(default_flag) * 100.0 / COUNT(*),
        2
    ) AS default_rate,
    SUM(loan_amnt) AS loan_amount
FROM loan_risk_analysis
WHERE issue_d IS NOT NULL
GROUP BY YEAR(STR_TO_DATE(issue_d, '%b%Y'))
ORDER BY issue_year;




SELECT DISTINCT issue_d
FROM loan_risk_analysis
LIMIT 20;



SELECT
    issue_d,
    STR_TO_DATE(issue_d, '%b-%Y') AS converted_date
FROM loan_risk_analysis
LIMIT 10;

SELECT
    issue_d,
    STR_TO_DATE(TRIM(issue_d), '%b-%Y') AS converted_date
FROM loan_risk_analysis
LIMIT 10;

SELECT
    issue_d,
    HEX(issue_d)
FROM loan_risk_analysis
LIMIT 10;

SELECT
    issue_d,
    LENGTH(issue_d)
FROM loan_risk_analysis
LIMIT 10;


SELECT
    RIGHT(issue_d,4) AS issue_year,
    COUNT(*) AS total_loans,
    SUM(default_flag) AS defaults,
    ROUND(
        SUM(default_flag) * 100.0 / COUNT(*),
        2
    ) AS default_rate,
    SUM(loan_amnt) AS loan_amount
FROM loan_risk_analysis
WHERE issue_d IS NOT NULL
GROUP BY RIGHT(issue_d,4)
ORDER BY issue_year;


SELECT
    RIGHT(issue_d,4) AS issue_year,
    COUNT(*) AS total_loans,
    SUM(default_flag) AS defaults,
    ROUND(
        SUM(default_flag) * 100.0 / COUNT(*),
        2
    ) AS default_rate,
    SUM(loan_amnt) AS loan_amount
FROM loan_risk_analysis
WHERE issue_d IS NOT NULL
GROUP BY RIGHT(issue_d,4)
ORDER BY issue_year;

SELECT
    addr_state,
    COUNT(*) AS total_loans,
    SUM(default_flag) AS defaults,
    ROUND(
        SUM(default_flag) * 100.0 / COUNT(*),
        2
    ) AS default_rate,
    SUM(loan_amnt) AS total_loan_amount
FROM loan_risk_analysis
GROUP BY addr_state
HAVING COUNT(*) >= 100
ORDER BY default_rate DESC;



SELECT 
	grade,
    fico_band,
    dti_band,
    income_band,
    
    COUNT(*) AS total_loans,
    
    SUM(default_flag) AS defaults,
    
	ROUND(
	SUM(default_flag) * 100.0 / COUNT(*),
        2
    ) AS default_rate,
 
	ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,

    ROUND(AVG(int_rate), 2) AS avg_interest_rate

FROM loan_risk_analysis

GROUP BY
    grade,
    fico_band,
    dti_band,
    income_band

HAVING COUNT(*) >= 100

ORDER BY default_rate DESC;

    



