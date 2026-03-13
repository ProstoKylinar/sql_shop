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

Добавим в итоговый README минимальный раздел про запуск контейнера и подключение.

***


## 0. Запуск SQL Server в Podman (macOS)

1. Убедиться, что podman‑машина запущена:

   ```bash
   podman machine start
   ```
   или если такой нет то создать и запустить
   ```bash
   podman machine init --cpus=4 --disk-size=60 --memory=6144 -v $HOME:$HOME

   podman machine start
   ```

2. Создать локальную папку для файлов импорта:

   ```bash
   mkdir -p $HOME/sql-data
   ```

3. Запустить контейнер с MS SQL Server:

   ```bash
   podman run -d \
     --name mssql2022 \
     -e "ACCEPT_EULA=Y" \
     -e "MSSQL_SA_PASSWORD=StrongPass#1" \
     -p 1433:1433 \
     -v $HOME/sql-data:/data \
     mcr.microsoft.com/mssql/server:2022-latest
   ```

   - сервер доступен на `localhost:1433`
   - логин: `sa`
   - пароль: `StrongPass#1`
   - папка `$HOME/sql-data` на хосте видна в контейнере как `/data`. Заметьте, что файл data/Suppliers.txt либо нужно примонтировать, изменив соответствующую строку в команде, либо скопировать содержимое в $HOME/sql-data и запустить эту команду без изменений

Проверка:

```bash
podman ps
```

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
   которая доступна серверу (например, `/data/Suppliers.txt`).
2. В базе `InternetShop` выполнить `sql/03_import_examples.sql`
   или прямо команду:

```sql
BULK INSERT Suppliers
FROM '/data/Suppliers.txt'
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
