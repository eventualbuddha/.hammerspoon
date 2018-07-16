local http = {}
local log = hs.logger.new('lib/http', 'debug')

http.safariBundleId = 'com.apple.Safari'
http.chromeBundleId = 'com.google.Chrome'
http.preferredBrowserBundleId = http.safariBundleId

-- Includes a common list of shortener services.
http.shortenerHosts = {
  'go', -- often used inside companies, i.e. go/org
  'g.co',
  'goo.gl',
  'bit.ly',
  'tinyurl.com',
}

local hostToBundleIdMap = {}

hostToBundleIdMap['meet.google.com'] = http.chromeBundleId
hostToBundleIdMap['hangouts.google.com'] = http.chromeBundleId
hostToBundleIdMap['chrome.google.com'] = http.chromeBundleId

function http.registerShortenerHost(host)
  table.insert(http.shortenerHosts, host)
end

function http.openHostWithBrowser(host, browserBundleId)
  hostToBundleIdMap[host] = browserBundleId
end

function http.registerURLHandler()
  hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
    log.df('Handling URL: %s', fullURL)

    local redirected = followURLRedirects(fullURL)

    if redirected ~= fullURL then
      local parts = hs.http.urlParts(redirected)

      scheme = parts['scheme']
      host = parts['host']
      params = {}
      fullURL = redirected
      if parts['queryItems'] ~= nil then
        for _, pair in ipairs(parts['queryItems']) do
          for k, v in pairs(pair) do
            params[k] = v
          end
        end
      end
    end

    local browserBundleId = hostToBundleIdMap[host] or http.preferredBrowserBundleId

    log.df('Forwarding to %s: %s', browserBundleId, fullURL)
    hs.urlevent.openURLWithBundle(fullURL, browserBundleId)
  end
end

function http.unregisterURLHandler()
  hs.urlevent.httpCallback = nil
end

function followURLRedirects(url, redirectsRemaining)
  if redirectsRemaining == nil then
    redirectsRemaining = 10
  end

  if redirectsRemaining == 0 then
    return url
  end

  local parts = hs.http.urlParts(url)

  -- special case for this one since we can just pull the URL
  -- out of a query parameter without making a request
  if url:find('^https://www.google.com/url\\?') ~= nil then
    for _, pair in ipairs(parts['queryItems']) do
      for k, v in pairs(pair) do
        if k == 'q' then
          return followURLRedirects(v, redirectsRemaining - 1)
        end
      end
    end
  end

  local isShortenerURL = false

  for _, shortener in ipairs(http.shortenerHosts) do
    if parts['host'] == shortener then
      isShortenerURL = true
      break
    end
  end

  if not isShortenerURL then
    return url
  end

  log.df('attempting to resolve shortener URL: %s', url)
  local success, _, headerText = hs.osascript.applescript(string.format('do shell script "curl -sI %s"', url))

  if not success then
    log.df('failed: %s', hs.inspect(headerText))
    return url
  end

  local location = headerText:match('[Ll]ocation: ([^%s]+)')

  if location ~= nil then
    log.df('following redirect for URL: %s ---> %s', url, location)
    return followURLRedirects(location, redirectsRemaining - 1)
  else
    log.df('no location header found in response headers: %s', headerText)
    return url
  end
end

return http
