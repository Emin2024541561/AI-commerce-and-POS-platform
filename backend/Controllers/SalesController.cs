using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Authorize]
[Route("sales")]
public sealed class SalesController(SaleService sales) : ControllerBase
{
    [HttpPost("create")] public async Task<ActionResult<SaleDto>> Create(CreateSaleRequest request) => Ok(await sales.CreateAsync(request));
    [HttpGet, Authorize(Roles = "Admin,Manager")] public async Task<ActionResult<IReadOnlyList<SaleDto>>> Get([FromQuery] DateTimeOffset? from, [FromQuery] DateTimeOffset? to) => Ok(await sales.GetAsync(from, to));
    [HttpGet("{id:guid}")] public async Task<ActionResult<SaleDto>> Get(Guid id) => Ok(await sales.GetAsync(id));
}
