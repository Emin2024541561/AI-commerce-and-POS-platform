using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Authorize(Roles = "Admin,Manager")]
[Route("dashboard")]
public sealed class DashboardController(DashboardService dashboard) : ControllerBase
{
    [HttpGet("stats")] public async Task<ActionResult<DashboardStatsDto>> Stats() => Ok(await dashboard.StatsAsync());
}
