using Azure.Identity;
using Microsoft.Azure.Devices;
using WebApp.Services;

var builder = WebApplication.CreateBuilder(args);
var token = new DefaultAzureCredential();

if (!Uri.TryCreate( builder.Configuration.GetValue<string>("AppConfig:Endpoint"), UriKind.Absolute, out var endpoint))
{
    throw new InvalidOperationException("App configuration URI is not valid");
}


builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(endpoint, token)
           .Select("Blinkey:*");
});

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddAzureAppConfiguration();
builder.Services.AddSingleton<WeatherForecastService>();
builder.Services.AddScoped<DeviceTwinService>();
builder.Services.AddScoped<IotDevicesService>();

var IothubHostName = builder.Configuration.GetValue<string>("Blinkey:IotHubOptions:HostName");

builder.Services.AddScoped(provider =>
{
    return ServiceClient.Create(IothubHostName, token);
});

builder.Services.AddScoped(provider =>
{
    return RegistryManager.Create(IothubHostName, token);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
