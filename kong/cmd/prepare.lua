local prefix_handler = require "kong.cmd.utils.prefix_handler"
local conf_loader = require "kong.conf_loader"
local log = require "kong.cmd.utils.log"

local function execute(args)
  local conf = assert(conf_loader(args.conf, {
    prefix = args.prefix
  }))

  local ok, err = prefix_handler.prepare_prefix(conf, args.nginx_conf)
  if not ok then
    log.verbose("could not prepare Kong")
    error(err) -- report to main error handler
  end
end

local lapp = [[
Usage: kong prepare [OPTIONS]

Prepares the Kong prefix in the configured prefix directory.

Options:
 -c,--conf    (optional string) configuration file
 -p,--prefix  (optional string) override prefix directory
]]

return {
  lapp = lapp,
  execute = execute
}
