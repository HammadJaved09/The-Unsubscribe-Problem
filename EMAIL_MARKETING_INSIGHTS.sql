/*                           EMAIL MARKETING CAMPAIGNS ANALYSIS                                                 */
/*                                  BY: SYED HAMMAD JAVED                                                       */



USE email_db;


/* THIS QUERY WILL RETURN US TOTAL NUMBERS OF USERS
 AND ALSO RETURN NUMBER OF ACTIVE & INACTIVE USERS */ 

SELECT 
COUNT(*) AS Total_Users,
SUM(CASE WHEN is_active=1 THEN 1 ELSE 0 END) AS Active_Users,
SUM(CASE WHEN is_active=0 THEN 1 ELSE 0 END) AS Inactive_Users
FROM Users;

/* BELOW QUERY WILL TOTAL USERS FROM USER TABLE AND TOTAL EMAILS
   SENT TOTAL UNSUBSCRIBERS & UNSUBSCRIBE% FROM CAMPAIGN PERFORMANCE 
   TABLE */



SELECT
(SELECT COUNT(User_id) FROM Users) AS Total_Users,
SUM(total_sent) AS Total_Emails_Sent,
SUM(total_unsubscribers) AS Total_Unsubscribers,
ROUND(SUM(total_unsubscribers)/SUM(total_sent) * 100,2) Unsubscriber_rate
FROM Campaign_Performance;



/* THIS QUERY WILL RETURN TOTAL CAMPAIGNS RUN OVERS 9 MONTHS PERIOD
   OPEN RATE% CLOSE RATE & ENGAGEMENT RATE% OF THESE CAMPAIGNS */

SELECT 
	COUNT(campaign_id) AS Total_Campaigns,
    ROUND(
        (SUM(total_opens) / SUM(total_sent)) * 100, 2) AS Open_Rate_Percent,
    ROUND(
        (SUM(total_clicks) / SUM(total_sent)) * 100, 2) AS Click_Rate_Percent,
    ROUND(
        ((SUM(total_opens) + SUM(total_clicks)) / SUM(total_sent)) * 100, 2) AS Engagement_Rate_Percent
FROM Campaign_Performance;



/* THIS QUERY EVALUATES THE PERFORMANCE OF ALL EMAIL CAMPAIGNS 
TO IDENTIFY WHICH ONES HAVE THE LOWEST UNSUBSCRIBE RATES 
AND THE HIGHEST ENGAGEMENT RATES */

SELECT 
    c.campaign_name AS Campaign_Name,
    c.category AS Category,
    c.send_hour AS Send_Hour_Of_Day,
    DAYNAME(c.send_date) AS Day_Of_Week,
    cp.total_sent AS Total_Emails_Sent,
    cp.total_unsubscribers AS Total_Unsubscribers,

    ROUND((cp.total_unsubscribers / cp.total_sent) * 100, 2) AS Unsubscribe_Rate_Percent,
    ROUND(((cp.total_opens + cp.total_clicks) / cp.total_sent) * 100, 2) AS Engagement_Rate_Percent,
    RANK() OVER (ORDER BY (cp.total_unsubscribers / cp.total_sent) ASC) AS Unsubscribe_Rank
FROM Campaign_Performance cp
JOIN Campaigns c 
    ON cp.campaign_id = c.campaign_id
ORDER BY Unsubscribe_Rate_Percent ASC;



/* THIS QUERY ANALYZES EMAIL CAMPAIGN PERFORMANCE BY CATEGORY 
TO IDENTIFY WHICH CATEGORY DRIVES THE HIGHEST NUMBER OF UNSUBSCRIBERS */

SELECT 
C.category AS Category,
SUM(CP.total_sent) AS Email_Sent,
SUM(CP.total_unsubscribers) AS TOTAL_UNSUBSCRIBERS,
ROUND(SUM(total_unsubscribers)/SUM(total_sent) * 100,2) AS Unsubscriber_Rate
FROM Campaigns C
JOIN Campaign_Performance CP
ON C.campaign_id = CP.campaign_id
GROUP BY C.category
ORDER BY TOTAL_UNSUBSCRIBERS DESC;



/* THIS QUERY EVALUATE RELATIONSHIP BETWEEN OPEN_RATE & UNSUBSCRIBE RATE */

SELECT 
    c.campaign_name AS Campaign_Name,
    ROUND((cp.total_opens / cp.total_sent) * 100, 2) AS Open_Rate,
    ROUND((cp.total_unsubscribers / cp.total_sent) * 100, 2) AS Unsubscribe_Rate
FROM Campaign_Performance cp
JOIN Campaigns c 
    ON cp.campaign_id = c.campaign_id
ORDER BY Open_Rate DESC;



/* THIS QUERY ANALYZES WHETHER THE SEND TIME AFFECTS ENGAGEMENT AND UNSUBSCRIBE BEHAVIOR */

SELECT 
    C.send_hour AS Hour_Of_Day,
    SUM(CP.total_sent) AS Total_Emails_Sent,
        ROUND(((SUM(CP.total_opens) + SUM(CP.total_clicks)) / SUM(CP.total_sent)) * 100, 2) AS Engagement_Rate,
    SUM(CP.total_unsubscribers) AS Total_Unsubscribers,
    ROUND((SUM(CP.total_unsubscribers) / SUM(CP.total_sent)) * 100, 2) AS Unsubscribe_Rate
FROM Campaign_Performance CP
JOIN Campaigns C
    ON CP.campaign_id = c.campaign_id
GROUP BY C.send_hour
ORDER BY Unsubscribe_Rate DESC;



/* THIS QUERY ANALYZE THE THE UNSUBSCRIBERS ON THE BASIS OF DEVICE TYPE & REGION */

SELECT 
    U.device_type,
    U.region,
    COUNT(DISTINCT UN.user_id) AS Total_Unsubscribers,
    COUNT(DISTINCT U.user_id) AS Total_Users,
    ROUND(
        (COUNT(DISTINCT UN.user_id) / COUNT(DISTINCT U.user_id)) * 100,
        2
    ) AS Unsubscribe_Rate_Percent
FROM Users U
LEFT JOIN Unsubscribe UN 
    ON U.user_id = UN.user_id
GROUP BY U.device_type, U.region
ORDER BY Unsubscribe_Rate_Percent DESC;



/* THIS QUERY AGGREGATES DAYS USERS TAKE TO UNSUBSCRIBE 
AND SHOWS MIN, MAX DAYS A USER SIGN UP & UNSUBSCRIBE OVER THE PERIOD 
OF 2023 & 24 */
 
WITH first_signup AS (
    SELECT user_id, MIN(signup_date) AS signup_date
    FROM Users
    GROUP BY user_id
),
first_unsub AS (
    SELECT user_id, MIN(unsubscribe_date) AS unsubscribe_date
    FROM Unsubscribe
    GROUP BY user_id
),
user_unsub AS (
    SELECT f.user_id,
           f.signup_date,
           u.unsubscribe_date,
           DATEDIFF(u.unsubscribe_date, f.signup_date) AS days_to_unsubscribe
    FROM first_signup f
    JOIN first_unsub u ON f.user_id = u.user_id
    WHERE DATEDIFF(u.unsubscribe_date, f.signup_date) >= 0
)
SELECT YEAR(signup_date) AS signup_year,
       MONTH(signup_date) AS signup_month,
       AVG(days_to_unsubscribe) AS avg_days,
       MIN(days_to_unsubscribe) AS min_days,
       MAX(days_to_unsubscribe) AS max_days
FROM user_unsub
GROUP BY signup_year, signup_month
ORDER BY signup_year, signup_month;


/* THIS QUERY ANALYZES THE REASONS BY CATEGORY
   LIKE WHICH REASONS IS THE MOST COMMON AMONG THE DIFFERENT CATEGORIES */


SELECT 
    c.category,
    u.reason,
    COUNT(*) AS total_unsubscribers,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM Unsubscribe) ) * 100, 2) AS percentage_of_total
FROM Unsubscribe u
JOIN campaigns c ON u.campaign_id = c.campaign_id
GROUP BY c.category, u.reason
ORDER BY c.category, total_unsubscribers DESC;


/*                                              COMPLETED                                                        */







