use TrafficDepartmentDW;
go

If (object_id('Pesel') is not null) DROP FUNCTION Pesel;
go
CREATE FUNCTION dbo.Pesel (@pesel nvarchar(11))
RETURNS @ret TABLE
(
  birth_date date,
  gender char,
  valid int
)
AS
BEGIN
  --Wspó³czynniki sumy kontrolnej
  DECLARE @fact varchar(11)='13791379131'
  --Suma kontrolna
  DECLARE @sum int=0
  DECLARE @i int=1
  --Czy numer PESEL jest prawid³owy
  DECLARE @valid int=1
  --Czy w numerze s¹ same cyfry
  DECLARE @validInt int=1
  DECLARE @c char
  DECLARE @date date
  DECLARE @gender char
  
  --SprawdŸ d³ugoœæ numeru PESEL
  IF (LEN(@pesel)!=11)
    SET @validInt=0
  ELSE
    WHILE @i<=11
    BEGIN
      --SprawdŸ, czy wszystkie znaki to cyfry
      --Je¿eli tak, policz sumê kontroln¹
      SET @c=SUBSTRING(@pesel,@i,1)
      IF (@c<'0' OR @c>'9')
        SET @validInt=0
      ELSE
        SET @sum+=CAST(SUBSTRING(@fact,@i,1) as int)*@c
      SET @i+=1
    END

  IF @sum%10!=0 OR @validInt=0
    SET @valid=0
  
  IF @validInt=1
  BEGIN
    DECLARE @int int = SUBSTRING(@pesel,1,2)
    DECLARE @rok int = 1900+@int;
    --Przeanalizuj pierwsz¹ cyfrê miesi¹ca, mo¿e tam byæ
    --informacja o latach 1800-1899 i 2000-2299
    SET @int = SUBSTRING(@pesel,3,1)
    IF (@int>=2 AND @int<8)
      SET @rok+=@int/2*100;
    IF (@int>=8)
      SET @rok-=100;

    DECLARE @miesiac int = (@int%2)*10+SUBSTRING(@pesel,4,1);

    DECLARE @str varchar(10) = CAST(@rok AS varchar)+
      CASE WHEN @miesiac<10 THEN '0' ELSE '' END+
      CAST(@miesiac AS varchar)+SUBSTRING(@pesel,5,2);
    IF ISDATE(@str)=1
      SET @date=CAST(@str as date)
    ELSE
      SET @valid=0
    --P³eæ zapisana jest na 10 znaku
    SET @gender = CASE WHEN SUBSTRING(@pesel,10,1)%2=1 THEN 'M' ELSE 'K' END
  END
  
  INSERT INTO @ret (birth_date, gender, valid) VALUES (@date, @gender, @valid)
  RETURN
END
go

If (object_id('dbo.CriminalsTemp') is not null) DROP TABLE dbo.CriminalsTemp;
CREATE TABLE dbo.CriminalsTemp
(
	criminal_id	varchar(6),
	pesel varchar(11), 
	first_name varchar(20), 
	surname varchar(20), 
	penalty_points int, 
	is_updated BIT, 
	is_on_probation BIT
	);
go

BULK INSERT dbo.CriminalsTemp
    FROM 'C:\Users\wikto\Desktop\generowanieDanych\criminals_data_Excel.csv'
    WITH
    (
    FIELDTERMINATOR = '|',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --'0x0a'
    )

--SELECT * FROM dbo.CriminalsTemp;

-- DROP TABLE dbo.CriminalsTemp


If (object_id('vETLDimCriminalData') is not null) Drop View vETLDimCriminalData;
go
CREATE VIEW vETLDimCriminalData
AS
SELECT 
	CASE
	WHEN penalty_points BETWEEN 0 AND 8 THEN 'between 0 and 8'
	WHEN penalty_points BETWEEN 9 AND 16 THEN 'between 9 and 16'
	WHEN penalty_points BETWEEN 17 AND 24 THEN 'between 17 and 24'
	END AS penalty_points_category,
	is_on_probation,
	first_name,
	surname,
	pesel,
	birth_date,
	CASE 
	WHEN MONTH(GETDATE()) > MONTH(birth_date) OR MONTH(GETDATE()) = MONTH(birth_date) AND DAY(GETDATE()) >= DAY(birth_date) THEN DATEDIFF(year, birth_date, GETDATE()) 
	ELSE DATEDIFF(year, birth_date, GETDATE()) - 1
	END AS age,
	CASE
	WHEN DATEDIFF(year, birth_date, GETDATE()) BETWEEN 18 AND 25 THEN 'between 18 and 25'
	WHEN DATEDIFF(year, birth_date, GETDATE()) BETWEEN 26 AND 35 THEN 'between 26 and 35'
	WHEN DATEDIFF(year, birth_date, GETDATE()) BETWEEN 36 AND 50 THEN 'between 36 and 50'
	WHEN DATEDIFF(year, birth_date, GETDATE()) BETWEEN 51 AND 60 THEN 'between 51 and 60'
	WHEN DATEDIFF(year, birth_date, GETDATE()) >= 61  THEN '61 and more'
	END as age_category
FROM dbo.CriminalsTemp
CROSS APPLY dbo.Pesel(pesel);
go

--SELECT * FROM vETLDimCriminalData;

--DROP VIEW vETLDimCriminalData;

MERGE INTO Criminal as C
	USING vETLDimCriminalData as CD
		ON C.Pesel = CD.pesel
			WHEN Not Matched
				THEN
					INSERT Values (
					CD.penalty_points_category,
					CD.is_on_probation,
					CD.first_name,
					CD.surname,
					CD.pesel,
					CD.age_category,
					1
					)
			WHEN Matched 
				AND (CD.penalty_points_category <> C.PenaltyPointsCategory
				OR CD.is_on_probation <> C.IsOnProbation
				OR CD.first_name <> C.FirstName
				OR CD.surname <> C.Surname
				OR CD.age_category <> C.AgeCategory)
				--AND C.IsCurrent <> 0
			THEN
				UPDATE
				SET C.IsCurrent = 0
			-- WHEN Not Matched BY Source
			-- AND C.ID_Criminal != 'UNKNOWN' -- do not update the UNKNOWN tuple
			-- THEN
			--	UPDATE
			--	SET C.IsCurrent = 0
			;

-- INSERTING CHANGED ROWS TO THE Criminal TABLE
INSERT INTO Criminal(
	PenaltyPointsCategory,
	IsOnProbation,
	FirstName,
	Surname,
	Pesel,
	AgeCategory,
	IsCurrent
	)
	SELECT 
		penalty_points_category,
		is_on_probation,
		first_name,
		surname,
		pesel,
		age_category,
		1
	FROM vETLDimCriminalData
	EXCEPT
	SELECT 
		PenaltyPointsCategory,
		IsOnProbation,
		FirstName,
		Surname,
		Pesel,
		AgeCategory,
		1
	FROM Criminal;

--SELECT * FROM Criminal;

DROP TABLE dbo.CriminalsTemp;
Drop View vETLDimCriminalData; 

--SELECT * FROM Criminal WHERE pesel=83111212449


