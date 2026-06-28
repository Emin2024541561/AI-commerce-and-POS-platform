# Smart AI POS & Inventory Management System

Production-grade SaaS scaffold for restaurants, cafes, and retail stores. The project includes a .NET 8 Web API, SQL Server schema and seed scripts, JWT authentication, role-based authorization, AI analytics endpoints, Docker support, and a Flutter Material 3 frontend.

## Test Users

- Admin: `admin@smartpos.ba` / `Admin123!`
- Cashier: `cashier1@smartpos.ba` / `Cashier123!`
- Cashier: `cashier2@smartpos.ba` / `Cashier123!`
- Manager: `manager@smartpos.ba` / `Manager123!`

## Run With Docker

```powershell
docker compose up --build
```

API:

- Swagger: `http://localhost:5000/swagger`
- Base URL: `http://localhost:5000`

The API creates the SQL Server database and seeds users, categories, products, 45 realistic sales, stock levels, and an initial AI insight on first startup.

## Run Backend Locally

```powershell
cd backend
dotnet restore
dotnet run
```

Configure production settings through environment variables or `appsettings.json`:

- `ConnectionStrings__DefaultConnection`
- `Jwt__Issuer`
- `Jwt__Audience`
- `Jwt__Key`
- `OpenAI__ApiKey`
- `OpenAI__Model`

## Run Flutter

The `frontend/lib` app is complete and uses stock Flutter APIs only. If platform wrappers are not present on your machine, generate them once:

```powershell
cd frontend
flutter create --platforms=android,ios,web,windows,macos,linux .
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000
```

## Architecture

- Backend: Controller -> Service -> Repository -> EF Core DbContext.
- Auth: JWT access tokens and hashed refresh tokens.
- Roles: Admin, Manager, Cashier.
- Database: normalized SQL Server tables with foreign keys and performance indexes.
- AI: deterministic structured JSON analytics using sales/product data, with `OpenAI` config placeholders for production prompt-backed summaries.
- Frontend: Material 3 responsive UI with a lightweight Bloc-style `ValueNotifier` state layer, API client, POS cart, dashboard, products, inventory, sales, AI, and profile screens.

## Key Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `GET /products`
- `POST /products`
- `PUT /products/{id}`
- `DELETE /products/{id}`
- `POST /sales/create`
- `GET /sales`
- `GET /sales/{id}`
- `GET /inventory/low-stock`
- `POST /inventory/update`
- `GET /ai/forecast-sales`
- `GET /ai/recommend-restock`
- `GET /ai/insights`
- `GET /dashboard/stats`

## Database Scripts

- `database/schema.sql` contains the normalized SQL Server schema.
- `database/seed.sql` contains static reference seed data.
- The API has richer first-run seed logic in `backend/Data/SeedData.cs`, including 45 generated sales transactions.
