type MetricaCall = ((...args: unknown[]) => void) & {
  a?: unknown[][]
  l?: number
}

const counterId = 111327586

const metricaWindow = window as typeof window & {
  ym?: MetricaCall
}

const queuedCall: MetricaCall = (...args: unknown[]) => {
  queuedCall.a = queuedCall.a ?? []
  queuedCall.a.push(args)
}

queuedCall.l = Date.now()
metricaWindow.ym = metricaWindow.ym ?? queuedCall

const callMetrica = (...args: unknown[]) => {
  metricaWindow.ym?.(...args)
}

if (!document.querySelector(`script[data-metrica-id="${counterId}"]`)) {
  const tag = document.createElement("script")

  tag.src = `https://mc.yandex.ru/metrika/tag.js?id=${counterId}`
  tag.async = true
  tag.dataset.metricaId = String(counterId)
  tag.setAttribute("spa-preserve", "")

  document.head.appendChild(tag)
}

callMetrica(counterId, "init", {
  defer: true,
  clickmap: true,
  trackLinks: true,
  accurateTrackBounce: true,
  webvisor: false,
})

let lastSentUrl = ""
let previousUrl = document.referrer

const sendPageView = () => {
  const currentUrl = window.location.href

  if (currentUrl === lastSentUrl) {
    return
  }

  callMetrica(counterId, "hit", currentUrl, {
    title: document.title,
    referer: previousUrl,
  })

  previousUrl = currentUrl
  lastSentUrl = currentUrl
}

document.addEventListener("nav", sendPageView)
