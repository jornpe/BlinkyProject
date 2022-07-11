using Microsoft.Azure.Devices;
using System.Text;
using System.Text.Json;
using WebApp.Messages;

namespace WebApp.Services
{
    public class DeviceTwinService
    {
        private static string deviceId = "jornpTestDevice";
        private readonly ServiceClient serviceClient;
        private readonly ILogger<DeviceTwinService> logger;

        public DeviceTwinService(ServiceClient serviceClient, ILogger<DeviceTwinService> logger)
        {
            this.serviceClient = serviceClient;
            this.logger = logger;
        }

        public async Task SendCouldToDeviceMessage(ColorUpdateMessage colorUpdateMessage)
        {
            var json = JsonSerializer.Serialize(colorUpdateMessage);
            var msg = new Message(Encoding.ASCII.GetBytes(json));
            msg.ContentType = "application/json";
            msg.ContentEncoding = "UTF-8";

            await serviceClient.SendAsync(deviceId, msg);
            var feedbackReciver = serviceClient.GetFeedbackReceiver();

        }
    }
}
