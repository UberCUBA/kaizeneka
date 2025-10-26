# Use the official .NET 9 SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY ["KaizenekaApi.csproj", "./"]
RUN dotnet restore "KaizenekaApi.csproj"

# Copy the rest of the source code
COPY . .

# Build the application
RUN dotnet build "KaizenekaApi.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "KaizenekaApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Use the official .NET 9 runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Copy the published app
COPY --from=publish /app/publish .

# Expose the port the app runs on (Render.com will assign a dynamic port)
EXPOSE 10000

# Set the entry point
ENTRYPOINT ["dotnet", "KaizenekaApi.dll"]