--- pptx/ppt/odp previewer via LibreOffice + pdftoppm (yazi 26.5.6)
local M = {}

local function file_stem(url_str)
	local name = url_str:match("/([^/]+)$") or url_str
	-- decode URL percent-encoding (e.g. %20 → space)
	name = name:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
	return name:match("^(.+)%.[^.]+$") or name
end

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then return end

	local ok, err = self:preload(job)
	if not ok or err then
		return ya.preview_widget(job, err)
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek() end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local src  = tostring(job.file.path)
	local stem = file_stem(tostring(job.file.url))
	local tmp  = "/tmp/yazi_pptx_" .. (tostring(cache):match("([^/]+)$") or "tmp")

	Command("mkdir"):arg({ "-p", tmp }):output()

	-- Step 1: pptx/ppt/odp → PDF via LibreOffice headless
	local lo, lo_err = Command("libreoffice")
		:arg({ "--headless", "--convert-to", "pdf:impress_pdf_Export", "--outdir", tmp, src })
		:output()

	if not lo or not lo.status.success then
		Command("rm"):arg({ "-rf", tmp }):output()
		return true, Err("LibreOffice 转换失败: %s", lo_err or (lo and lo.stderr) or "")
	end

	local pdf = tmp .. "/" .. stem .. ".pdf"
	if not fs.cha(Url(pdf)) then
		Command("rm"):arg({ "-rf", tmp }):output()
		return true, Err("未找到转换后的 PDF，预期路径: %s", pdf)
	end

	-- Step 2: PDF 第一页 → JPEG（复用已装的 pdftoppm）
	local pp, pp_err = Command("pdftoppm")
		:arg({ "-f", "1", "-l", "1", "-singlefile", "-jpeg", "-jpegopt", "quality=85", pdf, tostring(cache) })
		:output()

	Command("rm"):arg({ "-rf", tmp }):output()

	if not pp or not pp.status.success then
		return true, Err("pdftoppm 失败: %s", pp_err or (pp and pp.stderr) or "")
	end

	-- pdftoppm -jpeg -singlefile 输出为 <cache>.jpg，precache 缩放到预览区
	return ya.image_precache(Url(tostring(cache) .. ".jpg"), cache)
end

return M
