# Consumer SDK WeChat Mini Program Example

This guide explains how to correctly integrate Scantrust Web Video Auth inside a WeChat Mini Program using the `<web-view>` component.

## 1. Account Requirements

`<web-view>` is **not available to personal-type Mini Programs**. You need a non-personal (company / organisation) Mini Program account, and it must have completed WeChat verification.

This example ships with a **placeholder AppID** — it is not a working one. Replace it with your own in `project.config.json` before you build:

```json
{
  "appid": "YOUR_APP_ID",
  "miniprogramRoot": "miniprogram/",
  "compileType": "miniprogram"
}
```

You find your AppID in the Mini Program admin console (`mp.weixin.qq.com`) under **开发管理 (Development Management) → 开发设置 (Development Settings) → AppID (小程序ID)**.

Select that same AppID when you import the project into **WeChat DevTools** (`微信开发者工具`). The AppID is what ties the project to the account whose domain whitelist (step 2) applies — with the placeholder left in place, the `web-view` component will not render on a real device.

## 2. Whitelist the Verification Domain (业务域名)

`<web-view>` only loads URLs whose domain is registered as a **business domain** (`业务域名`) for your Mini Program. This is the step that most integrations get stuck on.

In the Mini Program admin console:

**`mp.weixin.qq.com` → 开发管理 (Development Management) → 开发设置 (Development Settings) → 业务域名 (Business Domain)**

1. Download the verification file WeChat gives you (`*.txt`).
2. Host it at the **root** of the domain you want to whitelist, reachable over HTTPS.
3. Add the Scantrust verification domain — the one your `web-view` loads:
   - `verify.scantrust.cn` for the China deployment (used by this example)
   - `verify.scantrust.com` for the global deployment

Notes:

- The domain must be served over **HTTPS**, and for the mainland-China deployment it must be ICP-registered.
- **Any domain loaded in an `iframe` inside that page must be whitelisted too**, not just the top-level `src`.
- Up to 20 business domains can be configured, and the list can only be changed a limited number of times per month — plan the change rather than iterating on it.
- In WeChat DevTools you can tick **`不校验合法域名、web-view(业务域名)...`** to skip the check while developing. This works **only in DevTools** — on a real device the whitelist is always enforced.

## 3. Load the Verification Page in a `web-view`

Register the page in `miniprogram/app.json`:

```json
{
  "pages": [
    "pages/index/index"
  ],
  "window": {
    "navigationBarTextStyle": "black",
    "navigationBarTitleText": "Weixin",
    "navigationBarBackgroundColor": "#ffffff"
  },
  "style": "v2",
  "componentFramework": "glass-easel",
  "lazyCodeLoading": "requiredComponents"
}
```

Point the component at the Scantrust verification URL — `miniprogram/pages/index/index.ts`:

```ts
// index.ts
Component({
  data: {
    title: 'Authentication Video Auth App',
    url: 'https://verify.scantrust.cn/video/'
  },
})
```

`miniprogram/pages/index/index.wxml`:

```xml
<!--index.wxml-->
<web-view class="view" src="{{url}}"/>
```

`miniprogram/pages/index/index.wxss`:

```css
/**index.wxss**/
page {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.view {
  height: 100vh;
  width: 100% !important;
}
```

Constraints worth knowing:

- **Only one `web-view` per page**, and it automatically covers the whole page — any other component on that page will not be visible. Give the page a full-viewport height so the camera view is not clipped.
- `<web-view>` is **not supported when the page uses `navigationStyle: custom`**.
- Load and failure states are available through the component's `bindload` / `binderror` events if you want to show your own error screen:

  ```xml
  <web-view class="view" src="{{url}}" bindload="onLoad" binderror="onError"/>
  ```

## 4. Build and Run

```bash
npm install          # installs miniprogram-api-typings for the TypeScript definitions
```

Then in WeChat DevTools:

1. **Import project** → select this folder (`ScantrustConsumerSDK`) → choose your own AppID.
2. The project compiles TypeScript through the built-in compiler plugin (`useCompilerPlugins: ["typescript"]` in `project.config.json`); no separate build step is required.
3. Preview with a real device (**预览** / Preview and scan the QR code) to verify the camera and the domain whitelist. The simulator is not a reliable check for either — the business-domain whitelist is only enforced on a real device, and camera behaviour inside `web-view` depends on the WeChat client version.

## API Documentation

The verification flow runs against the Scantrust Consumer API. Full documentation:

[https://devportal.scantrust.com/docs/build-with-scantrust/consumer/scantrust-consumer-api](https://devportal.scantrust.com/docs/build-with-scantrust/consumer/scantrust-consumer-api)

## Reference

- [`web-view` component](https://developers.weixin.qq.com/miniprogram/en/dev/component/web-view.html)
