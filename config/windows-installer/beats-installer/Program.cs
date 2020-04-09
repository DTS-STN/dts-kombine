using System;
using System.IO;
using System.IO.Compression;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace beats_intsaller
{
    class Program
    {
        static async Task Main()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

            IConfigurationRoot configuration = builder.Build();

            var certPath = configuration.GetSection("install-settings:cert-path");
            
            if (!File.Exists("appsettings.json")){
                Console.WriteLine("Missing required appsettings.json file. Exiting...");
                return;
            }
            if (!Directory.Exists("./agents")){
                Console.WriteLine("Missing agent configuration folder. Exiting...");
                return;
            }
            if (!Directory.Exists(certPath.Value)){
                Console.WriteLine("Certificates missing. Exiting...");
                return;
            }

            // publish command:
            // dotnet publish -c Release --self-contained -r win10-x64 /p:PublishSingleFile=true
            
            // below should result in a smaller package size, but perhaps at a cost
            // dotnet publish -c Release --self-contained -r win10-x64 /p:PublishSingleFile=true /p:PublishedTrimmed=true
            var elkVersion = configuration.GetSection("elk:version");

            string metricbeatUrl = $"https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-{elkVersion.Value}-windows-x86_64.zip";
            string winlogbeatUrl = $"https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-{elkVersion.Value}-windows-x86_64.zip";
            string packetbeatbeatUrl = $"https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-{elkVersion.Value}-windows-x86_64.zip";

            var installPath = configuration.GetSection("install-settings:install-path");
            var downloadPath = configuration.GetSection("install-settings:download-path");

            string metricbeatDlPath = $"{downloadPath.Value}/metricbeat-{elkVersion.Value}.zip";
            string metricbeatInstallPath = $"{installPath.Value}/metricbeat";

            string winlogbeatDlPath = $"{downloadPath.Value}/winlogbeat-{elkVersion.Value}.zip";
            string winlogbeatInstallPath = $"{installPath.Value}/winlogbeat";

            string packetbeatDlPath = $"{downloadPath.Value}/packetbeat-{elkVersion.Value}.zip";
            string packetbeatInstallPath = $"{installPath.Value}/packetbeat";

            /************** Downloading the beats ***********************/
            Console.WriteLine("Getting beats...");

            if (!Directory.Exists(downloadPath.Value)){
                Directory.CreateDirectory(downloadPath.Value);
            }

            var metricbeatDownload = HttpClientDownload(metricbeatUrl);
            await File.WriteAllBytesAsync(metricbeatDlPath, metricbeatDownload.Result);
            
            var winlogbeatDownload = HttpClientDownload(winlogbeatUrl);
            await File.WriteAllBytesAsync(winlogbeatDlPath, winlogbeatDownload.Result);

            var packetbeatDownload = HttpClientDownload(packetbeatbeatUrl);
            await File.WriteAllBytesAsync(packetbeatDlPath, packetbeatDownload.Result);

            Console.WriteLine("Done");
            /************************************************************/

            /************** Installing the beats ***********************/
            Console.WriteLine("Installing beats...");

            if (!Directory.Exists(installPath.Value)){
                Directory.CreateDirectory(installPath.Value);
            }

            ZipFile.ExtractToDirectory(metricbeatDlPath, downloadPath.Value);
            Directory.Move(downloadPath.Value + $"/metricbeat-{elkVersion.Value}-windows-x86_64", metricbeatInstallPath);
            

            ZipFile.ExtractToDirectory(winlogbeatDlPath, downloadPath.Value);
            Directory.Move(downloadPath.Value + $"/winlogbeat-{elkVersion.Value}-windows-x86_64", winlogbeatInstallPath);

            ZipFile.ExtractToDirectory(packetbeatDlPath, downloadPath.Value);
            Directory.Move(downloadPath.Value + $"/packetbeat-{elkVersion.Value}-windows-x86_64", packetbeatInstallPath);

            Console.WriteLine("Done");
            /***********************************************************/

            /************** Configuring the beats **********************/
            Console.WriteLine("Configuring agents...");

            var logstashToken = configuration.GetSection("elk:logstash-url-token");
            var logstashUrl = configuration.GetSection("elk:logstash-url");
            var certPathToken = configuration.GetSection("install-settings:cert-path-token");

            File.Copy("./agents/jolokia.yml", $"{metricbeatInstallPath}/modules.d/jolokia.yml", true);
            File.Copy("./agents/system.yml", $"{metricbeatInstallPath}/modules.d/system.yml", true);
            File.Copy("./agents/windows.yml", $"{metricbeatInstallPath}/modules.d/windows.yml", true);
            File.Copy(ReplaceTokens("./agents/metricbeat.yml", logstashToken.Value, logstashUrl.Value, certPathToken.Value, certPath.Value), $"{metricbeatInstallPath}/metricbeat.yml", true);
            File.Copy(ReplaceTokens("./agents/packetbeat.yml", logstashToken.Value, logstashUrl.Value, certPathToken.Value, certPath.Value), $"{packetbeatInstallPath}/packetbeat.yml", true);
            File.Copy(ReplaceTokens("./agents/winlogbeat.yml", logstashToken.Value, logstashUrl.Value, certPathToken.Value, certPath.Value), $"{winlogbeatInstallPath}/winlogbeat.yml", true);

            Console.WriteLine("Done");
            /***********************************************************/

            /************** Installing NpCap ***************************/
            Console.WriteLine("Getting NpCap for packetbeat...");
            var npcapdl = HttpClientDownload("https://nmap.org/dist/nmap-7.80-setup.exe");
            await File.WriteAllBytesAsync($"nmap-7.80-setup.exe", npcapdl.Result);
            Console.WriteLine("Done");

            Console.WriteLine("Installing NpCap...");
            Console.WriteLine("Install NpCap before continuing. Ensure that it is installed in WinPcap API-compatible mode.");
            System.Diagnostics.Process.Start("cmd.exe", $"/C nmap-7.80-setup.exe /winpcap_mode");
            Console.Write("Press any key to continue...");
            Console.ReadLine();
            /***********************************************************/

            /************** Running the service registration scripts **********************/
            Console.WriteLine("Registering services...");

            var metricbeatCommand = $"/C Powershell.exe -executionpolicy remotesigned -File \"{metricbeatInstallPath}/install-service-metricbeat.ps1\"";
            System.Diagnostics.Process.Start("cmd.exe", metricbeatCommand);

            var winlogbeatCommand = $"/C Powershell.exe -executionpolicy remotesigned -File \"{winlogbeatInstallPath}/install-service-winlogbeat.ps1\"";
            System.Diagnostics.Process.Start("cmd.exe", winlogbeatCommand);

            var packetbeatCommand = $"/C Powershell.exe -executionpolicy remotesigned -File \"{packetbeatInstallPath}/install-service-packetbeat.ps1\"";
            System.Diagnostics.Process.Start("cmd.exe", packetbeatCommand);

            Console.WriteLine("Done");
            /*****************************************************************************/

            /************** Starting the services **********************/
            Console.WriteLine("Starting the services...");

            System.Threading.Thread.Sleep(1000); // wait a second before starting the services
            System.Diagnostics.Process.Start("cmd.exe", "/C Powershell.exe -executionpolicy remotesigned Start-Service metricbeat");
            System.Threading.Thread.Sleep(500);
            System.Diagnostics.Process.Start("cmd.exe", "/C Powershell.exe -executionpolicy remotesigned Start-Service winlogbeat");
            System.Threading.Thread.Sleep(500);
            System.Diagnostics.Process.Start("cmd.exe", "/C Powershell.exe -executionpolicy remotesigned Start-Service packetbeat");
            Console.WriteLine("Done");
            /***********************************************************/

            /************** Removing the downloaded files **********************/
            Console.WriteLine("Cleaning up...");

            File.Delete(metricbeatDlPath);
            File.Delete(winlogbeatDlPath);
            File.Delete(packetbeatDlPath);

            Console.WriteLine("Done");
            /*******************************************************************/
        }

        private static string ReplaceTokens(string filePath, string urlToken, string ip, string certToken, string certPath)
        {
            string text = File.ReadAllText(filePath);
            if (text.Contains(urlToken)){
                text = text.Replace(urlToken, ip);
            }
            if (text.Contains(certToken)){
                text = text.Replace(certToken, certPath);
            }
            File.WriteAllText(filePath, text);
            return filePath;
        }

        private static async Task<byte[]> HttpClientDownload(string url)
        {
            using (var client = new HttpClient())
            {
                try
                {
                    HttpResponseMessage response = await client.GetAsync(url);
                    response.EnsureSuccessStatusCode();
                    var result = await response.Content.ReadAsByteArrayAsync();
                    return result;
                }
                catch (HttpRequestException e)
                {
                    Console.WriteLine("\nException caught!");
                    Console.WriteLine("Message: {0}", e.Message);
                }
            }
            return new byte[0];
        }
    }
}