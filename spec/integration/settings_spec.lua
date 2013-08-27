package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local _ = require("underscore")

describe("When defining settings", function()
  describe("a user can configure based on environments", function()
    it("defaults to all environments", function()
      local context = nil
      mock_app(function(app)
        app:configure(function()
          context = "context"
        end)
      end)

      assert.same("context", context)
    end)

    it("only runs against the default environment", function()
      local context = nil
      mock_app(function(app)
        app:configure('development', function()
          context = "development"
        end)
        app:configure('production', function()
          context = 'production'
        end)
      end)

      assert.same('development', context)
    end)

    it("runs against multiple specified environments", function()
      local context = nil

      mock_app(function(app)
        app:setting('environment', 'staging')
        app:configure('staging', 'production', function()
          context = "not_development"
        end)

        app:configure('development', function()
          context = 'development'
        end)
      end)

      assert.same('not_development', context)
    end)
  end)
end)
