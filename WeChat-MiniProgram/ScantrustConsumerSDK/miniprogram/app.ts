// app.ts
const IPHONE_IDENTIFIER = /<(iPhone\d+,\d+)>/

App<IAppOption>({
  globalData: { iphoneModel: null },
  onLaunch() {
    const { model } = wx.canIUse('getDeviceInfo') ? wx.getDeviceInfo() : wx.getSystemInfoSync()
    console.log('[iphone-model] device model:', model)
    this.globalData.iphoneModel = (model || '').match(IPHONE_IDENTIFIER)?.[1] ?? null
  },
})
