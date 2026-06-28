using System.Security.Cryptography;

namespace SmartAiPos.Api.Services;

public static class PasswordHasher
{
    public static string Hash(string password)
    {
        var salt = RandomNumberGenerator.GetBytes(16);
        using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100_000, HashAlgorithmName.SHA256);
        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(pbkdf2.GetBytes(32))}";
    }

    public static bool Verify(string password, string hash)
    {
        var parts = hash.Split('.');
        if (parts.Length != 2) return false;

        var salt = Convert.FromBase64String(parts[0]);
        var expected = Convert.FromBase64String(parts[1]);

        using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100_000, HashAlgorithmName.SHA256);
        return CryptographicOperations.FixedTimeEquals(expected, pbkdf2.GetBytes(32));
    }
}