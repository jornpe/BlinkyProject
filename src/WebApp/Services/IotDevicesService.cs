using Microsoft.Azure.Devices;

namespace WebApp.Services
{
    public class IotDevicesService
    {
        private readonly RegistryManager registryManager;
        private readonly ILogger<IotDevicesService> logger;

        public IotDevicesService(RegistryManager registryManager, ILogger<IotDevicesService> logger)
        {
            this.registryManager = registryManager;
            this.logger = logger;
        }

        public async Task<List<string>> GetDevicesIdsAsync()
        {
            var ids = new List<string>();
            var query = registryManager.CreateQuery("SELECT * from devices");

            while (query.HasMoreResults)
            {
                foreach (var twin in await query.GetNextAsTwinAsync())
                {
                    ids.Add(twin.DeviceId);
                    logger.LogInformation("Found device twin with ID: {twin.DeviceId}", twin.DeviceId);
                }
            }

            return ids;
        }
    }
}
