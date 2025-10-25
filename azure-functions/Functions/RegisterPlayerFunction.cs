using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
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
    /// Azure Function for registering a new player
    /// API Name: registerplayer
    /// Method: POST
    /// </summary>
    public class RegisterPlayerFunction
    {
        private readonly ILogger _logger;

        public RegisterPlayerFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<RegisterPlayerFunction>();
        }

        [Function("registerplayer")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "registerplayer")] 
            HttpRequestData req)
        {
            _logger.LogInformation("RegisterPlayer function processing a request.");

            try
            {
                // Read and parse request body
                string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                var registerRequest = JsonConvert.DeserializeObject<RegisterPlayerRequest>(requestBody);

                if (registerRequest == null)
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "Invalid request body");
                }

                // Validate required fields
                if (string.IsNullOrWhiteSpace(registerRequest.PlayerName))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "PlayerName is required");
                }

                if (string.IsNullOrWhiteSpace(registerRequest.FullName))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "FullName is required");
                }

                if (string.IsNullOrWhiteSpace(registerRequest.Age))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "Age is required");
                }

                if (string.IsNullOrWhiteSpace(registerRequest.Email))
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "Email is required");
                }

                if (registerRequest.Level < 1)
                {
                    return await CreateErrorResponse(req, HttpStatusCode.BadRequest, 
                        "Level must be at least 1");
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
                    new MySqlParameter("p_PlayerName", registerRequest.PlayerName),
                    new MySqlParameter("p_FullName", registerRequest.FullName),
                    new MySqlParameter("p_Age", registerRequest.Age),
                    new MySqlParameter("p_Level", registerRequest.Level),
                    new MySqlParameter("p_Email", registerRequest.Email)
                };

                var results = dbHelper.ExecuteStoredProcedure("sp_RegisterPlayer", parameters);

                if (results.Count > 0)
                {
                    var player = DatabaseHelper.ConvertToObject<Player>(results[0]);
                    
                    var response = req.CreateResponse(HttpStatusCode.Created);
                    var apiResponse = new ApiResponse<Player>
                    {
                        Success = true,
                        Message = "Player registered successfully",
                        Data = player
                    };
                    
                    await response.WriteStringAsync(JsonConvert.SerializeObject(apiResponse));
                    response.Headers.Add("Content-Type", "application/json");
                    
                    return response;
                }
                else
                {
                    return await CreateErrorResponse(req, HttpStatusCode.InternalServerError, 
                        "Failed to register player");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in RegisterPlayer function");
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
