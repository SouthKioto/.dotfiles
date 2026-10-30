-- Matugen — nie edytuj ręcznie (szablon: ~/.config/matugen/templates/nvim-palette.lua)
-- paleta base16 dla colors/matugen.lua + kolory składni (custom_colors z matugen/config.toml)
return {
    base00 = "{{colors.surface.default.hex}}",
    base01 = "{{colors.surface_container.default.hex}}",
    base02 = "{{colors.surface_container_highest.default.hex}}",
    base03 = "{{colors.outline.default.hex}}",
    base04 = "{{colors.on_surface_variant.default.hex}}",
    base05 = "{{colors.on_surface.default.hex}}",
    base06 = "{{colors.secondary_fixed.default.hex}}",
    base07 = "{{colors.primary_fixed.default.hex}}",
    base08 = "{{colors.red.default.hex}}",
    base09 = "{{colors.orange.default.hex}}",
    base0A = "{{colors.yellow.default.hex}}",
    base0B = "{{colors.green.default.hex}}",
    base0C = "{{colors.cyan.default.hex}}",
    base0D = "{{colors.blue.default.hex}}",
    base0E = "{{colors.magenta.default.hex}}",
    base0F = "{{colors.primary.default.hex}}",

    -- akcenty UI z tapety
    accent = "{{colors.primary.default.hex}}",
    accent2 = "{{colors.tertiary.default.hex}}",
    sand = "{{colors.secondary.default.hex}}",
    moss = "{{colors.tertiary_fixed.default.hex}}",

    -- kolory składni
    red = "{{colors.red.default.hex}}",
    orange = "{{colors.orange.default.hex}}",
    yellow = "{{colors.yellow.default.hex}}",
    green = "{{colors.green.default.hex}}",
    cyan = "{{colors.cyan.default.hex}}",
    blue = "{{colors.blue.default.hex}}",
    magenta = "{{colors.magenta.default.hex}}",
    error_bg = "{{colors.red_container.default.hex}}",
}
