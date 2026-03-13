***

## Структура репозитория

```text
internet-shop-db/
├─ sql/
│  ├─ 01_create_db_and_tables.sql
│  ├─ 02_constraints_and_trigger.sql
│  ├─ 03_import_examples.sql
│  ├─ 04_users_and_permissions.sql
├─ data/
│  └─ Suppliers.txt
└─ README.md
```

***

# База данных InternetShop

Скрипты для создания и администрирования БД интернет‑магазина (MS SQL Server).

## 1. Подготовка

Нужно:

- запущенный SQL Server (локально или в контейнере);
- клиент SQL (DBeaver / Azure Data Studio);
- логин `sa` (или другой админ).

## 2. Создание базы и таблиц

1. Подключиться к серверу под админом.
2. Открыть `sql/01_create_db_and_tables.sql`.
3. Выполнить скрипт.

Результат:

- создаётся база `InternetShop`;
- создаются таблицы: `Customers`, `Orders`, `OdrersInfo`, `Products`,
  `Suppliers`, `ProductCategories`, `OrderStatuses`,
  `OrderStatusHistory`, `Reviews`;
- настраиваются все внешние ключи.

## 3. Ограничения и триггер

1. Выбрать базу `InternetShop`.
2. Выполнить `sql/02_constraints_and_trigger.sql`.

Результат:

- добавлены CHECK‑ограничения (email, количество товара, дата отзыва);
- в `OdrersInfo` добавлен столбец `line_total`;
- создан триггер `TRG_OdrersInfo_CalcLineTotal`,
  который пересчитывает `line_total = quantity * price`;
- добавлены тестовые данные (имена на английском).

Проверка:

```sql
SELECT * FROM OdrersInfo;
-- должна быть строка с line_total = 1000.00
```

## 4. Импорт / экспорт данных

### 4.1 Импорт .txt (BULK INSERT)

1. Скопировать файл `data/Suppliers.txt` в папку,
   которая доступна серверу (например, `/data/Suppliers_eng.txt`).
2. В базе `InternetShop` выполнить `sql/03_import_examples.sql`
   или прямо команду:

```sql
BULK INSERT Suppliers
FROM '/data/Suppliers_eng.txt'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 1
);

SELECT * FROM Suppliers;
```

### 4.2 Экспорт / импорт .xls

Экспорт в Excel:

- в клиенте БД использовать мастер экспорта (таблица `Suppliers` → Export → XLS/XLSX).

Импорт из Excel:

- создать таблицу‑приёмник (например, `SuppliersCopy`);
- использовать мастер импорта (Excel → таблица `SuppliersCopy`).

## 5. Пользователи и права

1. В базе `InternetShop` выполнить `sql/04_users_and_permissions.sql`.

Создаются:

- логины и пользователи:
  - `admin_app` / `AdminPass#1`
  - `order_manager_login` / `ManagerPass#1`
  - `analyst_login` / `AnalystPass#1`
- роли:
  - `db_admin_role` — полный доступ;
  - `order_manager_role` — управление заказами, чтение справочников;
  - `analyst_role` — только чтение.

Примеры проверки:

```sql
-- под order_manager_login (InternetShop):
INSERT INTO Orders (order_id, customer_id, address)
VALUES (2, 1, 'Manager test address');    -- ОК

INSERT INTO Suppliers (supplier_id, name)
VALUES (500, 'Manager Supplier');         -- ОШИБКА прав
```

```sql
-- под analyst_login:
SELECT * FROM Orders;                     -- ОК

INSERT INTO Orders (order_id, customer_id, address)
VALUES (10, 1, 'Analyst test');           -- ОШИБКА прав
