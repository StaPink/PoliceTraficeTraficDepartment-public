use TrafficDepartmentDW;
go

If (object_id('dbo.OfficersTemp') is not null) DROP TABLE dbo.OfficersTemp;
CREATE TABLE dbo.OfficersTemp
(
	badge_number varchar(6), 
	pesel varchar(11), 
	first_name varchar(20), 
	surname varchar(20), 
	job_title varchar(40), 
	job_rank int, 
	is_updated BIT, 
	street_and_house_num varchar(200), 
	city varchar(100), 
	avg_rating float, 
	comments varchar(200), 
	start_year varchar(4), 
	had_history_of_brutal_arrests BIT
	);
go

BULK INSERT dbo.OfficersTemp
    FROM 'C:\Users\wikto\Desktop\generowanieDanych\officer_data_Excel.csv'
    WITH
    (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n' -- '0x0a'
    )

 --SELECT * FROM dbo.OfficersTemp;

-- DROP TABLE dbo.OfficersTemp

If (object_id('vETLDimPolicemanData') is not null) Drop View vETLDimPolicemanData;
go
CREATE VIEW vETLDimPolicemanData
AS
SELECT 
	badge_number,
	CASE
	WHEN job_rank = 1 THEN 'low'
	WHEN job_rank = 2 THEN 'medium'
	WHEN job_rank = 3 THEN 'high'
	END AS job_rank_category,
	job_title,
	[address] = street_and_house_num,
	city,
	CASE
	WHEN avg_rating = 0 THEN '0'
	WHEN avg_rating BETWEEN 0 AND 1 THEN 'between 0 and 1'
	WHEN avg_rating = 1 THEN '1'
	WHEN avg_rating BETWEEN 1 AND 2 THEN 'between 1 and 2'
	WHEN avg_rating = 2 THEN '2'
	WHEN avg_rating BETWEEN 2 AND 3 THEN 'between 2 and 3'
	WHEN avg_rating = 3 THEN '3'
	WHEN avg_rating BETWEEN 3 AND 4 THEN 'between 3 and 4'
	WHEN avg_rating = 4 THEN '4'
	WHEN avg_rating BETWEEN 4 AND 5 THEN 'between 4 and 5'
	WHEN avg_rating = 5 THEN '5'
	END AS avg_rating_category,
	comments,
	had_history_of_brutal_arrests,
	first_name,
	surname,
	CASE
		WHEN DATEDIFF(year, start_year, CURRENT_TIMESTAMP) BETWEEN 0 AND 1 THEN 'up to one year'
		WHEN DATEDIFF(year, start_year, CURRENT_TIMESTAMP) BETWEEN 1 AND 5 THEN 'between one and five years'
		WHEN DATEDIFF(year, start_year, CURRENT_TIMESTAMP) BETWEEN 5 AND 10 THEN 'between five years and ten years'
		WHEN DATEDIFF(year, start_year, CURRENT_TIMESTAMP) > 10 THEN 'more than ten years'
	END AS work_experience
FROM dbo.OfficersTemp;
go

--SELECT * FROM vETLDimPolicemanData;

--DROP VIEW vETLDimPolicemanData;

--DELETE FROM Policeman 

MERGE INTO Policeman as P
	USING vETLDimPolicemanData as PD
		ON P.BadgeNumber = PD.badge_number
			WHEN Not Matched
				THEN
					INSERT Values (
					PD.badge_number,
					PD.job_rank_category,
					PD.job_title,
					PD.[address],
					PD.city,
					PD.avg_rating_category,
					PD.comments,
					PD.had_history_of_brutal_arrests,
					PD.first_name,
					PD.surname,
					PD.work_experience,
					1
					)
			WHEN Matched 
				AND (PD.job_rank_category <> P.JobRankCategory
				OR PD.job_title <> P.JobTitle
				OR PD.[address] <> P.[Address]
				OR PD.avg_rating_category <> P.AverageRatingCategory
				OR PD.comments <> P.CommentsRegardingWork
				OR PD.had_history_of_brutal_arrests <> P.HadHistoryOfBrutalArrests
				OR PD.first_name <> P.FirstName
				OR PD.surname <> P.Surname
				OR PD.work_experience <> P.WorkExperience)
			THEN
				UPDATE
				SET P.IsCurrent = 0
			-- WHEN Not Matched BY Source
			-- AND P.ID_Policeman != 'UNKNOWN' -- do not update the UNKNOWN tuple
			-- THEN
			--	UPDATE
			--	SET P.IsCurrent = 0
			;

INSERT INTO Policeman(
	BadgeNumber,
	JobRankCategory,
	JobTitle,
	[Address],
	City,
	AverageRatingCategory,
	CommentsRegardingWork,
	HadHistoryOfBrutalArrests,
	FirstName,
	Surname,
	WorkExperience,
	IsCurrent
	)
	SELECT 
		badge_number,
		job_rank_category,
		job_title,
		[address],
		city,
		avg_rating_category,
		comments,
		had_history_of_brutal_arrests,
		first_name,
		surname,
		work_experience,
		1
	FROM vETLDimPolicemanData
	EXCEPT
	SELECT 
		BadgeNumber,
		JobRankCategory,
		JobTitle,
		[Address],
		City,
		AverageRatingCategory,
		CommentsRegardingWork,
		HadHistoryOfBrutalArrests,
		FirstName,
		Surname,
		WorkExperience,
		1
	FROM Policeman;


--SELECT * FROM Policeman WHERE BadgeNumber = 100000

--SELECT * FROM Policeman WHERE IsCurrent = 0;

DROP TABLE OfficersTemp;
DROP VIEW vETLDimPolicemanData;