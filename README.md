# AssettoServer Plugin Template

A ready-to-build starter template for writing your own [AssettoServer](https://github.com/compujuckel/AssettoServer) plugin, with localization baked in.

It is the upstream `SamplePlugin` (baseline `v0.0.55-pre35`), extracted into a standalone repository so you can click **Use this template** on GitHub and start from a clean slate. Out of the box it demonstrates the things almost every plugin needs:

- an **Autofac module** that registers your services — `SampleModule.cs`
- a **YAML config section** with **FluentValidation** — `SampleConfiguration.cs`, `SampleConfigurationValidator.cs`
- a long-lived **background service** that starts with the server — `Sample.cs`
- an **HTTP route** — `SampleController.cs`
- a **chat command** — `SampleCommandModule.cs`
- **server-side localization** (`ILocalizationService`, `lang/*.yml`) feeding both C# strings and a CSP Lua UI — `lang/`, `lua/sample.lua`

## Branches — pick the host you target

| Branch | Host target | Notes |
| --- | --- | --- |
| **`0.0.55custom`** (default) | [`Ereebay/AssettoServer`](https://github.com/Ereebay/AssettoServer) `0.0.55-main` (`net9.0`) | The promoted line: adds the localization template (`ILocalizationService`, `lang/`, localized Lua injection). |
| `main` | upstream `compujuckel/AssettoServer` master (baseline `v0.0.55-pre35`, `net9.0`) | Faithful mirror of the upstream in-tree `SamplePlugin`. |
| `0.0.54` | upstream `0.0.54` (`net8.0`) | Older plugin lifecycle API (`CriticalBackgroundService` / `IAssettoServerAutostart`). |

A new custom line (e.g. `0.0.56custom`) is cut when the Ereebay fork moves to a new host version; the default branch follows the newest custom line.

## How it works

AssettoServer loads plugins from `<server>/plugins/<PluginName>/<PluginName>.dll`. A plugin is just a .NET 9 class library that references the AssettoServer host assemblies **at compile time only** (`<Private>false</Private>` + `<ExcludeAssets>runtime</ExcludeAssets>`) — the running server provides them, so they are never bundled with your DLL.

Because this template references the host via relative paths (`..\AssettoServer\…`), **it must live inside an AssettoServer checkout**, right next to the `AssettoServer/` and `AssettoServer.Shared/` folders. The repo/folder name does **not** matter to the build — only its position does.

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- A clone of the host you build against (see the branch table)

## Getting started

1. **Create your repo** from this template — the green **Use this template** button on GitHub (check out the default `0.0.55custom` branch).

2. **Rename the template to your plugin** — run the scaffolder from the repo root (PowerShell 5.1+):
   ```powershell
   .\scaffold.ps1 -Name MyThing        # -> MyThingPlugin
   ```
   It renames the csproj/classes/lang files and rewrites namespaces, lang keys, routes and docs, then deletes itself. (Manual checklist below if you prefer.)

3. **Clone the host** (the `0.0.55custom` branch targets the Ereebay fork):
   ```bash
   git clone --branch 0.0.55-main https://github.com/Ereebay/AssettoServer.git
   ```

4. **Clone your plugin repo _into_ the host folder** so it sits next to the host projects:
   ```bash
   cd AssettoServer
   git clone https://github.com/<you>/<your-plugin-repo>.git
   ```

5. **Build:**
   ```bash
   cd <your-plugin-repo>
   dotnet build -c Release
   ```
   The plugin DLL lands in `bin/Release/net9.0/<YourPlugin>.dll`.

> Tip: to get IDE IntelliSense across the host, add the project to the server solution:
> `dotnet sln ../AssettoServer.sln add <YourPlugin>.csproj`
>
> In **Debug** the build also drops the DLL into `..\AssettoServer\bin\Debug\net9.0\plugins\<YourPlugin>\`, so running the server from your IDE picks it up automatically.

## Running your plugin on a server

Publish straight into the host's output tree (writes to `out-<rid>/plugins/`):

```bash
dotnet publish -c Release -r win-x64     # or linux-x64 / linux-arm64
```

…or copy the build output into your server install manually, then enable it in `extra_cfg.yml`:

```yaml
EnablePlugins:
- SamplePlugin
---
!SampleConfiguration
Hello: World!
```

The `!` tag is matched against your config **class name**; controllers and chat commands are discovered by scanning the plugin assembly.

## Anatomy

| File | Role |
| --- | --- |
| `SampleModule.cs` | Autofac module (`AssettoServerModule<SampleConfiguration>`). Registers your services; the generic base opts the plugin into a YAML config section. |
| `SampleConfiguration.cs` | The plugin's `extra_cfg.yml` section (the `!SampleConfiguration` document). |
| `SampleConfigurationValidator.cs` | FluentValidation rules for the config — errors surface at startup, pointing at the offending key. |
| `Sample.cs` | A `BackgroundService` registered as an `IHostedService` — runs for the lifetime of the server. |
| `SampleController.cs` | ASP.NET Core controller — HTTP routes are auto-discovered from the plugin assembly. |
| `SampleCommandModule.cs` | Qmmands chat command module — commands are auto-discovered from the plugin assembly. |
| `lang/SamplePlugin.*.yml` | Localization catalogs; keys live under `plugin.sample.*` and are consumed by C# (`ILocalizationService`) and the Lua UI alike. |
| `lua/sample.lua` | CSP client script; strings are localized server-side and injected at registration time. |

## Renaming it manually (if you skip the scaffolder)

`scaffold.ps1` automates all of this; the full list of places the name appears:

1. `SamplePlugin.csproj` → `<YourPlugin>.csproj` (also update its `<Description>`).
2. Namespace `SamplePlugin` → `<YourPlugin>` in every `.cs` file.
3. The `Sample*` classes: `SampleModule`, `SampleConfiguration`, `SampleConfigurationValidator`, `SampleController`, `SampleCommandModule`, `Sample`.
4. The config tag (`!SampleConfiguration`) and the `EnablePlugins` entry.
5. `lang/SamplePlugin.*.yml` filenames **and** the `plugin.sample.*` key prefix — in the yml files, in the C# references, and in `lua/sample.lua` (three places reference the same keys).
6. Route/command strings (`/sampleplugin`) if you care.
7. `README.md` and the workflow artifact name.

## Naming conventions

Two layers, deliberately different — never let one leak into the other:

| Layer | Convention | Example | Consumed by |
| --- | --- | --- | --- |
| **Repo / distribution** | kebab-case, ecosystem prefix | `assettoserver-plugin-mything` | GitHub search, catalogs, humans |
| **Plugin identity** | PascalCase, no prefix | `MyThingPlugin` | csproj/assembly name, `plugins/` dir, `EnablePlugins` |

`EnablePlugins` matches the **assembly name**, not the repo name — you can rename the repo at any time without touching installed servers. Keep the plugin identity stable forever; feel free to rebrand the repo.

## Versioning

Versions are tag-driven via [MinVer](https://github.com/adamralph/minver) (same scheme as the host): tag `v1.2.3` → version `1.2.3`. CI clones with full history so tags resolve.

## Building against a different server version

Check out a different branch of this template (see the table above) and the matching tag/branch in the host clone. Note `0.0.54` targets `net8.0` and the older `CriticalBackgroundService` / `IAssettoServerAutostart` lifecycle.

## Continuous integration

`.github/workflows/build.yml` checks out `Ereebay/AssettoServer@0.0.55-main`, drops this repo inside it, and builds — so the template is verified end to end on every push. Change the `ref:` to target a different host.

## License

Licensed under the **GNU AGPL-3.0** — the same license as [AssettoServer](https://github.com/compujuckel/AssettoServer), which this plugin links against. See [LICENSE](LICENSE).
