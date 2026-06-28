using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;


[ApiController]
[Authorize]
[Route("api/orders")]
public sealed class OrdersController(OrderService orders)
    : ControllerBase
{


    // ======================================
    // CUSTOMER - CREATE ORDER
    // ======================================


    [Authorize(Roles = "Customer")]
    [HttpPost("create")]
    public async Task<ActionResult<OrderDto>> Create(
        CreateOrderRequest request)
    {
        return Ok(
            await orders.CreateAsync(
                UserId(),
                request
            )
        );
    }





    // ======================================
    // CUSTOMER - MY ORDERS
    // ======================================


    [Authorize(Roles = "Customer")]
    [HttpGet("my-orders")]
    public async Task<ActionResult<IReadOnlyList<OrderDto>>> MyOrders()
    {
        return Ok(
            await orders.MyOrdersAsync(
                UserId()
            )
        );
    }






    // ======================================
    // CUSTOMER - ORDER DETAILS
    // ======================================


    [Authorize(Roles = "Customer")]
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<OrderDto>> Get(
        Guid id)
    {
        return Ok(
            await orders.GetAsync(
                UserId(),
                id
            )
        );
    }






    // ======================================
    // CUSTOMER - STATUS
    // ======================================


    [Authorize(Roles = "Customer")]
    [HttpGet("status/{id:guid}")]
    public async Task<ActionResult<OrderStatusDto>> Status(
        Guid id)
    {
        return Ok(
            await orders.StatusAsync(
                UserId(),
                id
            )
        );
    }









    // ======================================
    // ADMIN POS - PENDING ORDERS
    // ======================================


    [Authorize(Roles = "Admin,Manager")]
    [HttpGet("pending")]
    public async Task<ActionResult<IReadOnlyList<OrderDto>>> Pending()
    {
        return Ok(
            await orders.PendingAsync()
        );
    }







    // ======================================
    // ADMIN POS - APPROVE ORDER
    // ======================================


    [Authorize(Roles = "Admin,Manager")]
    [HttpPut("approve/{id:guid}")]
    public async Task<IActionResult> Approve(
        Guid id)
    {

        await orders.ApproveAsync(id);


        return Ok(
            new
            {
                message =
                "Narudžba je uspješno odobrena."
            }
        );

    }








    // ======================================
    // ADMIN POS - REJECT ORDER
    // ======================================


    [Authorize(Roles = "Admin,Manager")]
    [HttpPut("reject/{id:guid}")]
    public async Task<IActionResult> Reject(
        Guid id)
    {

        await orders.RejectAsync(id);


        return Ok(
            new
            {
                message =
                "Narudžba je odbijena."
            }
        );

    }









    // ======================================
    // CURRENT USER ID FROM TOKEN
    // ======================================


    private Guid UserId()
    {
        return Guid.Parse(
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            )!
        );
    }


}