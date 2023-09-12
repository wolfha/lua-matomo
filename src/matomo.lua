--[[
Copyright (c) 2022 Wolfgang Hauptfleisch <dev@augmentedlogic.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]
local https = require("ssl.https")
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")


local _M = { VERSION = "lua-matomo 0.2", YEAR = "year", MONTH = "month", DAY = "day" }
local mt = { __index = {} }


    function _M.new(host)
        local defaults = { host = host,
                           date = os.date('%Y-%m-%d'),
                           period = "day",
                           timeout = 60,
                           useragent = _M.VERSION }

        local object = setmetatable({ settings = defaults, response = {} },  mt)
    return object
    end

    function _M.prettyPrint(t, indent)
      local indent=indent or ''
      if t then
         for key,value in pairs(t) do
            io.write(indent,'[',tostring(key),']')
               if type(value)=="table" then io.write(':\n') _M.prettyPrint(value,indent..'\t')
          else io.write(' = ',tostring(value),'\n') end
          end
       end 
    end

    local function startsWith(haystack, needle)
        return haystack:find('^' .. needle) ~= nil
    end

    local function get(url)
        local response_body = {}
        local r, sc, h, s
        local https_options = {
                  url = url,
                  method = 'GET',
                  headers = {},
                  sink = ltn12.sink.table(response_body),
                  protocol = "tlsv1",
              }
        local http_options = {
                  url = url,
                  method = 'GET',
                  headers = {},
                  sink = ltn12.sink.table(response_body),
        }
              if(startsWith(url, "https")) then
                 r, sc, h, s = https.request(https_options)
              else
                 r, sc, h, s = http.request(http_options)
              end
              local rb = table.concat(response_body)
    return rb, sc;
    end

    function mt.__index:setToken(token)
        self.settings.token = token
    end

    function mt.__index:setUserAgent(useragent)
        self.settings.useragent = useragent
    end

    function mt.__index:setTimeout(timeout)
        self.settings.timeout = timeout
    end

    function mt.__index:setHost(host)
        self.settings.host = host
    end

    function mt.__index:setPeriod(period)
        self.settings.period = period
    end

    function mt.__index:setDate(date)
        self.settings.date = date
    end

    function mt.__index:setSiteId(site_id)
        self.settings.site_id = site_id
    end

    function mt.__index:getHttpStatus()
    return self.response.status_code
    end

    function mt.__index:getReport(method)
        self.response.status_code = nil;
        http.USERAGENT = self.settings.useragent
        http.TIMEOUT = self.settings.timeout or http.TIMEOUT
        local url_p1 = self.settings.host.."/?module=API&method=API.getBulkRequest&format=json&urls[0]=method%3d"..method
        local url_p2 = "&idSite="..self.settings.site_id.."&date="..self.settings.date
        local url_p3 = "&period="..self.settings.period.."&token_auth="..self.settings.token
        local url = url_p1..url_p2..url_p3;
        local data = nil
        local sc = nil
        pcall(function()
                  local pl, sc = get(url)
                  self.response.status_code = sc
                  data = json.decode(pl)
              end)
     return data
     end

return _M
