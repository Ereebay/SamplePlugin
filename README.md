# AssettoServer Plugin Template (0.0.54)

A ready-to-build starter template for writing your own [AssettoServer](https://github.com/compujuckel/AssettoServer) plugin for server version **0.0.54**.

It is the upstream `SamplePlugin` (baseline `v0.0.54`), extracted into a standalone repository so you can click **Use this template** on GitHub and start from a clean slate. Out of the box it demonstrates the things almost every plugin needs:

- an **Autofac module** that registers your services — `SampleModule.cs`
- a **YAML config section** with **FluentValidation** — `SampleConfiguration.cs`, `SampleConfigurationValidator.cs`
- an **autostart service** that starts with the server — `Sample.cs` (`CriticalBackgroundService` / `IAssettoServerAutostart`, the 0.0.54 lifecycle)
- an **HTTP route** — `SampleController.cs`
- a **chat command** — `SampleCommandModule.cs`

> Building for **0.0.55** or the **Ereebay fork**? See the branch table below — `main` targets upstream 0.0.55 (`net9.0`), `0.0.55custom` (the default) targets the fork with localization support.

## Branches — pick the host you target

| Branch | Host target | Notes |
| --- | --- | --- |
| **`0.0.54`** | upstream `compujuckel/AssettoServer` `v0.0.54` (`net8.0`) | **This branch.** Older plugin lifecycle API (`CriticalBackgroundService` / `IAssettoServerAutostart`). |
| `main` | upstream master (baseline `v0.0.55-pre35`, `net9.0`) | Faithful mirror of the upstream in-tree `SamplePlugin`. |
| `0.0.55custom` (default) | [`Ereebay/AssettoServer`](https://github.com/Ereebay/AssettoServer) `0.0.55-main` (`net9.0`) | Adds the localization template (`ILocalizationService`, `lang/`, localized Lua injection). |

## How it works

AssettoServer loads plugins from `<server>/plugins/<PluginName>/<PluginName>.dll`. A plugin is just a .NET 8 class library that references the AssettoServer host assemblies **at compile time only** (`<Private>false</Private>` + `<ExcludeAssets>runtime</ExcludeAssets>`) — the running server provides them, so they are never bundled with your DLL.

Because this template references the host via relative paths (`..\AssettoServer\…`), **it must live inside an AssettoServer checkout**, right next to the `AssettoServer/` and `AssettoServer.Shared/` folders. The repo/folder name does **not** matter to the build — only its position does.

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- A clone of AssettoServer `v0.0.54` (the host you build against)

## Getting started

1. **Create your repo** from this template — the green **Use this template** button on GitHub (switch to this `0.0.54` branch first).

2. **Rename the template to your plugin** — run the scaffolder from the repo root (PowerShell 5.1+):
   ```powershell
   .\scaffold.ps1 -Name MyThing        # -> MyThingPlugin
   ```
   It renames the csproj/classes and rewrites namespaces, routes and docs, then deletes itself. (Manual checklist below if you prefer.)

3. **Clone the host:**
   ```bash
   git clone --branch v0.0.54 https://github.com/compujuckel/AssettoServer.git
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
   The plugin DLL lands in `bin/Release/net8.0/<YourPlugin>.dll`.

> In **Debug** the build drops the DLL into the host's `bin/Debug/net8.0/plugins/<YourPlugin>/` when configured, so running the server from your IDE picks it up automatically.

## Running your plugin on a server

Publish into the host's output tree (per-RID `out-<rid>/plugins/`):

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
| `Sample.cs` | An autostart service (`CriticalBackgroundService` / `IAssettoServerAutostart`) — runs for the lifetime of the server. |
| `SampleController.cs` | ASP.NET Core controller — HTTP routes are auto-discovered from the plugin assembly. |
| `SampleCommandModule.cs` | Qmmands chat command module — commands are auto-discovered from the plugin assembly. |

## Renaming it manually (if you skip the scaffolder)

`scaffold.ps1` automates all of this; the full list of places the name appears:

1. `SamplePlugin.csproj` → `<YourPlugin>.csproj` (also update its `<Description>`).
2. Namespace `SamplePlugin` → `<YourPlugin>` in every `.cs` file.
3. The `Sample*` classes: `SampleModule`, `SampleConfiguration`, `SampleConfigurationValidator`, `SampleController`, `SampleCommandModule`, `Sample`.
4. The config tag (`!SampleConfiguration`) and the `EnablePlugins` entry.
5. Route/command strings (`/sampleplugin`) if you care.
6. `README.md` and the workflow artifact name.

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

Check out a different branch of this template (see the table above) and the matching tag/branch in the host clone. Note that `0.0.55` lines use plain `BackgroundService` / `IHostedService` and target `net9.0`.

## Continuous integration

`.github/workflows/build.yml` checks out `compujuckel/AssettoServer@v0.0.54`, drops this repo inside it, and builds with .NET 8 — so the template is verified end to end on every push.

## License

Licensed under the **GNU AGPL-3.0** — the same license as [AssettoServer](https://github.com/compujuckel/AssettoServer), which this plugin links against. See [LICENSE](LICENSE).
