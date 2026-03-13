USE InternetShop;
GO

ALTER TABLE Customers
ADD CONSTRAINT CK_Customers_Email
CHECK (email LIKE '%@%.%');

ALTER TABLE Products
ADD CONSTRAINT CK_Products_Quantity
CHECK (quantity IS NULL OR quantity >= 0);

ALTER TABLE Reviews
ADD CONSTRAINT CK_Reviews_Date
CHECK (date <= GETDATE());

-- Вычислимый атрибут в OdrersInfo

ALTER TABLE OdrersInfo
ADD line_total DECIMAL(12,2) NULL
    CHECK (line_total >= 0);

-- Триггер для пересчёта line_total

IF OBJECT_ID('TRG_OdrersInfo_CalcLineTotal', 'TR') IS NOT NULL
    DROP TRIGGER TRG_OdrersInfo_CalcLineTotal;
GO

CREATE TRIGGER TRG_OdrersInfo_CalcLineTotal
ON OdrersInfo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE oi
    SET line_total = oi.quantity * p.price
    FROM OdrersInfo oi
    INNER JOIN inserted i
        ON oi.order_id = i.order_id
       AND oi.product_id = i.product_id
    INNER JOIN Products p
        ON p.product_id = oi.product_id;
END;
GO

-- Тестовые данные

INSERT INTO Customers (customer_id, name, email, birthdate, gender)
VALUES (1, 'John Smith', 'john.smith@example.com', '1990-01-01', 'male');

INSERT INTO Suppliers (supplier_id, name)
VALUES (1, 'Acme Supplier');

INSERT INTO ProductCategories (product_category_id, category_name)
VALUES (1, 'Electronics');

INSERT INTO Products (product_id, product_name, product_category_id, quantity, supplier_id, price)
VALUES (1, 'Smartphone', 1, 100, 1, 500.00);

INSERT INTO OrderStatuses (order_status_id, name)
VALUES (1, 'Created'), (2, 'Paid');

INSERT INTO Orders (order_id, customer_id, address)
VALUES (1, 1, 'Test street 1, City');

INSERT INTO OrderStatusHistory (order_id, order_status_id)
VALUES (1, 1);

INSERT INTO OdrersInfo (order_id, product_id, quantity)
VALUES (1, 1, 2);
