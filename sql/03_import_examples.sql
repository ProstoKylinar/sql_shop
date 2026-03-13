USE InternetShop;
GO

/*
Пример содержимого Suppliers.txt:

20;Global Market
21;Tech Store
22;Online Vendor
*/

BULK INSERT Suppliers
FROM '/data/Suppliers_eng.txt'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 1
);

-- Проверка импорта
SELECT * FROM Suppliers;

