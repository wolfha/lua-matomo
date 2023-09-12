package.path = "../src/?.lua;"..package.path

local matomo = require('matomo');
local json = require('json');


local m = matomo.new("https://my_matomo_instance");
      m:setSiteId(1)
      m:setToken(my_secret_token)


      -- set the period day, months or year, the default is "matomo.DAY"
      m:setPeriod(matomo.YEAR)

      -- optional settings
      m:setUserAgent("matomo test") -- default is "lua-matomo <version>"
      m:setTimeout(120) -- default is 60


      -- see the Matomo Analytics docs for available methods
      local stats = m:getReport("VisitsSummary.get")

      -- get the http status code
      print(m:getHttpStatus())


      -- as the name of attributes and structure varies widely, you can use
      -- this to pretty print the response and see what data it contains 
      matomo.prettyPrint(stats)


      -- get some data from the response
      print(stats[1].nb_visits)
