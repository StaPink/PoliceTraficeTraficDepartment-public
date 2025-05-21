USE Police
GO
BULK INSERT Criminal FROM 'C:\Users\wikto\Desktop\generowanieDanych\criminal_data.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
BULK INSERT Ticket FROM 'C:\Users\wikto\Desktop\generowanieDanych\ticket_data.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
BULK INSERT Officer FROM 'C:\Users\wikto\Desktop\generowanieDanych\officer_data.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
BULK INSERT RatingOfService FROM 'C:\Users\wikto\Desktop\generowanieDanych\rating_data.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');

BULK INSERT Criminal FROM 'C:\Users\wikto\Desktop\generowanieDanych\criminal_dataT2.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
BULK INSERT Ticket FROM 'C:\Users\wikto\Desktop\generowanieDanych\ticket_dataT2.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
BULK INSERT Officer FROM 'C:\Users\wikto\Desktop\generowanieDanych\officer_dataT2.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
BULK INSERT RatingOfService FROM 'C:\Users\wikto\Desktop\generowanieDanych\rating_dataT2.csv' WITH (FIELDTERMINATOR='|', ROWTERMINATOR = '$');
