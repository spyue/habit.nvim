vim.api.nvim_create_user_command("HabitInsert", function()
	require("habit").insert()
end, { desc = "Insert a habit tracker below the cursor" })
