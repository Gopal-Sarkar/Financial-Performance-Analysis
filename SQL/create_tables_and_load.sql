-- Financial Performance Analysis — Schema & Data Load
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --- --- ---- ---- ---- ---- --- 
-- customers, vendors, headcount, and budget: loaded these using the
-- import wizard (right click table -> table data import wizard)
create table customers (
    customer_id varchar(20) primary key,
    customer_name varchar(100) not null,
    segment varchar(50),
    join_date date,
    region varchar(50),
    status varchar(20)
);

create table vendors (
    vendor_id varchar(20) primary key,
    vendor_name varchar(100) not null,
    category varchar(50),
    region varchar(50),
    active varchar(5)
);

create table headcount (
    employee_id varchar(20) primary key,
    employee_name varchar(100) not null,
    business_unit varchar(50),
    join_date date,
    status varchar(20),
    region varchar(50),
    cost_to_company int
);

create table budget (
    year int,
    month int,
    business_unit varchar(50),
    budgeted_revenue int,
    budgeted_expense int,
    primary key (year, month, business_unit)
);

create table financial_transactions (
    transaction_id varchar(20) primary key,
    transaction_date date,
    amount float,
    account_type varchar(20),
    category varchar(50),
    business_unit varchar(50),
    region varchar(50),
    customer_id varchar(20),
    vendor_id varchar(20),
    description varchar(255),
    foreign key (customer_id) references customers(customer_id),
    foreign key (vendor_id) references vendors(vendor_id)
);

-- financial_transactions has blank customer_id/vendor_id cells that are
-- structurally expected (Expense rows have no customer, Revenue rows have
-- no vendor). The wizard loaded these blanks as empty strings, which failed
-- the foreign key check. LOAD DATA with NULLIF() converts them to real
-- NULLs during the load instead.
set global local_infile = 1;
set foreign_key_checks = 0;

load data local infile 'C:/sqldata/Financial_Transactions.csv'
into table financial_transactions
fields terminated by ','
lines terminated by '\n'
ignore 1 rows
(transaction_id, transaction_date, amount, account_type, category, business_unit, region, @customer_id, @vendor_id, description)
set
  customer_id = nullif(@customer_id, ''),
  vendor_id = nullif(@vendor_id, '');

set foreign_key_checks = 1;
set global foreign_key_checks = 1;


-- quick check that row counts match what I expect
select count(*) from customers;    -- 400
select count(*) from vendors;   -- 120
select count(*) from headcount;   -- 200
select count(*) from budget;   -- 72
select count(*) from financial_transactions;  -- 10400