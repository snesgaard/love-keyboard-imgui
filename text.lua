local text_format = {}

function text_format.vertical_align_offset(valign, font, h)
	if valign == "top" then
		return 0
	elseif valign == "bottom" then
		return h - font:getHeight()
	end
	-- else: "middle"
	return (h - font:getHeight()) / 2
end

function text_format.draw(text, font, shape, opt)
	opt = opt or {}
	if font then
		gfx.setFont(font)
	else
		font = gfx.getFont()
	end
	local dy = text_format.vertical_align_offset(opt.valign, font, shape.h)
    gfx.printf(text, shape.x, shape.y + dy, shape.w, opt.align or "center")
end

return text_format
