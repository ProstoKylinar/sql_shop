USE InternetShop;
GO

-- Логины

CREATE LOGIN admin_app WITH PASSWORD = 'AdminPass#1',
    CHECK_POLICY = OFF;
CREATE LOGIN order_manager_login WITH PASSWORD = 'ManagerPass#1',
    CHECK_POLICY = OFF;
CREATE LOGIN analyst_login WITH PASSWORD = 'AnalystPass#1',
    CHECK_POLICY = OFF;
GO

-- Пользователи

CREATE USER admin_app    FOR LOGIN admin_app;
CREATE USER order_manager FOR LOGIN order_manager_login;
CREATE USER analyst      FOR LOGIN analyst_login;
GO

-- Роли

CREATE ROLE db_admin_role;
CREATE ROLE order_manager_role;
CREATE ROLE analyst_role;
GO

-- Привязка пользователей к ролям

EXEC sp_addrolemember 'db_admin_role',      'admin_app';
EXEC sp_addrolemember 'order_manager_role', 'order_manager';
EXEC sp_addrolemember 'analyst_role',       'analyst';
GO

-- Права для администратора

GRANT SELECT, INSERT, UPDATE, DELETE ON Customers          TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Suppliers          TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ProductCategories  TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products           TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Orders             TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON OdrersInfo         TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON OrderStatuses      TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON OrderStatusHistory TO db_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reviews            TO db_admin_role;

-- Права для менеджера заказов

GRANT SELECT ON Customers          TO order_manager_role;
GRANT SELECT ON Products           TO order_manager_role;
GRANT SELECT ON Suppliers          TO order_manager_role;
GRANT SELECT ON ProductCategories  TO order_manager_role;
GRANT SELECT ON OrderStatuses      TO order_manager_role;

GRANT SELECT, INSERT, UPDATE ON Orders             TO order_manager_role;
GRANT SELECT, INSERT, UPDATE ON OdrersInfo         TO order_manager_role;
GRANT SELECT, INSERT, UPDATE ON OrderStatusHistory TO order_manager_role;

DENY INSERT, UPDATE, DELETE ON Suppliers          TO order_manager_role;
DENY INSERT, UPDATE, DELETE ON ProductCategories  TO order_manager_role;
DENY INSERT, UPDATE, DELETE ON OrderStatuses      TO order_manager_role;

-- Права для аналитика (read-only)

GRANT SELECT ON Customers          TO analyst_role;
GRANT SELECT ON Suppliers          TO analyst_role;
GRANT SELECT ON ProductCategories  TO analyst_role;
GRANT SELECT ON Products           TO analyst_role;
GRANT SELECT ON Orders             TO analyst_role;
GRANT SELECT ON OdrersInfo         TO analyst_role;
GRANT SELECT ON OrderStatuses      TO analyst_role;
GRANT SELECT ON OrderStatusHistory TO analyst_role;
GRANT SELECT ON Reviews            TO analyst_role;
