using Microsoft.Azure.Devices.Shared;
using WebApp.Messages;

namespace WebApp.Infrastructure
{
    public class DeviceTwin
    {
        public ColorDto Color { get; set; }

        public TempSensorDto? SensorData { get; set; }

        public string ColorPickerColorBinding { get; set; }

        public Twin Twin { get; set; }

        public DeviceTwin(Twin twin)
        {
            Twin = twin;
            SensorData = new TempSensorDto();
            Color = new ColorDto
            {
                Red = 255,
                Green = 0,
                Blue = 0
            };

            ColorPickerColorBinding = $"rgb({Color})";
        }
        
    }
}
