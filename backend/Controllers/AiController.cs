using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Controllers;

[ApiController]
[Authorize(Roles = "Admin,Manager")]
[Route("ai")]
public sealed class AiController(AiService ai) : ControllerBase
{
    [HttpGet("forecast-sales")]
    public async Task<ActionResult<SalesForecastDto>> Forecast()
        => Ok(await ai.ForecastSalesAsync());


    [HttpGet("recommend-restock")]
    public async Task<ActionResult<IReadOnlyList<RestockSuggestionDto>>> Restock()
        => Ok(await ai.RecommendRestockAsync());


    [HttpGet("popularity")]
    public async Task<ActionResult<PopularityAnalysisDto>> Popularity()
        => Ok(await ai.PopularityAsync());


    [HttpGet("profit-analysis")]
    public async Task<ActionResult<IReadOnlyList<ProfitAnalysisDto>>> Profit()
        => Ok(await ai.ProfitAnalysisAsync());


    [HttpGet("smart-deals")]
    public async Task<ActionResult<IReadOnlyList<SmartDealDto>>> SmartDeals()
        => Ok(await ai.SmartDealsAsync());


    // ==============================
    // CUSTOMER AI RECOMMENDATIONS
    // ==============================

    [AllowAnonymous]
    [HttpGet("recommendations/{userId}")]
    public async Task<ActionResult<IReadOnlyList<CustomerRecommendationDto>>> Recommendations(
        Guid userId)
        => Ok(await ai.CustomerRecommendationsAsync(userId));



    // ==============================
    // SMART AI CHAT ASSISTANT
    // ==============================

    [AllowAnonymous]
    [HttpPost("assistant")]
    public async Task<ActionResult<AiAssistantResponse>> Assistant(
        AiAssistantRequest request)
        => Ok(await ai.AssistantAsync(request));



    [HttpGet("anomalies")]
    public async Task<ActionResult<IReadOnlyList<AnomalyDto>>> Anomalies()
        => Ok(await ai.AnomaliesAsync());


    [HttpGet("summary")]
    public async Task<ActionResult<AIInsightDto>> Summary()
        => Ok(await ai.BusinessSummaryAsync());


    [HttpGet("insights")]
    public async Task<ActionResult<IReadOnlyList<AIInsightDto>>> Insights()
        => Ok(await ai.InsightsAsync());
}