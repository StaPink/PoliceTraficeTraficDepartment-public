USE TrafficDepartmentDW
GO
-- Inserting data into the Date table
INSERT INTO [Date] ([Date], [Year], [Month], MonthNo, [Day])
VALUES 
('2024-04-16', '2024', 'April', 4, '16'),
('2024-04-17', '2024', 'April', 4, '17'),
('2024-04-18', '2024', 'April', 4, '18'),
('2024-04-19', '2024', 'April', 4, '19');

-- Inserting data into the Time table
INSERT INTO [Time] ([Hour], [Minute], [Second], TimeOfDay)
VALUES 
('08', '30', '00', 'between 0 and 8'),
('12', '15', '00', 'between 9 and 12'),
('15', '45', '00', 'between 13 and 15'),
('18', '20', '00', 'between 16 and 20');

-- Inserting data into the Place table
INSERT INTO Place (Street, District)
VALUES 
('Main Street', 'Downtown'),
('Elm Street', 'West End'),
('Oak Avenue', 'East Side'),
('Pine Road', 'North Side');

-- Inserting data into the Ticket table
INSERT INTO Ticket ([Description], ViolationArticle, PriceCategory)
VALUES 
('Parking violation', 'Article 123', 'normal'),
('Speeding', 'Article 456', 'expensive'),
('Running a red light', 'Article 789', 'normal'),
('Illegal U-turn', 'Article 246', 'cheap');

-- Inserting data into the Policeman table
INSERT INTO Policeman (BadgeNumber, JobRankCategory, JobTitle, [Address], City, AverageRatingCategory, CommentsRegardingWork, HadHistoryOfBrutalArrests, FirstName, Surname, WorkExperience, IsCurrent)
VALUES 
('123456', 'medium', 'Traffic Officer', '123 Main St', 'Cityville', 'between 3 and 4', 'Good worker', 0, 'John', 'Doe', 'between one and five years', 1),
('789012', 'high', 'Traffic Lieutenant', '456 Elm St', 'Townsville', 'between 4 and 5', 'Excellent officer', 0, 'Jane', 'Smith', 'more than ten years', 1),
('456789', 'low', 'Traffic Officer', '789 Oak Ave', 'Villageville', 'between 2 and 3', 'Needs improvement', 1, 'Alice', 'Johnson', 'up to one year', 1),
('345678', 'medium', 'Traffic Patrol Officer', '567 Pine Rd', 'Townsville', 'between 1 and 2', 'Average performer', 0, 'Bob', 'Williams', 'between one and five years', 1);

-- Inserting data into the Criminal table
INSERT INTO Criminal (PenaltyPointsCategory, IsOnProbation, FirstName, Surname, AgeCategory, IsCurrent)
VALUES 
('between 9 and 16', 1, 'Michael', 'Johnson', 'between 26 and 35', 1),
('between 0 and 8', 0, 'Sarah', 'Brown', 'between 18 and 25', 1),
('between 9 and 16', 1, 'David', 'Davis', 'between 26 and 35', 1),
('between 17 and 24', 0, 'Emily', 'Miller', 'between 18 and 25', 1);

-- Inserting data into the Rating table
INSERT INTO Rating (Points, ID_Policeman, ID_Criminal, ID_Ticket, ID_Place, ID_Date, ID_Time)
VALUES 
(3, 1, 1, 2, 1, 1, 1),
(5, 2, 2, 1, 1, 2, 3),
(2, 3, 1, 3, 3, 3, 2),
(4, 4, 4, 4, 4, 4, 4);

-- Inserting data into the GivingTickets table
INSERT INTO GivingTickets (PenaltyPoints, Amount, ID_Policeman, ID_Criminal, ID_Ticket, ID_Place, ID_Date, ID_Time)
VALUES 
(3, 300, 1, 1, 1, 1, 1, 1),
(5, 1000, 1, 1, 2, 1, 1, 1),
(2, 800, 3, 1, 3, 3, 3, 2),
(4, 500, 4, 4, 4, 4, 4, 4);

--TRUNCATE TABLE Rating