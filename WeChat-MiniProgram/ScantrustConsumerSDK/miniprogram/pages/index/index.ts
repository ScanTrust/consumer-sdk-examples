// index.ts
const VIDEO_AUTH_URL = 'https://verify.scantrust.cn/video/'

Component({
  data: {
    title: 'Authentication Video Auth App',
    url: ''
  },
  lifetimes: {
    attached() {
      const { iphoneModel } = getApp<IAppOption>().globalData
      this.setData({ url: iphoneModel ? `${VIDEO_AUTH_URL}?iphone-model=${iphoneModel}` : VIDEO_AUTH_URL })
    },
  },
})
