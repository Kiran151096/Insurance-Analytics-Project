use insurance;

--- i.	Target FY from Individual target sheet (New, Cross sell and Renewal) ---
SELECT * FROM `individual budgets` LIMIT 50000;

SELECT SUM(`Cross sell bugdet`) AS sum_of_cross_sell_budget
FROM `individual budgets`;

SELECT SUM(`New Budget`) AS sum_of_new_budget
FROM `individual budgets`;

SELECT SUM(`Renewal Budget`) AS sum_of_new_budget
FROM `individual budgets`;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- ii.	Placed Achievement form Brokerage + Fees sheet (New, Cross sell and Renewal) ---

---- brokerage ----
SELECT 
    SUM(CASE WHEN income_class = 'New' THEN Amount ELSE 0 END) AS new_business_achievement,
    SUM(CASE WHEN income_class = 'Cross Sell' THEN Amount ELSE 0 END) AS cross_sell_achievement,
    SUM(CASE WHEN income_class = 'Renewal' THEN Amount ELSE 0 END) AS renewal_achievement
FROM 
    `brokerage` 
WHERE 
    income_class IN ('New', 'Cross Sell', 'Renewal');
    
---- fees ----
SELECT
    SUM(CASE WHEN income_class = 'New' THEN Amount ELSE 0 END) AS new_business_achievement,
    SUM(CASE WHEN income_class = 'Cross Sell' THEN Amount ELSE 0 END) AS cross_sell_achievement,
    SUM(CASE WHEN income_class = 'Renewal' THEN Amount ELSE 0 END) AS renewal_achievement
FROM
    `fees`
WHERE
     income_class IN ('New','Cross Sell','Renewal');
     
---- Combining Both (Brokerage + Fees) ----
    
SELECT 
  SUM(CASE WHEN income_class = 'New' THEN Amount ELSE 0 END) AS new_business_achievement,
  SUM(CASE WHEN income_class = 'Cross Sell' THEN Amount ELSE 0 END) AS cross_sell_achievement,
  SUM(CASE WHEN income_class = 'Renewal' THEN Amount ELSE 0 END) AS renewal_achievement
FROM (
  SELECT income_class, Amount FROM brokerage
  UNION ALL
  SELECT income_class, Amount FROM fees
) AS combined
WHERE income_class IN ('New', 'Cross Sell', 'Renewal');
    
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- iii. Invoiced Achievement from Invoice sheet (New, Cross sell and Renewal) Column (B, F, G, J) ---

SELECT 
    income_class,  
    SUM(CASE WHEN income_class = 'New' THEN amount ELSE 0 END) AS New_Achievement,
    SUM(CASE WHEN income_class = 'Cross sell' THEN amount ELSE 0 END) AS Cross_Sell_Achievement,
    SUM(CASE WHEN income_class = 'Renewal' THEN amount ELSE 0 END) AS Renewal_Achievement
FROM invoice
WHERE income_class IN ('New', 'Cross sell', 'Renewal')
GROUP BY income_class
LIMIT 50000;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- iv. Percentage of Achievement for Placed and Invoice – (Achieved/budget) ----

CREATE TABLE achievement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    income_class VARCHAR(50) NOT NULL,
    achieved_amount DECIMAL(15,2) NOT NULL
);

CREATE TABLE budget (
    id INT AUTO_INCREMENT PRIMARY KEY,
    income_class VARCHAR(50) NOT NULL,
    total_budget DECIMAL(15,2) NOT NULL
);

CREATE TABLE invoice_achievement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    income_class VARCHAR(50) NOT NULL,
    invoice_amount DECIMAL(15,2) NOT NULL
);


INSERT INTO achievement (income_class, achieved_amount)
VALUES 
('New', 3531629.31),
('Cross Sell',13041253.31 ),
('Renewal',18507270.30 );

INSERT INTO budget (income_class, total_budget)
VALUES 
('New', 19673793),
('Cross Sell', 20083111),
('Renewal', 12319455);

INSERT INTO invoice_achievement (income_class, invoice_amount)
VALUES
('New', 569815),
('Cross Sell', 2853842),
('Renewal', 8244310);

SELECT * FROM achievement;
SELECT * FROM budget;
SELECT * FROM invoice_achievement;

     ----- Placed Achievement Percentage -----

SELECT
   a.income_class,
   SUM(a.achieved_amount) AS total_achievement,
   b.total_budget,
   CONCAT(ROUND((SUM(a.achieved_amount) / b.total_budget) * 100,2), '%') AS placed_achievement_percentage
FROM
   achievement a
JOIN
   budget b ON a.income_class = b.income_class
WHERE
   a.income_class IN ('New', 'Cross Sell', 'Renewal')
GROUP BY
   a.income_class, b.total_budget;
   
     ----- Invoice Achievement Percentage -----

SELECT
    a.income_class,
    SUM(a.invoice_amount) AS total_achievement,
    b.total_budget,
    CONCAT(ROUND((SUM(a.invoice_amount) / b.total_budget) * 100,2), '%') AS invoice_achievement_percentage
FROM
    invoice_achievement a  -- Added alias 'a' here
JOIN
    budget b ON a.income_class = b.income_class
WHERE
    a.income_class IN ('New', 'Cross Sell', 'Renewal')
GROUP BY
    a.income_class, b.total_budget;
 
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ------------------------------ -- --------------------------------------------------------------------------------------------------------------------------------------------------------------
--- v.	No of meetings for current year – Meeting sheet (A, C, D) --

SELECT
   YEAR(meeting_date) AS year,
   COUNT(meeting_date) AS count_of_meeting_date
FROM meeting
GROUP BY YEAR(meeting_date);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--- vi.	Open Oppty – Opportunity report (Column: C, E, F, G) (Stage ‘Open’ Column G = Propose Solution & Qualify Opportunity) ---

SELECT 
    opportunity_id,
    opportunity_name,
    revenue_amount,
    stage
FROM `opportunity`
WHERE Stage IN ('Propose Solution', 'Qualify Opportunity')
ORDER BY revenue_amount DESC;


--------------------------------------------------------------------------------------------------------------------------------------------
             --- KPI 1 ---
             --- No. of Invoice by Acc Exec ---

SELECT
    `Account Executive`,               
    COUNT(invoice_date) AS number_of_invoices
FROM invoice
GROUP BY `Account Executive`;  


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
              --- KPI 2 ---
              --- Yearly Meeting Count ---
              
SELECT 
  YEAR(meeting_date) AS Year,
  COUNT(meeting_date) AS MeetingCount
FROM meeting
GROUP BY YEAR(meeting_date)
ORDER BY Year;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
              --- KPI 3.1 ---
              ---- Cross Sell ----

CREATE TABLE Cross_Sell (
    invoice INT PRIMARY KEY,
    achievement DECIMAL(15,2),
    target INT
); 
       
INSERT INTO Cross_Sell (invoice, achievement, target)  
VALUES  
( 2853842, 13041253.30, 20083111); 
           
SELECT 
    invoice AS "Invoice Cross Sell", 
    achievement AS "Achievement Cross Sell", 
    target AS "Target Cross Sell"
FROM Cross_Sell;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                --- KPI 3.2 ---
                ---- New ----
                
   CREATE TABLE New_Sell (
    invoice INT PRIMARY KEY,
    achievement DECIMAL(15,2),
    target INT
); 
       
INSERT INTO New_Sell (invoice, achievement, target)  
VALUES  
(569815.00, 3531629.31, 19673793.00 ); 
           
SELECT 
    invoice AS "Invoice New Sell", 
    achievement AS "Achievement New Sell", 
    target AS "Target New Sell"
FROM New_Sell; 
--------------------------------------------------------------------------------------------------------------------------------------------------------------            
               --- KPI 3.3 ---
               ---- Renewal ----
               
CREATE TABLE Renewal_Sell (
    invoice INT PRIMARY KEY,
    achievement DECIMAL(15,2),
    target INT
); 
       
INSERT INTO Renewal_Sell (invoice, achievement, target)  
VALUES  
(8244310.00, 18507270.64, 12319455.00); 
           
SELECT 
    invoice AS "Invoice Renewal Sell", 
    achievement AS "Achievement Renewal Sell", 
    target AS "Target Renewal Sell"
FROM Renewal_Sell; 
              

--------------------------------------------------------------------------------------------------------------------------------------------
                --- KPI 4 ---
                ---- Stage by Revenue ----
                
SELECT
    stage,                             
    SUM(revenue_amount) AS total_revenue      
FROM opportunity                    
GROUP BY stage                           
ORDER BY FIELD(stage, 'Qualify Opportunity', 'Negotiate','Propose Solution');

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
               --- KPI 5 ---
			   --- No. of Meeting By Acc Exec ---
SELECT
    `Account Executive`,               
    COUNT(meeting_date) AS number_of_meeting
FROM meeting
GROUP BY `Account Executive`;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                 --- KPI 6 ---
                 --- Top Open Opportunity ---
                 
SELECT 
    opportunity_id,
    opportunity_name,
    revenue_amount,
    stage
FROM `opportunity`
WHERE Stage IN ('Propose Solution', 'Qualify Opportunity')
ORDER BY revenue_amount DESC
LIMIT 10;
--------------------------------------------------------------------------------------------------------------------
