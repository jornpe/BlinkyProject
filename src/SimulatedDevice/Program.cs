﻿
using System.Text;
using System.Text.Json;
using Microsoft.Azure.Devices.Client;
using Microsoft.Extensions.Configuration;

var config = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddUserSecrets<Program>()
    .Build();


var deviceConnectionString = config.GetConnectionString("IotDevice");
var device = DeviceClient.CreateFromConnectionString(deviceConnectionString);

var deviceName = deviceConnectionString
                        .Split(';')
                        .First(s => s.StartsWith("DeviceId"))
                        .Split('=')
                        .Last();

Console.WriteLine("Connected using device ID: " + deviceName);

var rec = ReceiveMessagesAsync(device);
var snd = SendTelemetryDataAsync(device);

await Task.WhenAll(rec, snd);

static async Task ReceiveMessagesAsync(DeviceClient? device)
{
    if (device == null) return;

    Console.WriteLine("Starting to listen to incoming messages");

    while (true)
    {
        var receivedMessage = await device.ReceiveAsync();
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
    return JsonSerializer.Serialize(data);
}

