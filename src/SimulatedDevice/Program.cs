
using System.Text;
using Microsoft.Azure.Devices.Client;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

var config = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddUserSecrets<Program>()
    .Build();


string deviceConnectionString = config.GetConnectionString("DevicePrimary");
var device = DeviceClient.CreateFromConnectionString(deviceConnectionString);

var rec = ReceiveMessagesAsync(device);
var snd = SendTelemetryDataAsync(device);

await Task.WhenAll(rec, snd);

static async Task ReceiveMessagesAsync(DeviceClient? device)
{
    if (device == null) return;

    Console.WriteLine("Starting to listen to incomming messages");

    while (true)
    {
        Message receivedMessage = await device.ReceiveAsync();
        if (receivedMessage == null) continue;

        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine($"Received message: { Encoding.ASCII.GetString(receivedMessage.GetBytes()) }");
        Console.ResetColor();

        await device.CompleteAsync(receivedMessage);
    }
}


static async Task SendTelemetryDataAsync(DeviceClient? device)
{
    if(device == null) return;


    Console.WriteLine("Starting sending telemetry messages");

    while (true)
    {
        var rand = new Random();
        var json = CreateMessage(rand);
        var msg = new Message(Encoding.ASCII.GetBytes(json));
        msg.ContentType = "application/json";
        msg.ContentEncoding = "UTF-8";
        await device.SendEventAsync(msg);
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"Sending telemetry data at {DateTime.Now} with message : {json}");
        Console.ResetColor();
        await Task.Delay(2000);
    }

}

static string CreateMessage(Random rand)
{
    var data = new
    {
        temp = rand.Next(-20, 20),
        humidity = rand.Next(0, 100)
    };
    return JsonConvert.SerializeObject(data);
}

