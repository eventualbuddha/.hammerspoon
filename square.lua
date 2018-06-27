local log = hs.logger.new('square', 'debug')

log.i('Loading Square config')

function checkCoffeeScriptInJobReqs()
  local engJobsURL = 'https://squareup.com/careers/jobs?role=Engineering'
  log.df('Requesting %s…', engJobsURL)
  local status, body = hs.http.get(engJobsURL, {})

  if status ~= 200 then
    log.df('Failed to request Engineering job list (status=%d): %s', status, body)
    return nil
  end

  local found = false

  for url in string.gmatch(body, 'https://www.smartrecruiters.com/Square/%d+') do
    log.df('Requesting %s…', url)
    local status, body = hs.http.get(url)

    if status ~= 200 then
      log.df('Failed to get job page (status=%d, url=%s): %s', status, url, body)
      return nil
    end

    if string.find(string.lower(body), 'coffeescript') ~= nil then
      log.df('Found CoffeeScript in %s', url)
      found = true
    end
  end

  return found
end

local coffeeScriptCheckTimer = hs.timer.doEvery(6 * 60 * 60, function()
  local result = checkCoffeeScriptInJobReqs()

  if result == true then
    -- found CoffeeScript =\
    hs.notify.new({title='Square Job Reqs', informativeText='Found CoffeeScript in job reqs'}):send()
  elseif result == false then
    -- no CoffeeScript! tell someone
    hs.notify.new({title='Square Job Reqs', informativeText='CoffeeScript is no longer present!'}):send()
    coffeeScriptCheckTimer:stop()
  end
end)

local http = dofile('./lib/http.lua')

http.registerURLHandler()
http.registerShortenerHost('go.squareup.com')
http.openHostWithBrowser('www.smartrecruiters.com', http.chromeBundleId)
