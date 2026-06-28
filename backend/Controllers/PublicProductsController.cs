using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Route("api/public/products")]
public sealed class PublicProductsController(PublicProductService products) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<PublicProductDto>>> Get([FromQuery] PublicProductQuery query) => Ok(await products.GetAsync(query));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProductDetailsDto>> GetById(int id) => Ok(await products.GetByIdAsync(id));

    [HttpGet("featured")]
    public async Task<ActionResult<IReadOnlyList<PublicProductDto>>> Featured() => Ok(await products.FeaturedAsync());

    [HttpGet("popular")]
    public async Task<ActionResult<IReadOnlyList<PublicProductDto>>> Popular() => Ok(await products.PopularAsync());

    [HttpGet("deals")]
    public async Task<ActionResult<IReadOnlyList<PublicProductDto>>> Deals() => Ok(await products.DealsAsync());

    [HttpGet("search")]
    public async Task<ActionResult<IReadOnlyList<PublicProductDto>>> Search([FromQuery] string q) => Ok(await products.SearchAsync(q));
}
