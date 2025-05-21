CREATE DATABASE Police
GO

USE Police
GO

create table Officer(
	badge_number int PRIMARY KEY,
	pesel char(11) UNIQUE,
	first_name varchar(20),
	surname varchar(20),
	job_title varchar(40),
	job_rank int,
	is_updated int
);

create table Criminal(
	criminal_id int PRIMARY KEY,
	pesel char(11) UNIQUE,
	first_name varchar(20),
	surname varchar(20),
	penalty_points int , -- CHECK (penalty_points >= 0 AND penalty_points <= 24)
	is_updated int
);

--SELECT * FROM Criminal

create table Ticket(
	ticket_id int PRIMARY KEY,
	officer_badge_number int NOT NULL FOREIGN KEY REFERENCES Officer(badge_number),
	criminal_id int NOT NULL FOREIGN KEY REFERENCES Criminal(criminal_id),
	--criminal_pesel char(11) UNIQUE FOREIGN KEY REFERENCES Criminal(pesel),
	ticket_description varchar(200),
	violation_article varchar(100),
	penalty_points int CHECK (penalty_points >= 0 AND penalty_points <= 24),
	datetime_of_issue datetime,
	amount int,
	street varchar(100),
	district varchar(50),
	is_updated int
);

create table RatingOfService(
	rating_id int PRIMARY KEY,
	points float CHECK (points >= 0 AND points <= 5),
	comments varchar(500),
	officer_badge_number int NOT NULL FOREIGN KEY REFERENCES Officer(badge_number),
	criminal_id int NOT NULL FOREIGN KEY REFERENCES Criminal(criminal_id),
	is_updated int
);