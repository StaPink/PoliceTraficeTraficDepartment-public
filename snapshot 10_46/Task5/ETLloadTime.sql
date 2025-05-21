use TrafficDepartmentDW
go

DECLARE @Hour INT, @Minute INT, @Second INT, @TimeOfDay VARCHAR(20);

SET @Hour = 0;
WHILE @Hour < 24
BEGIN
    SET @Minute = 0;
    WHILE @Minute < 60
    BEGIN
        SET @Second = 0;
        WHILE @Second < 60
        BEGIN
            SET @TimeOfDay = 
                CASE 
                    WHEN @Hour < 9 THEN 'between 0 and 8'
                    WHEN @Hour < 13 THEN 'between 9 and 12'
                    WHEN @Hour < 16 THEN 'between 13 and 15'
                    WHEN @Hour < 21 THEN 'between 16 and 20'
                    ELSE 'between 21 and 23'
                END;

            INSERT INTO dbo.[Time] ([Hour], [Minute], [Second], TimeOfDay) 
            VALUES (@Hour, @Minute, @Second, @TimeOfDay);

            SET @Second = @Second + 1;
        END
        SET @Minute = @Minute + 1;
    END
    SET @Hour = @Hour + 1;
END