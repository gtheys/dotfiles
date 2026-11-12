-- AIDEV-NOTE: plugin entry points. Keep in sync with package.toml deps.

-- full-border.yazi: clean borders on all panels
require("full-border"):setup()

-- starship.yazi: starship prompt as yazi header (needs `starship` in PATH)
require("starship"):setup()
