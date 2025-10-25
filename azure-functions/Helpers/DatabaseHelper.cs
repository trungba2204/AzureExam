using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace BattleGameFunctions.Helpers
{
    /// <summary>
    /// Database helper class for SQL Server operations
    /// </summary>
    public class DatabaseHelper
    {
        private readonly string _connectionString;
        private readonly ILogger _logger;

        public DatabaseHelper(string connectionString, ILogger logger)
        {
            _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>
        /// Execute a stored procedure and return results as a list of dictionaries
        /// </summary>
        public List<Dictionary<string, object>> ExecuteStoredProcedure(
            string procedureName, 
            params SqlParameter[] parameters)
        {
            var results = new List<Dictionary<string, object>>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand(procedureName, connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                connection.Open();
                using var reader = command.ExecuteReader();

                while (reader.Read())
                {
                    var row = new Dictionary<string, object>();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                    }
                    results.Add(row);
                }

                return results;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error executing stored procedure: {procedureName}");
                throw;
            }
        }

        /// <summary>
        /// Execute a non-query stored procedure
        /// </summary>
        public int ExecuteNonQuery(string procedureName, params SqlParameter[] parameters)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand(procedureName, connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                if (parameters != null && parameters.Length > 0)
                {
                    command.Parameters.AddRange(parameters);
                }

                connection.Open();
                return command.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error executing non-query: {procedureName}");
                throw;
            }
        }

        /// <summary>
        /// Convert dictionary to specific type T
        /// </summary>
        public static T ConvertToObject<T>(Dictionary<string, object> dict) where T : new()
        {
            var obj = new T();
            var type = typeof(T);

            foreach (var kvp in dict)
            {
                var property = type.GetProperty(kvp.Key);
                if (property != null && kvp.Value != null)
                {
                    property.SetValue(obj, Convert.ChangeType(kvp.Value, property.PropertyType));
                }
            }

            return obj;
        }
    }
}

