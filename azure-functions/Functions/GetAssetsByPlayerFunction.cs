using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using BattleGameFunctions.Models;
using BattleGameFunctions.Helpers;

namespace BattleGameFunctions.Functions
{
    /// <summary>
    /// Azure Function for getting player assets report
    /// API Name: getassetsbyplayer
    /// Method: GET
    /// </summary>
    public class GetAssetsByPlayerFunction
    {
        private readonly ILogger _logger;

        public GetAssetsByPlayerFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<GetAssetsByPlayerFunction>();
        }

        [Function("getassetsbyplayer")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "getassetsbyplayer")] 
            HttpRequestData req)
        {
            _logger.LogInformation("GetAssetsByPlayer function processing a request.");

            try
            {
                // Get connection string from environment
                var connectionString = Environment.GetEnvironmentVariable("SqlConnectionString");
                if (string.IsNullOrEmpty(connectionString))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                        "Database connection string not configured");
                }

                // Execute stored procedure
                var dbHelper = new DatabaseHelper(connectionString, _logger);
                var results = dbHelper.ExecuteStoredProcedure("sp_GetAssetsByPlayer");

                var reportList = results.Select(r => new PlayerAssetReport
                {
                    No = Convert.ToInt32(r["No"]),
                    PlayerName = r["Player name"]?.ToString() ?? string.Empty,
                    Level = Convert.ToInt32(r["Level"]),
                    Age = r["Age"]?.ToString() ?? string.Empty,
                    AssetName = r["Asset name"]?.ToString() ?? string.Empty
                }).ToList();

                var response = req.CreateResponse(HttpStatusCode.OK);
                var apiResponse = new ApiResponse<List<PlayerAssetReport>>
                {
                    Success = true,
                    Message = "Report retrieved successfully",
                    Data = reportList,
                    Count = reportList.Count
                };
                
                await response.WriteStringAsync(JsonConvert.SerializeObject(apiResponse));
                response.Headers.Add("Content-Type", "application/json");
                response.Headers.Add("Access-Control-Allow-Origin", "*");
                response.Headers.Add("Access-Control-Allow-Methods", "GET, OPTIONS");
                response.Headers.Add("Access-Control-Allow-Headers", "Content-Type");
                
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAssetsByPlayer function");
                return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                    $"Internal server error: {ex.Message}");
            }
        }

        private async Task<HttpResponseData> CreateErrorResponse(
            HttpRequestData req, 
            HttpStatusCode statusCode, 
            string message)
        {
            var response = req.CreateResponse(statusCode);
            var apiResponse = new ApiResponse<object>
            {
                Success = false,
                Message = message,
                Data = null
            };
            
            await response.WriteStringAsync(JsonConvert.SerializeObject(apiResponse));
            response.Headers.Add("Content-Type", "application/json");
            response.Headers.Add("Access-Control-Allow-Origin", "*");
            
            return response;
        }
    }
}

