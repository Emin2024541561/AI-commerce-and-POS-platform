using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartAiPos.Api.Repositories;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Route("api/categories")]
public sealed class CategoriesController(IAppRepository repo) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var categories = await repo.Categories
            .OrderBy(x => x.Name)
            .Select(x => new
            {
                x.Id,
                x.Name
            })
            .ToListAsync();

        return Ok(categories);
    }
}