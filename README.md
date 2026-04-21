# Brain Game

Brain Game is a HarmonyOS wearable app with three mini games: Memory Grid, Number Flash, and Color Focus.
It is built with ArkTS and ArkUI for compact smartwatch layouts.

> Note: Shared project guides are available in [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Preview
<div>
  <img src="screenshots/ss1.png" width="24%" alt="Language page">
  <img src="screenshots/ss.png" width="24%" alt="Home page">
  <img src="screenshots/ss2.png" width="24%" alt="Game selection page">
  <img src="screenshots/ss3.png" width="24%" alt="Game page">
</div>

# Use Cases
- Memory improvement
- Visual focus and attention
- Fast thinking
- Eye and mind coordination
- Quick brain exercises on a watch

# Technology
## Stack
- **Languages**: ArkTS, ArkUI
- **Frameworks**: HarmonyOS 6.0.0 Beta3
- **Tools**: DevEco Studio 6.0.0.828
- **Libraries**: `@kit.ArkUI`, `@ohos.arkui.ArcList`

# Directory Structure
```text
entry/
├── src/main/ets/
│   ├── entryability/EntryAbility.ets
│   ├── entrybackupability/EntryBackupAbility.ets
│   ├── pages/
│   │   ├── GameColorFocus.ets
│   │   ├── GameMemoryBlock.ets
│   │   ├── GameNumberFlash.ets
│   │   ├── Index.ets
│   │   ├── LanguagePage.ets
│   │   └── SelectGamePage.ets
│   └── viewModel/
│       ├── langStore.ets
│       └── translations.ts
```

# Supported Device
- Huawei Watch 5

# License
Brain Game is distributed under the terms of the MIT License.
See the [LICENSE](./LICENSE) for more information.
