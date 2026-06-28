namespace SmartAiPos.Api.Models;

public enum UserRole
{
    Admin = 1,
    Manager = 2,
    Cashier = 3,
    Customer = 4
}

public enum PaymentMethod
{
    Cash = 1,
    Card = 2,
    Digital = 3
}

public enum InsightType
{
    SalesForecast = 1,
    Restock = 2,
    Popularity = 3,
    Anomaly = 4,
    BusinessSummary = 5
}

public enum OrderStatus
{
    Pending = 1,
    Completed = 2,
    Cancelled = 3
}