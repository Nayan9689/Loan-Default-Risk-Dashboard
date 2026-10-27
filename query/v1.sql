USE loan_risk;

   SHOW GLOBAL VARIABLES LIKE 'local_infile';
   
   USE loan_risk;
   
   CREATE TABLE loans_stg (
    id BIGINT,
    member_id BIGINT,
    loan_amnt DECIMAL(10,2),
    funded_amnt DECIMAL(10,2),
    funded_amnt_inv DECIMAL(10,2),
    term VARCHAR(20),
    int_rate DECIMAL(5,2),
    installment DECIMAL(10,2),
    grade VARCHAR(5),
    sub_grade VARCHAR(5),
    emp_title VARCHAR(255),
    emp_length VARCHAR(50),
    home_ownership VARCHAR(50),
    annual_inc DECIMAL(15,2),
    verification_status VARCHAR(50),
    issue_d VARCHAR(20),
    loan_status VARCHAR(100),
    pymnt_plan VARCHAR(10),
    url TEXT,
    `desc` TEXT,
    purpose VARCHAR(100),
    title VARCHAR(255),
    zip_code VARCHAR(20),
    addr_state VARCHAR(10),
    dti DECIMAL(10,2),
    delinq_2yrs INT,
    earliest_cr_line VARCHAR(20),
    fico_range_low INT,
    fico_range_high INT,
    inq_last_6mths INT,
    mths_since_last_delinq INT,
    mths_since_last_record INT,
    open_acc INT,
    pub_rec INT,
    revol_bal BIGINT,
    revol_util VARCHAR(20),
    total_acc INT
);


LOAD DATA LOCAL INFILE '"D:/laptop downloads/archive (4)/rejected_2007_to_2018q4.csv"'
INTO TABLE loans_stg
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, @member_id, loan_amnt, @funded_amnt, @funded_amnt_inv, term, int_rate, installment,
 grade, sub_grade, @emp_title, emp_length, home_ownership, annual_inc, verification_status,
 issue_d, loan_status, @pymnt_plan, @url, @desc, purpose, @title, @zip_code, addr_state,
 dti, delinq_2yrs, earliest_cr_line, @fico_low, @fico_high, inq_last_6mths,
 @mths_delinq, @mths_record, open_acc, pub_rec, revol_bal, revol_util, total_acc);
 
 
 LOAD DATA LOCAL INFILE 'D:\\laptop downloads\\archive (4)\\rejected_2007_to_2018q4.csv'
INTO TABLE loans_stg;