# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:10.0-noble AS build
WORKDIR /src
COPY ["AspNetCore64897Repro.csproj", "./"]
COPY ["Directory.Build.props", "./"]
COPY ["packages.lock.json", "./"]
RUN dotnet restore "AspNetCore64897Repro.csproj" /p:ContinuousIntegrationBuild=true
COPY . .
WORKDIR "/src"
RUN dotnet build "AspNetCore64897Repro.csproj" -c Release -o /app/build /p:ContinuousIntegrationBuild=true

FROM build AS publish
RUN dotnet publish "AspNetCore64897Repro.csproj" -c Release -o /app/publish /p:ContinuousIntegrationBuild=true

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AspNetCore64897Repro.dll"]
