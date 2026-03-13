CREATE DATABASE InternetShop;
GO

USE InternetShop;
GO

-- Покупатели
CREATE TABLE Customers
(
    customer_id INT           NOT NULL,
    name        VARCHAR(120)  NULL,
    email       VARCHAR(70)   NOT NULL,
    birthdate   DATETIME      NULL,
    gender      VARCHAR(10)   NULL
        CHECK (gender IN ('male','female'))
);

ALTER TABLE Customers
ADD CONSTRAINT PK_Customers PRIMARY KEY (customer_id);

-- Состав заказа (многие-ко-многим заказ–товар)
CREATE TABLE OdrersInfo
(
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL
        CHECK (quantity > 0)
);

ALTER TABLE OdrersInfo
ADD CONSTRAINT PK_OdrersInfo PRIMARY KEY (product_id, order_id);

-- Заказы
CREATE TABLE Orders
(
    order_id    INT          NOT NULL,
    customer_id INT          NOT NULL,
    address     VARCHAR(500) NOT NULL,
    order_date  DATETIME     NOT NULL DEFAULT GETDATE()
);

ALTER TABLE Orders
ADD CONSTRAINT PK_Orders PRIMARY KEY (order_id);

-- Статусы заказа (справочник)
CREATE TABLE OrderStatuses
(
    order_status_id INT         NOT NULL,
    name            VARCHAR(30) NOT NULL
);

ALTER TABLE OrderStatuses
ADD CONSTRAINT PK_OrderStatuses PRIMARY KEY (order_status_id);

-- История статусов
CREATE TABLE OrderStatusHistory
(
    order_id        INT      NOT NULL,
    order_status_id INT      NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT GETDATE()
);

ALTER TABLE OrderStatusHistory
ADD CONSTRAINT PK_OrderStatusHistory PRIMARY KEY (order_id, order_status_id, created_at);

-- Категории товаров (справочник)
CREATE TABLE ProductCategories
(
    product_category_id INT          NOT NULL,
    category_name       VARCHAR(100) NOT NULL
);

ALTER TABLE ProductCategories
ADD CONSTRAINT PK_ProductCategories PRIMARY KEY (product_category_id);

-- Товары
CREATE TABLE Products
(
    product_id          INT           NOT NULL,
    product_name        VARCHAR(500)  NOT NULL,
    product_category_id INT           NOT NULL,
    quantity            INT           NULL,
    supplier_id         INT           NOT NULL,
    price               DECIMAL(10,2) NOT NULL
        CHECK (price >= 0)
);

ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY (product_id);

-- Отзывы
CREATE TABLE Reviews
(
    review_id   INT           NOT NULL,
    text        VARCHAR(1000) NULL,
    date        DATETIME      NOT NULL,
    score       TINYINT       NOT NULL
        CHECK (score BETWEEN 1 AND 5),
    product_id  INT           NOT NULL,
    customer_id INT           NOT NULL
);

ALTER TABLE Reviews
ADD CONSTRAINT PK_Reviews PRIMARY KEY (review_id);

-- Поставщики (справочник)
CREATE TABLE Suppliers
(
    supplier_id INT          NOT NULL,
    name        VARCHAR(256) NOT NULL
);

ALTER TABLE Suppliers
ADD CONSTRAINT PK_Suppliers PRIMARY KEY (supplier_id);

-- ВНЕШНИЕ КЛЮЧИ

ALTER TABLE OdrersInfo
ADD CONSTRAINT FK_OdrersInfo_Orders
    FOREIGN KEY (order_id) REFERENCES Orders (order_id);

ALTER TABLE OdrersInfo
ADD CONSTRAINT FK_OdrersInfo_Products
    FOREIGN KEY (product_id) REFERENCES Products (product_id);

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id);

ALTER TABLE OrderStatusHistory
ADD CONSTRAINT FK_OSH_Orders
    FOREIGN KEY (order_id) REFERENCES Orders (order_id);

ALTER TABLE OrderStatusHistory
ADD CONSTRAINT FK_OSH_OrderStatuses
    FOREIGN KEY (order_status_id) REFERENCES OrderStatuses (order_status_id);

ALTER TABLE Products
ADD CONSTRAINT FK_Products_Suppliers
    FOREIGN KEY (supplier_id) REFERENCES Suppliers (supplier_id);

ALTER TABLE Products
ADD CONSTRAINT FK_Products_ProductCategories
    FOREIGN KEY (product_category_id) REFERENCES ProductCategories (product_category_id);

ALTER TABLE Reviews
ADD CONSTRAINT FK_Reviews_Products
    FOREIGN KEY (product_id) REFERENCES Products (product_id);

ALTER TABLE Reviews
ADD CONSTRAINT FK_Reviews_Customers
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id);
