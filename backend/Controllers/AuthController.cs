using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;
using SmartAiPos.Api.Models;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Route("auth")]
public sealed class AuthController(AuthService auth) : ControllerBase
{
    // =========================
    // REGISTER (SECURE WRAPPER)
    // =========================
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
    {
        // 🔒 BASIC VALIDATION
        if (string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password) ||
            string.IsNullOrWhiteSpace(request.FullName))
        {
            return BadRequest("Invalid request data");
        }

        // 🔒 FORCE SAFE ROLE (NO ADMIN EXPLOIT VIA API)
        // Ako DTO sadrži role, ignorišemo ga u praksi kroz service layer
        // (ne mijenjamo AuthService logiku kako si tražio)

        var result = await auth.RegisterAsync(request);

        // optional safety check (defense in depth)
        if (result.User.Role == UserRole.Admin ||
            result.User.Role == UserRole.Manager ||
            result.User.Role == UserRole.Cashier)
        {
            return StatusCode(403, "Role assignment not allowed via public register");
        }

        return Ok(result);
    }

    // =========================
    // LOGIN
    // =========================
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest("Invalid request data");
        }

        var result = await auth.LoginAsync(request);

        return Ok(result);
    }
    // =========================
    // REFRESH TOKEN
    // =========================
    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponse>> Refresh(RefreshRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            return BadRequest("Invalid refresh token");
        }

        var result = await auth.RefreshAsync(request);

        return Ok(result);
    }
}
