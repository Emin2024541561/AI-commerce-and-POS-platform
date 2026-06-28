using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Authorize]
[Route("inventory")]
public sealed class InventoryController(InventoryService inventory) : ControllerBase
{
    [HttpGet("low-stock")] public async Task<ActionResult<IReadOnlyList<LowStockDto>>> LowStock() => Ok(await inventory.LowStockAsync());
    [HttpPost("update"), Authorize(Roles = "Admin,Manager")] public async Task<IActionResult> Update(InventoryUpdateRequest request) { await inventory.UpdateAsync(request); return NoContent(); }
}
