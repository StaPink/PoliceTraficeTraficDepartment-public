use TrafficDepartmentDW6
go

If (object_id('vETLFRATING') is not null) Drop view vETLFRATING;
go
CREATE VIEW vETLFRATING
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
		  Amount = ST1.LiczbaEgzemplarzy
		, PurchasePrice = ST1.Cena * ST1.LiczbaEgzemplarzy
		, Profit = ST1.Cena * ST1.LiczbaEgzemplarzy * 1.07
		, SellDateKey = SD.DateKey
		, PayDateKey = PD.DateKey
		, JunkKey = junk.JunkKey
		, SellerKey = IsNull(seller.SellerKey, -1)
		, TimeKey = dbo.DimTime.TimeKey
		, TransactionNo = ST2.NrRachunku
		, CASE
			WHEN [Cena] < 20 THEN 'tania'
			WHEN [Cena] BETWEEN 21 AND 100 THEN 'umiarkowana'
			ELSE 'droga'
		  END AS [SourcePriceRange]
		, FK_Ksiazka
		, pid = seller.PID
		, data_wystawienia = ST2.DataWystawienia
					
	FROM PoliceDepartemntWarehouse.dbo.SprzedazKsiazki AS ST1
	JOIN BillMaster.dbo.Rachunek as ST2 ON ST1.FK_Rachunek = ST2.NrRachunku


	JOIN dbo.DimDate as SD ON CONVERT(VARCHAR(10), SD.Date, 111) = CONVERT(VARCHAR(10), ST2.DataWystawienia, 111)
	JOIN dbo.DimDate as PD ON CONVERT(VARCHAR(10), PD.Date, 111) = CONVERT(VARCHAR(10), ST2.DataOplacenia, 111)
	JOIN dbo.DimJunk as junk ON junk.Position = ST2.Stanowisko and junk.TypeOfPayment = ST2.Platnosc
	left JOIN dbo.DimSeller as seller ON 
			seller.PID = ST2.FK_Sprzedawca
		and ST2.DataWystawienia BETWEEN seller.EntryDate AND isnull(seller.ExpiryDate, CURRENT_TIMESTAMP)
	JOIN dbo.DimTime ON dbo.DimTime.Hour = DATEPART(HOUR, ST2.DataWystawienia)
	) AS x
JOIN dbo.DimBook ON dbo.DimBook.ISBN = x.FK_Ksiazka
WHERE SourcePriceRange = dbo.DimBook.PriceRange;
go

MERGE INTO vETLFRATING as TT
	USING vETLFBookSales as ST
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

Drop view vETLFBookSales;
