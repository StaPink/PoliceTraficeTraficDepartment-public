use master
alter database Police set single_user with rollback immediate
DROP DATABASE Police;

--DROP TABLE RatingOfService;
--DROP TABLE Ticket;
--DROP TABLE Criminal;
--DROP TABLE Officer;

--DELETE RatingOfService;
--DELETE Ticket;
--DELETE Criminal;
--DELETE Officer;