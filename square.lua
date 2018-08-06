local log = hs.logger.new('square', 'debug')

log.i('Loading Square config')


local http = dofile('./lib/http.lua')

http.registerURLHandler()
http.registerShortenerHost('go.squareup.com')
http.openHostWithBrowser('www.smartrecruiters.com', http.chromeBundleId)
