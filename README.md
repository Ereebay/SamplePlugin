# AssettoServer Sample Plugin (Template)

A ready-to-build starter template for writing your own [AssettoServer](https://github.com/compujuckel/AssettoServer) plugin.

It is the upstream `SamplePlugin` (copied verbatim from AssettoServer **`v0.0.55-pre35`**), extracted into a standalone repository so you can click **Use this template** on GitHub and start from a clean slate. Out of the box it demonstrates the five things almost every plugin needs:

> **Branch `0.0.55`** — targets AssettoServer **0.0.55** (`net9.0`). Building for **0.0.54** (`net8.0`)? Use the [`0.0.54` branch](../../tree/0.0.54) instead — its plugin lifecycle API differs (see [Building against a different server version](#building-against-a-different-server-version)).

- an **Autofac module** that registers your services — `SampleModule.cs`
- a **YAML config section** with **FluentValidation** — `SampleConfiguration.cs`, `SampleConfigurationValidator.cs`
- a long-lived **background service** that starts with the server — `Sample.cs`
- an **HTTP route** — `SampleController.cs`
- a **chat command** — `SampleCommandModule.cs`

## How it works

AssettoServer loads plugins from `<server>/plugins/<PluginName>/<PluginName>.dll`. A plugin is just a .NET 9 class library that references the AssettoServer host assemblies **at compile time only** (`<Private>false</Private>` + `<ExcludeAssets>runtime</ExcludeAssets>`) — the running server provides them, so they are never bundled with your DLL.

Because this template references the host via relative paths (`..\AssettoServer\…`), **it must live inside an AssettoServer checkout**, right next to the `AssettoServer/` and `AssettoServer.Shared/` folders.

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- A clone of AssettoServer (the host you build against)

## Getting started

1. **Create your repo** from this template — the green **Use this template** button on GitHub.

2. **Clone the AssettoServer host at the version this template targets (`v0.0.55-pre35`):**
   ```bash
   git clone --branch v0.0.55-pre35 https://github.com/compujuckel/AssettoServer.git
   ```

3. **Clone your plugin repo _into_ the AssettoServer folder** so it sits next to the host projects:
   ```bash
   cd AssettoServer
   git clone https://github.com/<you>/<your-plugin-repo>.git
   ```
   Your tree should look like this:
   ```
   AssettoServer/
   ├── AssettoServer/                 # main server project
   ├── AssettoServer.Shared/          # plugin-facing API surface
   ├── AssettoServer.sln
   └── <your-plugin-repo>/            # ← this template
       └── SamplePlugin.csproj
   ```

4. **Build:**
   ```bash
   cd <your-plugin-repo>
   dotnet build -c Release
   ```
   The plugin DLL lands in `bin/Release/net9.0/SamplePlugin.dll`.

> Tip: to get IDE IntelliSense across the host, add the project to the server solution:
> `dotnet sln ../AssettoServer.sln add SamplePlugin.csproj`
>
> In **Debug** the build also drops the DLL into `..\AssettoServer\bin\Debug\net9.0\plugins\SamplePlugin\`, so running the server from your IDE picks it up automatically.

## Running your plugin on a server

Publish straight into the server's output tree (writes to the host's `out-<rid>/plugins/` folder):

```bash
dotnet publish -c Release -r win-x64     # or linux-x64 / linux-arm64
```

…or just copy the build output into your server install manually:

```
<server>/plugins/SamplePlugin/SamplePlugin.dll
```

Enable the plugin in `extra_cfg.yml`:

```yaml
EnablePlugins:
- SamplePlugin
```

Add its config section as a tagged YAML document at the end of `extra_cfg.yml` (the `!` tag is matched against your config class name):

```yaml
---
!SampleConfiguration
Hello: World!
```

Then verify the route and command work:

- **HTTP:** `GET http://<server>:<httpPort>/sampleplugin` → `Hello from sample plugin!`
- **Chat:** type `/sampleplugin` in-game → `Hello from sample plugin!`

## Anatomy

| File | Role |
| --- | --- |
| `SampleModule.cs` | Autofac module (`AssettoServerModule<SampleConfiguration>`). Registers your services; the generic base opts the plugin into a YAML config section. |
| `SampleConfiguration.cs` | The plugin's `extra_cfg.yml` section (the `!SampleConfiguration` document). |
| `SampleConfigurationValidator.cs` | FluentValidation rules for the config — errors surface at startup, pointing at the offending key. |
| `Sample.cs` | A `BackgroundService` registered as an `IHostedService` — runs for the lifetime of the server. |
| `SampleController.cs` | ASP.NET Core controller — HTTP routes are auto-discovered from the plugin assembly. |
| `SampleCommandModule.cs` | Qmmands chat command module — commands are auto-discovered from the plugin assembly. |

## Renaming it to your own plugin

The project name is `SamplePlugin`. To make it yours:

1. Rename `SamplePlugin.csproj` → `<YourPlugin>.csproj`.
2. Replace the namespace `SamplePlugin` with `<YourPlugin>` in every `.cs` file.
3. Rename the `Sample*` classes (`SampleModule`, `SampleConfiguration`, `SampleConfigurationValidator`, `SampleController`, `SampleCommandModule`, `Sample`).
4. Update the config tag (`!SampleConfiguration`) and the `EnablePlugins` entry to the new names.
5. Rename the route (`/sampleplugin`) and command (`sampleplugin`) strings if you like.

AssettoServer matches the YAML config tag against your config type name and discovers controllers/commands by scanning the plugin assembly — so the class names and namespaces are entirely up to you.

## Building against a different server version

This branch (**`0.0.55`**) targets AssettoServer **`v0.0.55-pre35`** (`net9.0`). To build against another release on the same major line, check out a different tag in the host clone:

```bash
cd AssettoServer && git checkout <tag>
```

> ℹ️ Building for AssettoServer **`0.0.54`** (`net8.0`)? Use the [`0.0.54` branch](../../tree/0.0.54) of this template instead. The plugin lifecycle API changed between the two: `0.0.54` uses `CriticalBackgroundService` / `IAssettoServerAutostart`, whereas `0.0.55` uses plain `BackgroundService` / `IHostedService` and targets `net9.0`.

## Continuous integration

`.github/workflows/build.yml` checks out `compujuckel/AssettoServer@v0.0.55-pre35`, drops this repo inside it, and builds — so the template is verified end to end on every push. Change the `ref:` (and the framework, per the note above) to target a different server version.

## License

Licensed under the **GNU AGPL-3.0** — the same license as [AssettoServer](https://github.com/compujuckel/AssettoServer), which this plugin links against. See [LICENSE](LICENSE).
