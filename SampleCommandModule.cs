using AssettoServer.Commands;
using AssettoServer.Shared.Services;
using Qmmands;

namespace SamplePlugin;

public class SampleCommandModule : ACModuleBase
{
    private readonly ILocalizationService _l10n;

    // Command modules get ILocalizationService injected via the constructor.
    public SampleCommandModule(ILocalizationService l10n)
    {
        _l10n = l10n;
    }

    [Command("sampleplugin")]
    public void SamplePlugin()
    {
        Reply(_l10n.Get("plugin.sample.cmd.hello"));
    }
}
