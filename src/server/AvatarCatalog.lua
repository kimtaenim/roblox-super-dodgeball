-- 로블록스 카탈로그 아바타 부품 : NPC에게 요즘 아바타의 몸·얼굴(다이내믹 헤드)·머리카락을 입힌다.
-- 번호는 Config.Npc.Personas의 catalog에 "번호 + 기대하는 이름"으로 적는다.
-- 서버를 켤 때 번호마다 로블록스에 진짜 이름을 물어보고, 이름이 맞을 때만 쓴다.
-- 번호가 틀렸거나 불러오지 못하면 그 부품은 빼고 직접 만든 모습(NpcLooks)으로 돌아간다.

local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local AvatarCatalog = {}

local bundles = {} -- 번들 번호 → 그 번들 차림(HumanoidDescription), 못 쓰면 false
local assets = {} -- 아이템 번호 → 쓸 수 있으면 true, 못 쓰면 false
local ready = false -- 확인이 다 끝났는지

-- 이름을 비교하기 쉽게 소문자 영어·숫자만 남긴다.
local function simplify(text)
	local result = string.gsub(string.lower(text or ""), "[^%w]", "")
	return result
end

-- 진짜 이름과 기대하는 이름이 같은지. 짧은 이름("Man")은 똑같아야 하고,
-- 긴 이름은 한쪽이 다른 쪽을 품어도 같다고 본다 (뒤에 " - Head" 같은 말이 붙는 경우).
local LOOSE_MATCH_LENGTH = 8
local function sameName(actual, expected)
	local a, e = simplify(actual), simplify(expected)
	if a == "" or e == "" then
		return false
	end
	if a == e then
		return true
	end
	if #e < LOOSE_MATCH_LENGTH then
		return false
	end
	return string.find(a, e, 1, true) ~= nil or string.find(e, a, 1, true) ~= nil
end

-- 번들을 확인하고 그 번들의 차림을 받아 온다.
local function loadBundle(entry)
	local ok, details = pcall(AssetService.GetBundleDetailsAsync, AssetService, entry.id)
	if not ok or not sameName(details.Name, entry.name) then
		warn(("카탈로그 번들 %d (%s)을 쓸 수 없어요: %s"):format(entry.id, entry.name, if ok then details.Name else tostring(details)))
		return false
	end
	for _, item in details.Items do
		if item.Type == "UserOutfit" then
			local found, description = pcall(Players.GetHumanoidDescriptionFromOutfitId, Players, item.Id)
			if found then
				return description
			end
		end
	end
	warn(("카탈로그 번들 %d (%s)에서 차림을 찾지 못했어요"):format(entry.id, entry.name))
	return false
end

-- 아이템(머리카락·얼굴)을 확인한다.
local function checkAsset(entry)
	local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, entry.id, Enum.InfoType.Asset)
	local good = ok and sameName(info.Name, entry.name)
	if not good then
		warn(("카탈로그 아이템 %d (%s)을 쓸 수 없어요: %s"):format(entry.id, entry.name, if ok then info.Name else tostring(info)))
	end
	return good
end

-- NPC들이 쓸 번호를 모두 미리 확인한다 (서버 시작 때 한 번, 시간이 걸리니 따로 돌린다).
function AvatarCatalog.prepare(personas)
	for _, persona in personas do
		local catalog = persona.catalog
		if catalog then
			for _, key in { "body", "head" } do
				local entry = catalog[key]
				if entry and bundles[entry.id] == nil then
					bundles[entry.id] = loadBundle(entry)
				end
			end
			for _, key in { "hair", "face" } do
				local entry = catalog[key]
				if entry and assets[entry.id] == nil then
					assets[entry.id] = checkAsset(entry)
				end
			end
		end
	end
	ready = true
end

-- 확인된 번들 차림을 돌려준다 (없거나 못 쓰면 nil).
function AvatarCatalog.bundle(entry)
	if not ready or not entry then
		return nil
	end
	return bundles[entry.id] or nil
end

-- 확인된 아이템인지 알려준다.
function AvatarCatalog.hasAsset(entry)
	return ready and entry ~= nil and assets[entry.id] == true
end

return AvatarCatalog
