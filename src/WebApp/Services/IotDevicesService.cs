using Microsoft.Azure.Devices;

namespace WebApp.Services
{
    public class IotDevicesService
    {
        private readonly RegistryManager registryManager;
        private readonly ILogger<IotDevicesService> logger;
        private readonly IConfiguration configuration;

        public IotDevicesService(RegistryManager registryManager, ILogger<IotDevicesService> logger, IConfiguration configuration)
        {
            this.registryManager = registryManager;
            this.logger = logger;
            this.configuration = configuration;
        }

        public async Task<List<string>> GetDevicesIdsAsync()
        {
            logger.LogInformation("Connected to: {0} ", configuration["AppConfig:Endpoint"]);

            var ids = new List<string>();
            var query = registryManager.CreateQuery("SELECT * from devices");

            while (query.HasMoreResults)
            {
                foreach (var twin in await query.GetNextAsTwinAsync())
                {
                    logger.LogInformation("Found device twin with ID: {twin.DeviceId}", twin.DeviceId);
                    ids.Add(twin.DeviceId);
                }
            }

            return ids;
        }
    }
}
