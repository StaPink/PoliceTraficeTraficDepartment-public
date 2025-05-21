use TrafficDepartmentDW;
go

If (object_id('vETLRating') is not null) Drop view vETLRating;
go
CREATE VIEW vETLRating
AS
SELECT 
	  Points
	, ID_Policeman
	, ID_Criminal
	, ID_Ticket
	, ID_Place
	, ID_Date
	, ID_Time
FROM
	(SELECT 
		  Points = ST1.points
		, ID_Policeman = ST2.ID_Policeman
		, ID_Criminal = 
		, ID_Ticket = 
		, ID_Place = 
		, ID_Date = 
					
	FROM Police.dbo.RatingOfService AS ST1
	JOIN Police.dbo.Officer  as ST2 ON ST1.officer_badge_number  = ST2.badge_number 
    Join Police.dbo.Ticket   as ST3 ON ST2.badge_number = ST3.officer_badge_number
	--Date
	JOIN dbo.Date as DA ON CONVERT(VARCHAR(10), DA.Date, 111) = CONVERT(VARCHAR(10), ST3.DataWystawienia, 111)
    --Time
	JOIN dbo.Time as TI ON TI.Hour = ST3.Hour
    --place
	JOIN dbo.Place as Place ON Place.Distric = ST3.Distric and Place.Street = ST3.Street

	--taka konstrukcja do ticketa policemana i criminala
    --criminal
	JOIN dbo.Police as police ON police. = ST2.Stanowisko and junk.TypeOfPayment = ST2.Platnosc

    --policeman
	JOIN dbo.DimBook ON dbo.DimBook.ISBN = x.FK_Ksiazka
WHERE SourcePriceRange = dbo.DimBook.PriceRange;
go


-- TODO
--	- dodaæ krotkê UNKNOWN do ka¿dego wymiaru i przypiywaæ jej klucz w funkcji ISNULL()

MERGE INTO Rating as TT
	USING vETLRating as ST
		ON 	
			TT.Points = ST.Points
		AND TT.ID_Policeman = ST.ID_Policeman
		AND TT.ID_Criminal = ST.ID_Criminal
		AND TT.ID_Ticket = ST.ID_Ticket
		AND TT.ID_Place = ST.ID_Place
		AND TT.ID_Date = ST.ID_Date
		AND TT.ID_Time = ST.ID_Time
			WHEN Not Matched
				THEN
					INSERT
					Values (
						  ST.Points
						, ST.ID_Policeman
						, ST.ID_Criminal
						, ST.ID_Ticket
						, ST.ID_Place
						, ST.ID_Date
						, ST.ID_Time
					)
			;

Drop view vETLRating;