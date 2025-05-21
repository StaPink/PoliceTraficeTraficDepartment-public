USE TrafficDepartmentDW;
GO

IF (OBJECT_ID('vETLRating') IS NOT NULL) DROP VIEW vETLRating;
GO

CREATE VIEW vETLRating
AS
SELECT 
    ST1.amount AS Amount,
	ST3.points AS Points,
    dbo.Policeman.ID_Policeman AS ID_Policeman,
    dbo.Criminal.ID_Criminal AS ID_Criminal,
	dbo.Ticket.ID_Ticket AS ID_Ticket,
    dbo.Place.ID_Place AS ID_Place,
    SD.ID_Date AS ID_Date,
    dbo.[Time].ID_Time AS ID_Time,
    CASE
	WHEN Amount BETWEEN 0 AND 999 THEN 'cheap'
	WHEN Amount BETWEEN 1000 AND 2999 THEN 'normal'
	WHEN Amount BETWEEN 3000 AND 6999 THEN 'expensive'
	WHEN Amount >= 7000  THEN 'exceptional'
	END AS [PriceCategory]

	FROM Police.dbo.RatingOfService AS ST3	
	JOIN Police.dbo.Ticket AS ST1 ON (ST3.ticket_id = ST1.ticket_id)
	JOIN Police.dbo.Criminal AS ST2 ON ST1.criminal_id = ST2.criminal_id

	LEFT JOIN dbo.Criminal ON dbo.Criminal.Pesel= ST2.pesel
	LEFT JOIN dbo.Policeman ON Policeman.BadgeNumber = ST1.officer_badge_number
	JOIN dbo.Place ON (dbo.Place.Street = ST1.street AND dbo.Place.District = ST1.district)
	JOIN dbo.[Date] as SD ON CONVERT(VARCHAR(10), CAST(SD.[Date] AS DATE), 111) = CONVERT(VARCHAR(10), CAST(ST1.datetime_of_issue AS DATE), 111)
	JOIN dbo.[Time] ON (dbo.[Time].[Hour] = DATEPART(HOUR, ST1.datetime_of_issue) AND dbo.[Time].[Minute] = DATEPART(MINUTE, ST1.datetime_of_issue) AND dbo.[Time].[Second] = DATEPART(SECOND, ST1.datetime_of_issue))
	JOIN dbo.Ticket ON dbo.Ticket.ViolationArticle = ST1.violation_article WHERE [PriceCategory] = dbo.Ticket.PriceCategory
GO

MERGE INTO Rating AS TT
USING vETLRating AS ST
ON 
    TT.Points = ST.Points
    AND TT.ID_Policeman = ST.ID_Policeman
    AND TT.ID_Criminal = ST.ID_Criminal
    AND TT.ID_Ticket = ST.ID_Ticket
    AND TT.ID_Place = ST.ID_Place
    AND TT.ID_Date = ST.ID_Date
    AND TT.ID_Time = ST.ID_Time
WHEN NOT MATCHED THEN
    INSERT 
    VALUES (ST.Points, ST.ID_Policeman, ST.ID_Criminal, ST.ID_Ticket, ST.ID_Place, ST.ID_Date, ST.ID_Time);
GO

--SELECT * FROM vETLGivingTickets;
--Select * From dbo.Rating

DROP VIEW vETLRating 