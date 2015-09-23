------------------------------------------------------------
-- Copyright (c) 2015 Yakisoba-PanTARO
-- https://github.com/Yakisoba-PanTARO/mosewand
------------------------------------------------------------

-- Register dummy air like node.
minetest.register_node("mosewand:air", {
        drawtype                 = "airlike",
	paramtype                = "light",
	sunlight_propagates      = true,
	walkable                 = false,
	pointable                = false,
	diggable                 = false,
	climbable                = false,
	buildable_to             = true,
})

local directions = {
        { x = 1, y = 0, z = 0 }, { x = -1, y =  0, z =  0 },
        { x = 0, y = 1, z = 0 }, { x =  0, y = -1, z =  0 },
        { x = 0, y = 0, z = 1 }, { x =  0, y =  0, z = -1 },
}

minetest.register_craftitem("mosewand:mosewand", {
        description		= "Mose's Wand",
	inventory_image		= "mosewand_mosewand.png",
	wield_image		= "mosewand_mosewand.png",
	stack_max		= 1,
	liquids_pointable	= true,

	on_place = function(itemstack, placer, pointed_thing)
		return nil
	end,

	on_use = function(itemstack, user, pointed_thing)
		if not pointed_thing.above or not pointed_thing.under then
			return
		end
		
		local above_node = minetest.get_node(pointed_thing.above)
		local under_node = minetest.get_node(pointed_thing.under)

		-- Break all dummy air like nodes that connected.
		if above_node.name == "mosewand:air" then
			function dig_dummy_nodes(pos)
				for _, dir in ipairs(directions) do
					local pos2 = vector.add(pos, dir)
					if minetest.get_node(pos2).name == "mosewand:air" then
						minetest.remove_node(pos2)
						dig_dummy_nodes(pos2)
					end
				end
			end
			-- Remove dummy air like nodes recursively.
			dig_dummy_nodes(pointed_thing.above)
			
                        -- Dig liquid nodes (Place dummy air like nodes).
		elseif minetest.get_item_group(under_node.name, "liquid") > 0 then
			local pos = user:getpos()
			local dir = user:get_look_dir()
			local facedir = minetest.dir_to_facedir(dir)
			
			function place_dummy_nodes(center_pos)
				local count = 0
				
				function place_dummy_nodes_vertically(pos)
					if minetest.get_node(pos).name == under_node.name then
						count = count + 1
						minetest.set_node(pos, {name = "mosewand:air"})
						place_dummy_nodes_vertically(vector.add(pos, {x = 0, y =  1, z = 0}))
						place_dummy_nodes_vertically(vector.add(pos, {x = 0, y = -1, z = 0}))
					end
				end
				
				local hwidth = 2
				if facedir == 0 or facedir == 2 then
					for x = -hwidth, hwidth do
						place_dummy_nodes_vertically(vector.add(center_pos, {x = x, y = 0, z = 0}))
					end
					
				elseif facedir == 1 or facedir == 3 then
					for z = -hwidth, hwidth do
						place_dummy_nodes_vertically(vector.add(center_pos, {x = 0, y = 0, z = z}))
					end
				end
				
				-- Continue the process of placing dummy air like nodes.
				if count > 0 then
					local pos2 = vector.add(center_pos, minetest.facedir_to_dir(facedir))
					
					if facedir == 0 or facedir == 2 then
						pos2.x = pos.x + (pos2.z - pos.z) * dir.x / dir.z
					elseif facedir == 1 or facedir == 3 then
						pos2.z = pos.z + (pos2.x - pos.x) * dir.z / dir.x
					end
					
					place_dummy_nodes(vector.round(pos2))
				end
			end
			-- Place dummy air like nodes recursively.
			place_dummy_nodes(pointed_thing.under)
		end
	end,
})

minetest.register_craft({
	output = "mosewand:mosewand",
	recipe = {
		{ "group:book", "group:book", "default:stick" },
		{ "group:book", "default:stick", "group:book" },
		{ "default:stick", "group:book", "group:book" },
	},
})
