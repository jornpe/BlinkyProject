using Microsoft.Azure.Devices;
using System.Text;
using System.Text.Json;
using WebApp.Messages;

namespace WebApp.Services
{
    public class DeviceTwinService
    {
        private readonly ServiceClient serviceClient;

        public DeviceTwinService(ServiceClient serviceClient)
        {
            this.serviceClient = serviceClient;
        }

        public async Task SendCouldToDeviceMessage(ColorUpdateMessage colorUpdateMessage, string deviceId)
        {
            var json = JsonSerializer.Serialize(colorUpdateMessage);
            var msg = new Message(Encoding.ASCII.GetBytes(json));
            msg.ContentType = "application/json";
            msg.ContentEncoding = "UTF-8";

            await serviceClient.SendAsync(deviceId, msg);
            
        }
    }
}
