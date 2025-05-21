CREATE DATABASE TrafficDepartmentDW
GO

USE TrafficDepartmentDW
GO

CREATE TABLE [Date]
(
    ID_Date INT IDENTITY(1,1) PRIMARY KEY,
    [Date] DATETIME UNIQUE,
	[Year] VARCHAR(4),
	[Month] VARCHAR(10),
	MonthNo	TINYINT,
	[Day] VARCHAR(2),
	CONSTRAINT chk_Month CHECK ([Month] IN ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')),
)
GO

CREATE TABLE [Time](
	ID_Time INT IDENTITY(1,1) PRIMARY KEY,
	[Hour] INT,
	[Minute] INT,
	[Second] INT,
	TimeOfDay VARCHAR(20) NOT NULL,
	CONSTRAINT chk_TimeOfDay CHECK (TimeOfDay IN ('between 0 and 8', 'between 9 and 12', 'between 13 and 15', 'between 16 and 20', 'between 21 and 23'))
)
GO

CREATE TABLE Place(
	ID_Place INT IDENTITY(1,1) PRIMARY KEY,
	Street VARCHAR(100),
	District VARCHAR(50),
)
GO

CREATE TABLE Ticket(
	ID_Ticket INT IDENTITY(1,1) PRIMARY KEY,
	DB_ID_Ticket INT UNIQUE,
	--[Description] VARCHAR(200),
	ViolationArticle VARCHAR(100),
	PriceCategory VARCHAR(15),
	CONSTRAINT chk_PriceCategory CHECK (PriceCategory IN ('cheap', 'normal', 'expensive', 'exceptional'))
)
GO

CREATE TABLE Policeman(
	ID_Policeman INT IDENTITY(1,1) PRIMARY KEY,
	BadgeNumber VARCHAR(6),
	JobRankCategory VARCHAR(6),
	JobTitle VARCHAR(40),
	[Address] VARCHAR(200),
	City VARCHAR(100),
	AverageRatingCategory VARCHAR(15),
	CommentsRegardingWork VARCHAR(200),
	HadHistoryOfBrutalArrests BIT,
	FirstName VARCHAR(20),
	Surname VARCHAR(20),
	WorkExperience VARCHAR(35),
	IsCurrent BIT,
	CONSTRAINT chk_JobRankCategory CHECK (JobRankCategory IN ('low', 'medium', 'high')),
	CONSTRAINT chk_JobTitle CHECK (JobTitle IN ('Traffic Officer', 'Traffic Patrol Officer', 'Traffic Corporal/Sergeant', 'Traffic Lieutenant')),
	CONSTRAINT chk_AverageRatingCategory CHECK (AverageRatingCategory IN ('0', 'between 0 and 1','1', 'between 1 and 2', '2', 'between 2 and 3', '3', 'between 3 and 4', '4', 'between 4 and 5', '5')),
	CONSTRAINT chk_WorkExperience CHECK (WorkExperience IN ('up to one year', 'between one and five years', 'between five years and ten years', 'more than ten years')),
)
GO

CREATE TABLE Criminal(
	ID_Criminal INT IDENTITY(1,1) PRIMARY KEY,
	PenaltyPointsCategory VARCHAR(20),
	IsOnProbation BIT,
	FirstName VARCHAR(20),
	Surname VARCHAR(20),
	Pesel VARCHAR(11),
	AgeCategory VARCHAR(20),
	IsCurrent BIT,
	CONSTRAINT chk_PenaltyPointsCategory CHECK (PenaltyPointsCategory IN ('between 0 and 8', 'between 9 and 16', 'between 17 and 24')),
	CONSTRAINT chk_AgeCategory CHECK (AgeCategory IN ('between 18 and 25', 'between 26 and 35', 'between 36 and 50', 'between 51 and 60', '61 and more')),
)
GO

--SELECT * FROM Criminal

CREATE TABLE Rating(
	Points FLOAT,
	ID_Policeman INT FOREIGN KEY REFERENCES Policeman,
	ID_Criminal INT FOREIGN KEY REFERENCES Criminal,
	ID_Ticket INT FOREIGN KEY REFERENCES Ticket,
	ID_Place INT FOREIGN KEY REFERENCES Place,
	ID_Date INT FOREIGN KEY REFERENCES [Date],
	ID_Time INT FOREIGN KEY REFERENCES [Time],

	CONSTRAINT Composite_PK_Rating PRIMARY KEY (
		ID_Policeman,
		ID_Criminal, 
		ID_Ticket, 
		ID_Place, 
		ID_Date, 
		ID_Time
	)
)
GO

CREATE TABLE GivingTickets(
	PenaltyPoints INT,
	Amount INT,
	ID_Policeman INT FOREIGN KEY REFERENCES Policeman,
	ID_Criminal INT FOREIGN KEY REFERENCES Criminal,
	ID_Ticket INT FOREIGN KEY REFERENCES Ticket,
	ID_Place INT FOREIGN KEY REFERENCES Place,
	ID_Date INT FOREIGN KEY REFERENCES [Date],
	ID_Time INT FOREIGN KEY REFERENCES [Time],

	CONSTRAINT Composite_PK_GivingTickets PRIMARY KEY (
		ID_Policeman,
		ID_Criminal, 
		ID_Ticket, 
		ID_Place, 
		ID_Date, 
		ID_Time
	)
)
GO

--use master
--alter database TrafficDepartmentDW set single_user with rollback immediate
--drop database TrafficDepartmentDW