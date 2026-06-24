using System.Reflection;
using AssettoServer.Server;
using AssettoServer.Shared.Services;
using Microsoft.Extensions.Hosting;
using Serilog;

namespace SamplePlugin;

public class Sample : BackgroundService
{
    public Sample(SampleConfiguration configuration,
        ILocalizationService l10n,
        CSPServerScriptProvider scriptProvider)
    {
        Log.Debug("Sample plugin constructor called! Hello: {Hello}", configuration.Hello);

        // --- Localization ---
        // Register this plugin's lang/ catalog so its keys resolve through ILocalizationService.
        // Use a short, unique namespace that prefixes all of this plugin's keys.
        var pluginDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        l10n.RegisterSource(Path.Combine(pluginDir, "lang"), "sample");

        // OPTIONAL — only if your plugin has an in-game CSP UI. AddLocalizedScript injects a
        // translated tr() for the active ServerLocale before serving the script. Delete this
        // block (and lua/sample.lua, and the plugin.sample.ui.* keys) if your plugin draws no
        // player-visible Lua text.
        var luaPath = Path.Combine(pluginDir, "lua", "sample.lua");
        using var reader = new StreamReader(luaPath);
        scriptProvider.AddLocalizedScript(reader.ReadToEnd(), l10n, "sample.lua");
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Log.Debug("Sample plugin autostart called");
        return Task.CompletedTask;
    }
}
