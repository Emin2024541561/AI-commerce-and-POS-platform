using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Authorize(Roles = "Customer")]
[Route("api/cart")]
public sealed class CartController(CartService cart) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<CartDto>> Get() => Ok(await cart.GetAsync(UserId()));

    [HttpPost("add")]
    public async Task<ActionResult<CartDto>> Add(CartMutationRequest request) => Ok(await cart.AddAsync(UserId(), request));

    [HttpPut("update")]
    public async Task<ActionResult<CartDto>> Update(CartMutationRequest request) => Ok(await cart.UpdateAsync(UserId(), request));

    [HttpPost("remove")]
    public async Task<ActionResult<CartDto>> Remove(CartMutationRequest request) => Ok(await cart.RemoveAsync(UserId(), request));

    private Guid UserId() => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
