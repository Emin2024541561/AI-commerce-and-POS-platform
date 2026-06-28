using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Authorize]
[Route("products")]
public sealed class ProductsController(ProductService products) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<ProductDto>>> Get(
        [FromQuery] string? search = null,
        [FromQuery] int? categoryId = null)
    {
        return Ok(
            await products.GetAsync(
                search,
                categoryId
            )
        );
    }
    [HttpGet("categories")] public async Task<ActionResult<IReadOnlyList<CategoryDto>>> Categories() => Ok(await products.CategoriesAsync());
    [HttpPost, Authorize(Roles = "Admin,Manager")] public async Task<ActionResult<ProductDto>> Create(UpsertProductRequest request) => Ok(await products.UpsertAsync(null, request));
    [HttpPut("{id:int}"), Authorize(Roles = "Admin,Manager")] public async Task<ActionResult<ProductDto>> Update(int id, UpsertProductRequest request) => Ok(await products.UpsertAsync(id, request));
    [HttpDelete("{id:int}"), Authorize(Roles = "Admin")] public async Task<IActionResult> Delete(int id) { await products.DeleteAsync(id); return NoContent(); }
}
