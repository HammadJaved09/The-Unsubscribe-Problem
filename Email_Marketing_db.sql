CREATE database Email_db;
USE Email_db;

-- 1️⃣ USERS TABLE
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    signup_date DATE,
    device_type VARCHAR(50),
    region VARCHAR(100),
    is_active BOOLEAN
);

-- 2️⃣ CAMPAIGNS TABLE
CREATE TABLE Campaigns (
    campaign_id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_name VARCHAR(255),
    send_date DATE,
	email_subject VARCHAR(255),
    send_hour INT,
    category VARCHAR(100)
);


-- 3️⃣ CAMPAIGN PERFORMANCE TABLE
CREATE TABLE Campaign_Performance (
    campaign_id INT,
    total_sent INT,
    total_opens INT,
    total_clicks INT,
    total_unsubscribers INT,
    PRIMARY KEY (campaign_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

CREATE TABLE Email_Engagement (
    engagement_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    campaign_id INT,
    opened BOOLEAN,
    clicked BOOLEAN,
	unsubscribe BOOLEAN,
    open_time DATETIME,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);



CREATE TABLE Unsubscribe (
    unsubscribe_id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT,
    user_id INT,
    unsubscribe_date DATETIME,
    reason VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
        ON DELETE CASCADE
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/DELL 6540/OneDrive/Desktop/PowerBI Projects/Datasets/Email_marketing_dataset/Users.csv'
INTO TABLE Users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(user_id, signup_date, device_type, region, is_active);

LOAD DATA LOCAL INFILE 'C:/Users/DELL 6540/OneDrive/Desktop/PowerBI Projects/Datasets/Email_marketing_dataset/Campaigns.csv'
INTO TABLE Campaigns
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(campaign_id, campaign_name, send_date, email_subject, send_hour, category);

LOAD DATA LOCAL INFILE 'C:/Users/DELL 6540/OneDrive/Desktop/PowerBI Projects/Datasets/Email_marketing_dataset/Campaign_Performance.csv'
INTO TABLE Campaign_Performance
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(campaign_id, total_sent, total_opens, total_clicks, total_unsubscribers);

LOAD DATA LOCAL INFILE 'C:/Users/DELL 6540/OneDrive/Desktop/PowerBI Projects/Datasets/Email_marketing_dataset/Email_Engagement.csv'
INTO TABLE Email_Engagement
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(engagement_id, user_id, campaign_id, opened, clicked, unsubscribe,@open_time)
SET open_time = NULLIF(TRIM(@open_time), '');

LOAD DATA LOCAL INFILE 'C:/Users/DELL 6540/OneDrive/Desktop/PowerBI Projects/Datasets/Email_marketing_dataset/Unsubscribes.csv'
INTO TABLE Unsubscribe
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(unsubscribe_id, user_id, campaign_id, unsubscribe_date, reason);

SELECT * FROM Users;