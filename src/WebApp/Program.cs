using Azure.Identity;
using Microsoft.Azure.Devices;
using WebApp.Services;

var builder = WebApplication.CreateBuilder(args);

ConfigureIothubConnection(builder);

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<WeatherForecastService>();
builder.Services.AddScoped<DeviceTwinService>();
builder.Services.AddScoped<IotDevicesService>();


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



static void ConfigureIothubConnection(WebApplicationBuilder builder)
{
    var IothubHostName = builder.Configuration.GetValue<string>("IotHubOptions:HostName");
    builder.Services.AddScoped(provider =>
    {
        var token = new DefaultAzureCredential();
        return ServiceClient.Create(IothubHostName, token);
    });

    builder.Services.AddScoped(provider =>
    {
        var token = new DefaultAzureCredential();
        return RegistryManager.Create(IothubHostName, token);
    });
}