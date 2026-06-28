IF COL_LENGTH('dbo.Users', 'TwoFactorCode') IS NOT NULL
    ALTER TABLE dbo.Users DROP COLUMN TwoFactorCode;
GO

IF COL_LENGTH('dbo.Users', 'TwoFactorExpiresAt') IS NOT NULL
    ALTER TABLE dbo.Users DROP COLUMN TwoFactorExpiresAt;
GO

IF COL_LENGTH('dbo.Users', 'TwoFactorEnabled') IS NOT NULL
    ALTER TABLE dbo.Users DROP COLUMN TwoFactorEnabled;
GO
