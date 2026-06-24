-- Debug fallback: in Debug builds CSP loads this script locally, bypassing the
-- server-side tr() injection. In Release the injected (translated) tr() wins.
local tr = tr or function(key, args) return key end

-- Minimal in-game CSP UI demonstrating server-side localization.
-- The host injects a translation table + tr() for the active ServerLocale when
-- the plugin serves this script via CSPServerScriptProvider.AddLocalizedScript.
-- Reference strings with tr("key"); keys live in lang/SamplePlugin.<locale>.yml.
-- Pass a table as the 2nd arg to fill {placeholders}: tr("key", { name = "..." }).
ui.registerOnlineExtra(
    ui.Icons.Star,
    tr("plugin.sample.ui.title"),
    nil,
    function()
        ui.text(tr("plugin.sample.ui.greeting", { track = ac.getTrackID() }))
        ui.text(tr("plugin.sample.ui.body"))
    end,
    nil,
    ui.OnlineExtraFlags.Tool
)
