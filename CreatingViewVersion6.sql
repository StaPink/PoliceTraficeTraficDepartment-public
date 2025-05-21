USE TrafficDepartmentDW;
GO

IF (OBJECT_ID('vETLGivingTickets') IS NOT NULL) DROP VIEW vETLGivingTickets;
GO

CREATE VIEW vETLGivingTickets
AS
SELECT 
    ST1.penalty_points AS PenaltyPoints,
    ST1.amount AS Amount,
    dbo.Policeman.ID_Policeman AS ID_Policeman,
    dbo.Criminal.ID_Criminal AS ID_Criminal,
	dbo.Ticket.ID_Ticket AS ID_Ticket,
    dbo.Place.ID_Place AS ID_Place,
    SD.ID_Date AS ID_Date,
    dbo.[Time].ID_Time AS ID_Time
    case
    		WHEN ST.amount BETWEEN 0 AND 999 THEN 'cheap'
			WHEN ST.amount BETWEEN 1000 AND 2999 THEN 'normal'
			WHEN ST.amount BETWEEN 3000 AND 6999 THEN 'expensive'
			WHEN ST.amount >= 7000  THEN 'exceptional'
    END AS PriceCategory
FROM Police.dbo.Ticket AS ST1
JOIN Police.dbo.Criminal AS ST2 ON ST1.criminal_id = ST2.criminal_id
LEFT JOIN dbo.Criminal ON dbo.Criminal.Pesel = ST2.pesel
LEFT JOIN dbo.Policeman ON Policeman.BadgeNumber = ST1.officer_badge_number
JOIN dbo.Ticket ON dbo.Ticket.violation_article = ST1.violation_article 
    where PriceCategory = ST.amount
JOIN dbo.Place ON (dbo.Place.Street = ST1.street AND dbo.Place.District = ST1.district)
JOIN dbo.[Date] as SD ON CONVERT(VARCHAR(10), CAST(SD.[Date] AS DATE), 111) = CONVERT(VARCHAR(10), CAST(ST1.datetime_of_issue AS DATE), 111)
JOIN dbo.[Time] ON (dbo.[Time].[Hour] = DATEPART(HOUR, ST1.datetime_of_issue) AND dbo.[Time].[Minute] = DATEPART(MINUTE, ST1.datetime_of_issue) AND dbo.[Time].[Second] = DATEPART(SECOND, ST1.datetime_of_issue))
GO

MERGE INTO GivingTickets AS TT
USING vETLGivingTickets AS ST
ON 	
    TT.PenaltyPoints = ST.PenaltyPoints
    AND TT.Amount = ST.Amount
    AND TT.ID_Policeman = ST.ID_Policeman
    AND TT.ID_Criminal = ST.ID_Criminal
    AND TT.ID_Ticket = ST.ID_Ticket
    AND TT.ID_Place = ST.ID_Place
    AND TT.ID_Date = ST.ID_Date
    AND TT.ID_Time = ST.ID_Time
WHEN NOT MATCHED THEN
    INSERT 
    VALUES (ST.PenaltyPoints, ST.Amount, ST.ID_Policeman, ST.ID_Criminal, ST.ID_Ticket, ST.ID_Place, ST.ID_Date, ST.ID_Time);
GO

--SELECT * FROM vETLGivingTickets;

DROP VIEW vETLGivingTickets 

--SELECT * FROM GivingTickets;

