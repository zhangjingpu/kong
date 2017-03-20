local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson.safe"
local http = require "resty.http"
local url = require "socket.url"

local RequestBatchHandler = BasePlugin:extend()

local ngx_log = ngx.log
local DEBUG = ngx.DEBUG

function RequestBatchHandler:new()
  RequestBatchHandler.super.new(self, "request-batch")
end

local function make_request(conf, method, url)
  local parsed_url = url.parse(url)

  local host = parsed_url.host
  local is_https = parsed_url.scheme == "https"
  local port = parsed_url.port or (is_https and 443 or 80)
  local path = parsed_url.path

  -- Trigger request
  local client = http.new()
  client:connect(host, port)
  client:set_timeout(conf.timeout)
  if is_https then
    local ok, err = client:ssl_handshake()
    if not ok then
      return false, err
    end
  end

  local res, err = client:request {
    method = method,
    path = parsed_url.path,
    body = request.body,
    headers = request.headers
  }
  if not res then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  local body = res:read_body()
  local headers = res.headers

  local ok, err = client:set_keepalive(conf.keepalive)
  if not ok then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  ngx.status = res.status

  -- Send response to client
  for k, v in pairs(headers) do
    ngx.header[k] = v
  end

  ngx.say(body)

  return ngx.exit(res.status)
end

function RequestBatchHandler:access(conf)
  RequestBatchHandler.super.access(self)
  
  for k, v in pairs(conf.requests) do
    local method = v.method or ngx.req.get_method()
    local url = v.url

    ngx_log(DEBUG, "requesting ", k, " at ", method, url)

    local res, err = make_request(conf, method, url)
    if err then

    end
  end

  
end

RequestBatchHandler.PRIORITY = 750

return RequestBatchHandler
