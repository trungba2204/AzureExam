using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using BattleGameFunctions.Models;
using BattleGameFunctions.Helpers;

namespace BattleGameFunctions.Functions
{
    /// <summary>
    /// Azure Function for creating a new asset
    /// API Name: createasset
    /// Method: POST
    /// </summary>
    public class CreateAssetFunction
    {
        private readonly ILogger _logger;

        public CreateAssetFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<CreateAssetFunction>();
        }

        [Function("createasset")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "createasset")] 
            HttpRequestData req)
        {
            _logger.LogInformation("CreateAsset function processing a request.");

            try
            {
                // Read and parse request body
                string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                var createRequest = JsonConvert.DeserializeObject<CreateAssetRequest>(requestBody);

                if (createRequest == null)
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "Invalid request body");
                }

                // Validate required fields
                if (string.IsNullOrWhiteSpace(createRequest.AssetName))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "AssetName is required");
                }

                if (createRequest.LevelRequire < 0)
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "LevelRequire must be at least 0");
                }

                // Get connection string from environment
                var connectionString = Environment.GetEnvironmentVariable("MySqlConnectionString");
                if (string.IsNullOrEmpty(connectionString))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                        "Database connection string not configured");
                }

                // Execute stored procedure
                var dbHelper = new DatabaseHelper(connectionString, _logger);
                var parameters = new[]
                {
                    new MySqlParameter("p_AssetName", createRequest.AssetName),
                    new MySqlParameter("p_LevelRequire", createRequest.LevelRequire)
                };

                var results = dbHelper.ExecuteStoredProcedure("sp_CreateAsset", parameters);

                if (results.Count > 0)
                {
                    var asset = DatabaseHelper.ConvertToObject<Asset>(results[0]);
                    
                    var response = req.CreateResponse(HttpStatusCode.Created);
                    var apiResponse = new ApiResponse<Asset>
                    {
                        Success = true,
                        Message = "Asset created successfully",
                        Data = asset
                    };
                    
                    await response.WriteStringAsync(JsonConvert.SerializeObject(apiResponse));
                    response.Headers.Add("Content-Type", "application/json");
                    
                    return response;
                }
                else
                {
                    return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                        "Failed to create asset");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CreateAsset function");
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
            
            return response;
        }
    }
}
