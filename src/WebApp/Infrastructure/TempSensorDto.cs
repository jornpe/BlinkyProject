
using System.Buffers;
using System.Buffers.Text;
using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace WebApp.Infrastructure
{
    public class TempSensorDto
    {
        [JsonPropertyName("device_id")] 
        public string? DeviceId { get; set; } 

        [JsonPropertyName("time")] 
        [JsonConverter(typeof(EpochToDateTimeConverter))] 
        public DateTime UtcTime { get; set; }

        [JsonPropertyName("temp")] 
        public double Temperature { get; set; } 

        [JsonPropertyName("humidity")] 
        public double Humidity { get; set; } 

    }

    public class EpochToDateTimeConverter : JsonConverter<DateTime>
    {
        public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            var ticks = DateTime.UnixEpoch.AddSeconds(reader.GetInt64()).Ticks;
            return new DateTime(ticks, DateTimeKind.Utc);
        }

        public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
        {
            // The "R" standard format will always be 29 bytes.
            Span<byte> utf8Date = new byte[29];
            TimeSpan timeSpan = value - new DateTime(1970, 1, 1);

            bool result = Utf8Formatter.TryFormat(timeSpan.TotalSeconds, utf8Date, out _, new StandardFormat('R'));
            Debug.Assert(result);

            writer.WriteStringValue(utf8Date);
        }
    }
}
