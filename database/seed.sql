INSERT INTO Categories (Name) VALUES ('Drinks'), ('Food');

INSERT INTO Users (Id, FullName, Email, PasswordHash, Role, CreatedAt) VALUES
('11111111-1111-1111-1111-111111111111', 'Amina Hadzic', 'admin@smartpos.ba', 'seeded-by-api-on-first-run', 'Admin', SYSUTCDATETIME()),
('22222222-2222-2222-2222-222222222222', 'Emir Music', 'cashier1@smartpos.ba', 'seeded-by-api-on-first-run', 'Cashier', SYSUTCDATETIME()),
('33333333-3333-3333-3333-333333333333', 'Lejla Kovacevic', 'cashier2@smartpos.ba', 'seeded-by-api-on-first-run', 'Cashier', SYSUTCDATETIME()),
('44444444-4444-4444-4444-444444444444', 'Marko Ilic', 'manager@smartpos.ba', 'seeded-by-api-on-first-run', 'Manager', SYSUTCDATETIME());

INSERT INTO Products (Name, Price, CostPrice, StockQuantity, ReorderLevel, IsActive, CategoryId) VALUES
('Coffee', 3.50, 1.10, 120, 25, 1, 1),
('Coca Cola', 4.00, 1.80, 18, 30, 1, 1),
('Burger', 9.50, 4.10, 35, 15, 1, 2),
('Pizza', 11.00, 4.90, 25, 12, 1, 2),
('Water', 2.00, 0.70, 80, 30, 1, 1),
('Sandwich', 6.00, 2.40, 12, 20, 1, 2);

INSERT INTO AIInsights (Id, Type, Message, Date)
VALUES (NEWID(), 'BusinessSummary', 'Seed insight: coffee and soft drinks dominate morning and lunch demand.', SYSUTCDATETIME());
