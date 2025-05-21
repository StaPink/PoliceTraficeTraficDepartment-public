USE TrafficDepartmentDW;
GO

If (object_id('vETLDimTicket') is not null) Drop View vETLDimTicket;
go
CREATE VIEW vETLDimTicket
AS
SELECT DISTINCT
	--ticket_id,
	--ticket_description,
    violation_article,
	CASE
		WHEN amount BETWEEN 0 AND 999 THEN 'cheap'
		WHEN amount BETWEEN 1000 AND 2999 THEN 'normal'
		WHEN amount BETWEEN 3000 AND 6999 THEN 'expensive'
		WHEN amount >= 7000  THEN 'exceptional'
	END AS [AmountCategory]
FROM Police.dbo.Ticket;
go

MERGE INTO Ticket as TT
    USING vETLDimTicket as ST
        ON (TT.ViolationArticle = ST.violation_article AND TT.PriceCategory = ST.[AmountCategory] )
            WHEN Not Matched
                THEN
                    INSERT 
                    VALUES (
						--ST.ticket_description,
						ST.violation_article,
						ST.[AmountCategory]
                    )
            WHEN Not Matched By Source
                Then
                    DELETE
            ;

Drop View vETLDimTicket;