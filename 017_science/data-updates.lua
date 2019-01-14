--whitelist for productivity module effect
for _, mod in pairs(data.raw.module) do
	if mod.effect ~= nil then
		for _, effect in pairs(mod.effect) do
			if effect[1] == productivity then
				if mod.limitation ~= nil then
					local limitation = mod.limitation
					--new stuff
					table.insert(limitation, "17-military-science-pack")
					table.insert(limitation, "17-chemical-science-pack")
					table.insert(limitation, "17-production-science-pack")
					table.insert(limitation, "17-utility-science-pack")
					table.insert(limitation, "17-low-density-structure")					
				end
			end
		end
	end
end

--overrides
local function recipe_change(table, condition, replace)
	for _=1, #table do
		if table[_][1] == condition then
			table[_] = replace
		end
	end
end

local function prerequisites(technology, condition, replace)
	for _=1, #technology do
		if technology[_] == condition then
			table.remove(technology, _)
			if replace ~= nil then
				table.insert(technology, replace)
			end
		end
	end
end

local function remove_science(technology, science_pack)
	for _, ingredient in pairs (technology) do
		if ingredient[1] == science_pack then
			table.remove(technology, _)
		end
	end
end

if settings.startup["017-recipes-changes"].value then
	recipe_change(data.raw["recipe"]["atomic-bomb"].ingredients, "processing-unit", {"rocket-control-unit", 15})
	
	recipe_change(data.raw["recipe"]["power-armor-mk2"].ingredients, "speed-module-3", {"speed-module-2", 5})
	recipe_change(data.raw["recipe"]["power-armor-mk2"].ingredients, "effectivity-module-3", {"effectivity-module-2", 5})
	local power_armor = data.raw["technology"]["power-armor-2"].prerequisites
	prerequisites(power_armor, "speed-module-3", "speed-module-2")
	prerequisites(power_armor, "effectivity-module-3", "effectivity-module-2")
	table.insert(power_armor, "advanced-electronics-2")
end

local r_effects = data.raw["technology"]["rocket-silo"].effects --remove the duplicate LDS effect in rocket-silo research
for _=1, #r_effects do
	if r_effects[_].type == "unlock-recipe" and (r_effects[_].recipe == "low-density-structure" or r_effects[_].recipe == "rocket-fuel" or r_effects[_].recipe == "rocket-control-unit") then
		r_effects[_] = nil
	end
end

data.raw["technology"]["nuclear-fuel-reprocessing"].unit.count = (1500-settings.startup["017-nuclear-reprocessing-discount"].value)

if settings.startup["017-pack-type-rebalancing"].value then
	remove_science(data.raw["technology"]["rocket-silo"].unit.ingredients, "military-science-pack")
	remove_science(data.raw["technology"]["kovarex-enrichment-process"].unit.ingredients, "high-tech-science-pack")
	remove_science(data.raw["technology"]["speed-module-3"].unit.ingredients, "high-tech-science-pack")
	table.insert(data.raw["technology"]["speed-module-3"].unit.ingredients, {"production-science-pack", 1})
	remove_science(data.raw["technology"]["effectivity-module-3"].unit.ingredients, "high-tech-science-pack")
	table.insert(data.raw["technology"]["effectivity-module-3"].unit.ingredients, {"production-science-pack", 1})
	remove_science(data.raw["technology"]["effect-transmission"].unit.ingredients, "high-tech-science-pack")
	table.insert(data.raw["technology"]["effect-transmission"].unit.ingredients, {"production-science-pack", 1})
	remove_science(data.raw["technology"]["logistic-system"].unit.ingredients, "production-science-pack")
end

if settings.startup["017-techtree"].value then	
	prerequisites(data.raw["technology"]["rocket-silo"].prerequisites, "rocket-speed-5", nil)
	data.raw["recipe"]["science-pack-2"].enabled = false
	
	if settings.startup["017-old-science"].value and settings.startup["017-techtree"].value then
		remove_effect_table = {
			{"advanced-electronics", "science-pack-3"},
			{"advanced-material-processing-2", "production-science-pack"},
			{"advanced-electronics-2", "high-tech-science-pack"}
		}
		
		data.raw["technology"]["science-pack-3"].effects = {
				{type = "unlock-recipe", recipe = "science-pack-3"},
				{type = "unlock-recipe", recipe = "17-chemical-science-pack"}
		}
		data.raw["technology"]["production-science-pack"].effects = {
				{type = "unlock-recipe", recipe = "production-science-pack"},
				{type = "unlock-recipe", recipe = "17-production-science-pack"}
		}
		data.raw["technology"]["high-tech-science-pack"].effects = {
				{type = "unlock-recipe", recipe = "high-tech-science-pack"},
				{type = "unlock-recipe", recipe = "17-utility-science-pack"}
		}
		
		for i=1, #remove_effect_table do
			local effects = data.raw["technology"][remove_effect_table[i][1]].effects
			for _=1, #effects do
				if effects[_] then
					if effects[_].type == "unlock-recipe" and effects[_].recipe == remove_effect_table[i][2] then
						table.remove(effects, _)
					end
				end
			end
		end
	end	
	
	local function compare(technology, science_pack, pre_tier)
		valid = true
		if technology and technology.unit then
			for l, j in pairs(technology.unit.ingredients) do
				if j[1] == pre_tier then
					valid = true
					break
				else
					valid = false
				end
			end
		end
		if valid == true then
			if technology.prerequisites then
				for _=1, #technology.prerequisites do
					local tech = data.raw["technology"][technology.prerequisites[_]]
					if valid == true then
						if tech then
							if tech.unit then
								for i, ingredients in pairs(tech.unit.ingredients) do
									if ingredients[1] == pre_tier then
										valid = false
										break
									else
										valid = true
									end
								end
							elseif valid == false then
								break
							end
						end
					end
				end
			end
		end
		if technology.prerequisites and valid == true then
			technology.prerequisites[#technology.prerequisites+1] = science_pack
			return true
		else
			return false
		end
	end
	
	for _, tech in pairs(data.raw["technology"]) do
		if tech.effects then
			for i=1, #tech.effects do
				if tech.effects[i].type == "unlock-recipe" then
					whitelisted = true
					break
				else
					whitelisted = false
				end
			end
			if whitelisted == true then
				local valid = compare(tech, "logistics-science-pack", "science-pack-2")
				if valid == false then
				local valid = compare(tech, "chemical-science-pack", "science-pack-3") end
				if valid == false then
				local valid = compare(tech, "production-science-pack", "production-science-pack") end
				if valid == false then
				local valid = compare(tech, "utility-science-pack", "high-tech-science-pack") end
			end
		end
	end
end

--player equipment changes
--https://forums.factorio.com/viewtopic.php?t=6059
if settings.startup["017-durability"].value then
	for _, axe in pairs(data.raw["mining-tool"]) do
		axe.durability = math.huge
	end

	for _, armor in pairs(data.raw["armor"]) do
		armor.durability = math.huge
	end
end

if settings.startup["017-axe"].value then
	for _, axe in pairs(data.raw["mining-tool"]) do
		for i, r in pairs(data.raw["recipe"]) do
			if data.raw["recipe"][i].result == axe.name then
				data.raw["recipe"][i].hidden = true
				data.raw["recipe"][i].ingredients = {}
			end
		end
	end
end

if settings.startup["017-equipment"].value and data.raw["recipe"]["belt-immunity-equipment"] == nil then
	data:extend({
		{
			type = "technology",
			name = "belt-immunity-equipment",
			icon_size = 128,
			icon = "__017_science__/graphics/technology/belt-immunity-equipment.png",
			prerequisites = {"modular-armor"},
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "belt-immunity-equipment"
				}
			},
			unit =
			{
				count = 50,
				ingredients = {{"science-pack-1", 1}, {"science-pack-2", 1}},
				time = 15
			},
			order = "g-ga"
		},
		{
			type = "recipe",
			name = "belt-immunity-equipment",
			enabled = false,
			energy_required = 10,
			ingredients =
			{
				{"advanced-circuit", 5},
				{"steel-plate", 10}
			},
			result = "belt-immunity-equipment"
		}
	})
end

local lds_recipes = {
	"energy-shield-mk2-equipment",
	"battery-mk2-equipment",
	"fusion-reactor-equipment",
	"personal-laser-defense-equipment",
	"discharge-defense-equipment", -- sorry for indirectly nerfing discharge-defense :(
	"exoskeleton-equipment",
	"personal-roboport-mk2-equipment",
	"power-armor-mk2"
}

if settings.startup["017-lds"].value then
	local recipe = data.raw["recipe"]
	for _, r in pairs(recipe) do
		for _, l in pairs(lds_recipes) do
			if r.name == l then
				modified = false
				for _=1, #r.ingredients do
					if r.ingredients[_][1] == "steel-plate" then
						local n = math.ceil(r.ingredients[_][2] / 2)
						table.remove(r.ingredients, _)
						r.ingredients[#r.ingredients+1] = {"low-density-structure", n}
						modified = true
					end
				end
				if modified == false then
					for _=1, #r.ingredients do
						if r.ingredients[_][1] == "processing-unit" then
							local n = math.ceil(r.ingredients[_][2] / settings.startup["017-lds-num"].value)
							r.ingredients[#r.ingredients+1] = {"low-density-structure", n}
						end
					end
				end
			end
		end
	end
end

--HUGE THANKS to Dimava for the following changes
--Added options for some changes (for modded users)

--increase belt speed to 15x
for _, belt in pairs(data.raw["splitter"]) do
	if (belt.speed * 32) % 1 == 0 and belt.speed * 32 < 8 then
		belt.speed = belt.speed * 45 / 40;
	end
end
for _, belt in pairs(data.raw["transport-belt"]) do
	if (belt.speed * 32) % 1 == 0 and belt.speed * 32 < 8 then
		belt.speed = belt.speed * 45 / 40;
	end
end
for _, belt in pairs(data.raw["underground-belt"]) do
	if (belt.speed * 32) % 1 == 0 and belt.speed * 32 < 8 then
		belt.speed = belt.speed * 45 / 40;
	end
end

if settings.startup["017-drill"].value then
	--simplify drill stats
	data.raw["mining-drill"]["burner-mining-drill"].mining_speed = 0.25
	data.raw["mining-drill"]["burner-mining-drill"].mining_power = 3

	--simplify ore hardness
	for _, ore in pairs(data.raw.resource) do
		if ore.minable.hardness == 0.9 then
			ore.minable.hardness = 1
		end
	end
	data.raw.resource.stone.minable.hardness = 1
end

if settings.startup["017-smelting"].value then
	--decrease smelting times
	for _, recipe in pairs(data.raw.recipe) do
		if recipe.category=="smelting" then
			if recipe.energy_required then
				if (recipe.energy_required / 3.5) % 1 == 0 then
					recipe.energy_required = recipe.energy_required * 3.2 / 3.5
				end
			else
				if (recipe.normal.energy_required / 3.5) % 1 == 0 then
					recipe.normal.energy_required = recipe.normal.energy_required * 3.2 / 3.5
				end
				if (recipe.expensive.energy_required / 3.5) % 1 == 0 then
					recipe.expensive.energy_required = recipe.expensive.energy_required * 3.2 / 3.5
				end			
			end
		end
	end
end

if settings.startup["017-assem-lim"].value then
	--remove assembling-machine ingredient_count limits
	for _, machine in pairs(data.raw["assembling-machine"]) do
		if machine.ingredient_count < 10 then
			machine.ingredient_count = 10
		end
	end
end