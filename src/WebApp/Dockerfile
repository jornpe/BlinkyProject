#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src/webapp
COPY . .
RUN dotnet restore "WebApp.csproj" --runtime "linux-x64"
RUN dotnet publish "WebApp.csproj" -c Release -o /app/publish --runtime "linux-x64" --self-contained true --no-restore

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "WebApp.dll"]

# ORIGINAL

#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
#WORKDIR /app
#EXPOSE 80
#EXPOSE 443
#
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#WORKDIR /src
#COPY ["src/WebApp/WebApp.csproj", "src/WebApp/"]
#RUN dotnet restore "src/WebApp/WebApp.csproj"
#COPY . .
#WORKDIR "/src/src/WebApp"
#RUN dotnet build "WebApp.csproj" -c Release -o /app/build
#
#FROM build AS publish
#RUN dotnet publish "WebApp.csproj" -c Release -o /app/publish
#
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "WebApp.dll"]